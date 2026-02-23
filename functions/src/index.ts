// ============================================
// SportConnect Cloud Functions
// Stripe Payments + Push Notification Triggers + Event Triggers
// ============================================

import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {onRequest, onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import Stripe from "stripe";

admin.initializeApp();

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

const PLATFORM_FEE_PERCENT = 0.15; // 15%

// ============================================
// Helper: Send FCM Push Notification
// ============================================

/**
 * Look up a user's FCM token and send a push notification.
 */
async function sendPushToUser(
  userId: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  try {
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();
    const fcmToken = userDoc.data()?.fcmToken as string | undefined;

    if (!fcmToken) {
      console.log(`No FCM token for user ${userId}, skipping push`);
      return;
    }

    await admin.messaging().send({
      token: fcmToken,
      notification: {title, body},
      data,
      android: {
        priority: "high",
        notification: {
          channelId:
            data.type === "message"
              ? "sport_connect_messages"
              : data.type === "ride_request" || data.type === "ride_update"
                ? "sport_connect_rides"
                : "sport_connect_general",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    });

    console.log(`Push sent to ${userId}: "${title}"`);
  } catch (error: unknown) {
    const e = error as {code?: string};
    // Token may be stale — clean it up
    if (
      e.code === "messaging/invalid-registration-token" ||
      e.code === "messaging/registration-token-not-registered"
    ) {
      console.log(`Removing stale FCM token for user ${userId}`);
      await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
    } else {
      console.error(`Failed to send push to ${userId}:`, error);
    }
  }
}

// ============================================
// Trigger: New Chat Message
// ============================================

export const onNewMessage = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const senderId = message.senderId as string;
    const senderName = message.senderName as string;
    const content = message.content as string;
    const chatId = event.params.chatId;

    // Get chat document to find other participants
    const chatDoc = await admin
      .firestore()
      .collection("chats")
      .doc(chatId)
      .get();
    const chatData = chatDoc.data();
    if (!chatData) return;

    const participantIds = (chatData.participantIds as string[]) || [];

    // Send push to all participants except the sender
    const pushPromises = participantIds
      .filter((id: string) => id !== senderId)
      .map((recipientId: string) =>
        sendPushToUser(
          recipientId,
          senderName,
          content.length > 100
            ? content.substring(0, 100) + "..."
            : content,
          {
            type: "message",
            referenceId: chatId,
            senderId,
          },
        ),
      );

    await Promise.all(pushPromises);
  },
);

// ============================================
// Trigger: New Ride Request
// ============================================

export const onNewRideRequest = onDocumentCreated(
  "rideRequests/{requestId}",
  async (event) => {
    const request = event.data?.data();
    if (!request) return;

    const driverId = request.driverId as string;
    const riderName = (request.riderName as string) || "A rider";
    const rideId = request.rideId as string;
    const pickup = (request.pickupAddress as string) || "";

    await sendPushToUser(
      driverId,
      "New Ride Request",
      `${riderName} wants to join your ride${
        pickup ? " from " + pickup : ""
      }`,
      {
        type: "ride_request",
        referenceId: rideId,
        requestId: event.params.requestId,
      },
    );
  },
);

// ============================================
// Trigger: Ride Request Status Changed
// ============================================

export const onRideRequestUpdated = onDocumentUpdated(
  "rideRequests/{requestId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    // Only trigger on status changes
    if (before.status === after.status) return;

    const riderId = after.riderId as string;
    const newStatus = after.status as string;
    const rideId = after.rideId as string;

    let title = "";
    let body = "";

    switch (newStatus) {
    case "accepted":
      title = "Ride Request Accepted! 🎉";
      body = "Your ride request has been accepted. Get ready!";
      break;
    case "rejected":
      title = "Ride Request Declined";
      body = "Unfortunately, your ride request was not accepted.";
      break;
    case "cancelled":
      title = "Ride Cancelled";
      body = "A ride you were part of has been cancelled.";
      break;
    default:
      return; // No push for other statuses
    }

    await sendPushToUser(riderId, title, body, {
      type: "ride_update",
      referenceId: rideId,
      status: newStatus,
    });
  },
);

// ============================================
// Trigger: Ride Status Changes (started, completed)
// ============================================

export const onRideStatusChanged = onDocumentUpdated(
  "rides/{rideId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    // Notify passengers when ride starts
    if (before.status !== "active" && after.status === "active") {
      const passengerIds = (after.passengerIds as string[]) || [];
      const driverName = (after.driverName as string) || "Your driver";

      const pushPromises = passengerIds.map((passengerId: string) =>
        sendPushToUser(
          passengerId,
          "Your Ride Has Started! 🚗",
          `${driverName} has started the ride. Track your trip in the app.`,
          {
            type: "ride_update",
            referenceId: event.params.rideId,
            status: "active",
          },
        ),
      );

      await Promise.all(pushPromises);
    }

    // Notify passengers when ride is completed
    if (before.status !== "completed" && after.status === "completed") {
      const passengerIds = (after.passengerIds as string[]) || [];

      const pushPromises = passengerIds.map((passengerId: string) =>
        sendPushToUser(
          passengerId,
          "Ride Completed ✅",
          "Your ride is complete. Don't forget to rate your driver!",
          {
            type: "ride_update",
            referenceId: event.params.rideId,
            status: "completed",
          },
        ),
      );

      await Promise.all(pushPromises);
    }
  },
);

// ============================================
// Trigger: New Sport Event Created
// ============================================

export const onNewEvent = onDocumentCreated(
  "events/{eventId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const creatorId = data.creatorId as string;
    const title = (data.title as string) || "New event";
    const eventType = (data.type as string) || "sport";
    const eventId = event.params.eventId;

    // Notify the creator that their event is live
    await sendPushToUser(
      creatorId,
      "Your event is live! 🎉",
      `"${title}" is now visible to all SportConnect users. Good luck!`,
      {
        type: "event_created",
        referenceId: eventId,
        eventType,
      },
    );
  },
);

// ============================================
// Trigger: Event Updated (participant joined / event cancelled)
// ============================================

export const onEventUpdated = onDocumentUpdated(
  "events/{eventId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const eventId = event.params.eventId;
    const eventTitle = (after.title as string) || "An event";
    const creatorId = after.creatorId as string;

    // ── 1. A new participant joined ──────────────────────────────────────
    const participantsBefore = (before.participantIds as string[]) || [];
    const participantsAfter = (after.participantIds as string[]) || [];

    const newParticipants = participantsAfter.filter(
      (id: string) => !participantsBefore.includes(id),
    );

    for (const participantId of newParticipants) {
      // Notify the event creator about the new participant
      if (participantId !== creatorId) {
        // Look up the joining user's name for a personalised message
        let joinerName = "A new player";
        try {
          const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(participantId)
            .get();
          joinerName = (userDoc.data()?.displayName as string) || joinerName;
        } catch {
          // Graceful fallback — name is just cosmetic
        }

        await sendPushToUser(
          creatorId,
          "New participant! 🏅",
          `${joinerName} joined your event "${eventTitle}".`,
          {
            type: "event_joined",
            referenceId: eventId,
            participantId,
          },
        );
      }

      // Confirm to the participant that they are in
      await sendPushToUser(
        participantId,
        "You're in! ✅",
        `You have successfully joined "${eventTitle}". See you there!`,
        {
          type: "event_joined",
          referenceId: eventId,
        },
      );
    }

    // ── 2. Event cancelled (isActive flipped from true → false) ─────────
    if (before.isActive === true && after.isActive === false) {
      const allParticipants = participantsAfter.filter(
        (id: string) => id !== creatorId,
      );

      const cancelPushes = allParticipants.map((participantId: string) =>
        sendPushToUser(
          participantId,
          "Event cancelled 😞",
          `Unfortunately "${eventTitle}" has been cancelled by the organiser.`,
          {
            type: "event_cancelled",
            referenceId: eventId,
          },
        ),
      );

      await Promise.all(cancelPushes);
    }

    // ── 3. Event is now full ─────────────────────────────────────────────
    const maxParticipants = (after.maxParticipants as number) || 0;
    if (
      maxParticipants > 0 &&
      participantsAfter.length >= maxParticipants &&
      participantsBefore.length < maxParticipants
    ) {
      await sendPushToUser(
        creatorId,
        "Your event is full! 🎊",
        `"${eventTitle}" has reached its maximum capacity of ${maxParticipants} participants.`,
        {
          type: "event_full",
          referenceId: eventId,
        },
      );
    }
  },
);

// ============================================
// Stripe Helpers
// ============================================

function getStripeClient(secretKey: string): Stripe {
  return new Stripe(secretKey, {
    apiVersion: "2025-12-15.clover",
  });
}

function calculateFees(amount: number) {
  const platformFee = Math.round(amount * PLATFORM_FEE_PERCENT);
  const driverAmount = amount - platformFee;
  return {platformFee, driverAmount};
}

// ============================================
// Stripe: Create Connected Account
// ============================================

export const createConnectedAccount = onCall(
  {secrets: [stripeSecretKey], cors: true},
  async (request) => {
    console.log("Request data:", JSON.stringify(request.data));
    console.log("Request auth:", request.auth?.uid);

    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const {
      userId,
      email,
      country = "FR",
      firstName,
      lastName,
      phone,
      dateOfBirth,
      addressLine1,
      city,
    } = request.data;
    console.log("Parsed - userId:", userId, "email:", email, "country:", country);

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    // Get the Stripe API key from secret
    let stripeApiKey: string;
    try {
      stripeApiKey = stripeSecretKey.value().trim();
      console.log("Stripe API key loaded, prefix:", stripeApiKey?.substring(0, 20));
    } catch (err) {
      console.error("Error getting Stripe secret:", err);
      throw new HttpsError("internal", "Failed to load Stripe API key");
    }

    console.log("Creating Stripe client...");
    const stripe = getStripeClient(stripeApiKey);
    console.log("Stripe client created successfully");

    const db = admin.firestore();

    // Try to get driver info from users collection (where user data is stored)
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();

    if (!userData) {
      throw new HttpsError("not-found", "User not found in database");
    }

    // Check if user is a driver
    if (userData.role !== "driver") {
      throw new HttpsError(
        "failed-precondition",
        "User is not registered as a driver"
      );
    }

    let accountId = userData.stripeAccountId;
    console.log("User data - role:", userData.role, "stripeAccountId:", accountId);

    // If there's an existing accountId, verify it exists in Stripe
    if (accountId) {
      console.log("Found existing stripeAccountId:", accountId);
      try {
        const existingAccount = await stripe.accounts.retrieve(accountId);
        console.log("Existing Stripe account found:", existingAccount.id);
      } catch (error) {
        console.log("Existing Stripe account not valid, creating new one:", error);
        // Clear invalid accountId and create new one
        accountId = null;
        await db.collection("users").doc(userId).update({
          stripeAccountId: admin.firestore.FieldValue.delete(),
          stripeAccountStatus: admin.firestore.FieldValue.delete(),
          chargesEnabled: admin.firestore.FieldValue.delete(),
          payoutsEnabled: admin.firestore.FieldValue.delete(),
          detailsSubmitted: admin.firestore.FieldValue.delete(),
        });
      }
    }

    if (!accountId) {
      // Create new Stripe Connect account with prefilled individual info
      // Prefilling reduces onboarding friction - Stripe won't ask for prefilled fields
      console.log("Creating new Stripe Connect account for:", email);

      // Build individual info from user profile data
      const individual: Record<string, unknown> = {};
      if (firstName) individual.first_name = firstName;
      if (lastName) individual.last_name = lastName;
      if (email) individual.email = email;
      if (phone) individual.phone = phone;

      // Prefill date of birth if available
      if (dateOfBirth) {
        const dob = new Date(dateOfBirth);
        if (!isNaN(dob.getTime())) {
          individual.dob = {
            day: dob.getDate(),
            month: dob.getMonth() + 1,
            year: dob.getFullYear(),
          };
        }
      }

      // Prefill address if available
      if (addressLine1 || city) {
        individual.address = {
          ...(addressLine1 && {line1: addressLine1}),
          ...(city && {city}),
          country,
        };
      }

      const account = await stripe.accounts.create({
        type: "express",
        country,
        email,
        capabilities: {
          card_payments: {requested: true},
          transfers: {requested: true},
        },
        business_type: "individual",
        business_profile: {
          mcc: "4121", // Taxicabs/Limousines - standard MCC for rideshare/carpooling
          product_description:
            "Carpooling driver on SportConnect - providing shared ride services to passengers for cost-sharing commutes and sports events",
        },
        individual: individual as Stripe.AccountCreateParams.Individual,
        metadata: {userId, userType: "driver"},
      });

      accountId = account.id;
      console.log("New Stripe account created:", accountId);

      // Save Stripe account ID to user document
      await db.collection("users").doc(userId).update({
        stripeAccountId: accountId,
        stripeAccountStatus: "pending",
        chargesEnabled: false,
        payoutsEnabled: false,
        detailsSubmitted: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Stripe requires valid HTTP/HTTPS URLs for return/refresh
    // Using Firebase Hosting with redirect pages
    const baseUrl = "https://marathon-connect.web.app";

    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: `${baseUrl}/stripe-refresh.html?userId=${userId}`,
      return_url: `${baseUrl}/stripe-return.html?userId=${userId}`,
      type: "account_onboarding",
    });

    return {accountId, onboardingUrl: accountLink.url};
  },
);

// ============================================
// Stripe: Get or Create Customer
// ============================================

export const getOrCreateCustomer = onCall(
  {secrets: [stripeSecretKey], cors: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const {email, name, phone, existingCustomerId} = request.data;

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();
    const userId = request.auth.uid;

    // If an existing customer ID was provided, verify it still exists
    if (existingCustomerId) {
      try {
        const existing = await stripe.customers.retrieve(existingCustomerId);
        if (!existing.deleted) {
          return {customerId: existingCustomerId};
        }
      } catch {
        console.log("Existing customer not found, creating new one");
      }
    }

    // Check if user already has a Stripe customer ID in Firestore
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();
    if (userData?.stripeCustomerId) {
      try {
        const existing = await stripe.customers.retrieve(
          userData.stripeCustomerId,
        );
        if (!existing.deleted) {
          return {customerId: userData.stripeCustomerId};
        }
      } catch {
        console.log("Stored customer ID invalid, creating new one");
      }
    }

    // Create new Stripe customer
    const customer = await stripe.customers.create({
      email,
      ...(name && {name}),
      ...(phone && {phone}),
      metadata: {userId},
    });

    // Save customer ID to user document
    await db.collection("users").doc(userId).update({
      stripeCustomerId: customer.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {customerId: customer.id};
  },
);

// ============================================
// Stripe: Create Payment Intent
// ============================================

export const createPaymentIntent = onCall(
  {secrets: [stripeSecretKey], cors: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const {
      amount,
      currency = "eur",
      rideId,
      driverId,
      riderId,
      driverStripeAccountId,
      description,
      customerId,
    } = request.data;

    if (!amount || !rideId || !driverId || !riderId) {
      throw new HttpsError("invalid-argument", "Missing required fields");
    }

    // Check if driver's Stripe account ID was provided
    if (!driverStripeAccountId) {
      throw new HttpsError(
        "failed-precondition",
        "Driver has not set up Stripe Connect account. Payment cannot be processed.",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    // Verify the Stripe account exists and is active
    try {
      const account = await stripe.accounts.retrieve(driverStripeAccountId);
      
      if (!account.charges_enabled) {
        throw new HttpsError(
          "failed-precondition",
          "Driver's Stripe account is not fully activated. Charges are not enabled.",
        );
      }

      if (!account.payouts_enabled) {
        console.warn(
          `Driver ${driverId} has charges enabled but payouts disabled`,
        );
      }
    } catch (error: any) {
      console.error("Error verifying Stripe account:", error);
      throw new HttpsError(
        "failed-precondition",
        `Driver's Stripe account verification failed: ${error.message}`,
      );
    }

    const amountInCents = Math.round(amount * 100);
    const {platformFee} = calculateFees(amountInCents);

    // Generate idempotency key to prevent duplicate charges on retries
    const idempotencyKey = `pi_${rideId}_${riderId}_${amountInCents}`;

    // Create payment intent with destination charge
    // - automatic_payment_methods enables all eligible payment methods for better conversion
    // - Funds are transferred to driver's connected account after platform fee
    const paymentIntent = await stripe.paymentIntents.create(
      {
        amount: amountInCents,
        currency,
        automatic_payment_methods: {enabled: true},
        application_fee_amount: platformFee,
        transfer_data: {destination: driverStripeAccountId},
        description: description || `SportConnect ride payment - ${rideId}`,
        metadata: {rideId, driverId, riderId},
      },
      {idempotencyKey},
    );

    // Save payment record to Firestore
    await db.collection("payments").add({
      paymentIntentId: paymentIntent.id,
      rideId,
      driverId,
      riderId,
      driverStripeAccountId,
      amount: amountInCents,
      currency,
      platformFee,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Create ephemeral key for Payment Sheet (needed for saved cards)
    let ephemeralKey: string | undefined;
    if (customerId) {
      const ephemeralKeyObj = await stripe.ephemeralKeys.create(
        {customer: customerId},
        {apiVersion: "2025-12-15.clover"} // Use latest API version
      );
      ephemeralKey = ephemeralKeyObj.secret;
    }

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      ...(ephemeralKey && {ephemeralKey}),
    };
  },
);

// ============================================
// Stripe: Webhook Handler
// ============================================

export const stripeWebhook = onRequest(
  {secrets: [stripeSecretKey, stripeWebhookSecret], cors: true},
  async (req, res) => {
    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const sig = req.headers["stripe-signature"];

    if (!sig) {
      res.status(400).json({error: "Missing Stripe signature"});
      return;
    }

    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        stripeWebhookSecret.value(),
      );
    } catch (err) {
      console.error("Webhook signature verification failed:", err);
      res.status(400).json({error: "Invalid signature"});
      return;
    }

    const db = admin.firestore();

    try {
      switch (event.type) {
      case "payment_intent.succeeded": {
        const pi = event.data.object as Stripe.PaymentIntent;
        const payments = await db
          .collection("payments")
          .where("paymentIntentId", "==", pi.id)
          .get();

        // Extract card details for payment history display
        const paymentMethodId = typeof pi.payment_method === "string"
          ? pi.payment_method
          : pi.payment_method?.id;

        let last4: string | null = null;
        let brand: string | null = null;
        if (paymentMethodId) {
          try {
            const pm = await stripe.paymentMethods.retrieve(paymentMethodId);
            last4 = pm.card?.last4 ?? null;
            brand = pm.card?.brand ?? null;
          } catch {
            console.warn("Could not retrieve payment method details");
          }
        }

        for (const doc of payments.docs) {
          await doc.ref.update({
            status: "completed",
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
            ...(last4 && {paymentMethodLast4: last4}),
            ...(brand && {paymentMethodBrand: brand}),
          });
        }
        break;
      }

      case "payment_intent.payment_failed": {
        const pi = event.data.object as Stripe.PaymentIntent;
        const payments = await db
          .collection("payments")
          .where("paymentIntentId", "==", pi.id)
          .get();

        for (const doc of payments.docs) {
          await doc.ref.update({
            status: "failed",
            failedAt: admin.firestore.FieldValue.serverTimestamp(),
            failureMessage:
              pi.last_payment_error?.message || "Payment failed",
          });
        }
        break;
      }

      case "account.updated": {
        const account = event.data.object as Stripe.Account;
        const userId = account.metadata?.userId;
        if (!userId) break;

        const isActive =
          account.charges_enabled &&
          account.payouts_enabled &&
          account.details_submitted;

        // Determine detailed onboarding status
        let onboardingStatus = "pending";
        if (isActive) {
          onboardingStatus = "active";
        } else if (account.details_submitted) {
          onboardingStatus = "under_review";
        } else if (account.requirements?.currently_due?.length) {
          onboardingStatus = "incomplete";
        }

        // Update the user's Stripe account status with detailed info
        await db.collection("users").doc(userId).update({
          stripeAccountStatus: onboardingStatus,
          chargesEnabled: account.charges_enabled ?? false,
          payoutsEnabled: account.payouts_enabled ?? false,
          detailsSubmitted: account.details_submitted ?? false,
          isStripeEnabled: account.charges_enabled ?? false,
          isStripeOnboarded: isActive,
          stripeRequirements:
            account.requirements?.currently_due ?? [],
          stripeDisabledReason:
            account.requirements?.disabled_reason ?? null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Notify driver on final activation
        if (isActive) {
          await sendPushToUser(
            userId,
            "Stripe Account Active! 🎉",
            "Your payout account is ready. You can now receive ride payments directly!",
            {type: "stripe", referenceId: userId},
          );
        } else if (onboardingStatus === "incomplete") {
          // Gently remind if there are outstanding requirements
          await sendPushToUser(
            userId,
            "Complete Your Stripe Setup",
            "A few more details are needed to activate your payout account.",
            {type: "stripe", referenceId: userId},
          );
        }
        break;
      }

      default:
        console.log(`Unhandled event type: ${event.type}`);
      }

      res.status(200).json({received: true});
    } catch (error) {
      console.error("Error processing webhook:", error);
      res.status(500).json({error: "Webhook processing failed"});
    }
  },
);
