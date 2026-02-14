// ============================================
// SportConnect Cloud Functions
// Stripe Payments + Push Notification Triggers
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
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const {userId, email, country = "FR"} = request.data;
    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value());
    const db = admin.firestore();

    const userDoc = await db.collection("drivers").doc(userId).get();
    let accountId = userDoc.data()?.stripeAccountId;

    if (!accountId) {
      const account = await stripe.accounts.create({
        type: "express",
        country,
        email,
        capabilities: {
          card_payments: {requested: true},
          transfers: {requested: true},
        },
        business_type: "individual",
        metadata: {userId, userType: "driver"},
      });

      accountId = account.id;

      await db.collection("drivers").doc(userId).set(
        {
          stripeAccountId: accountId,
          stripeAccountStatus: "pending",
          email,
          country,
          chargesEnabled: false,
          payoutsEnabled: false,
          detailsSubmitted: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    }

    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: `sportconnect://stripe-refresh?userId=${userId}`,
      return_url: `sportconnect://stripe-return?userId=${userId}`,
      type: "account_onboarding",
    });

    return {accountId, onboardingUrl: accountLink.url};
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

    const stripe = getStripeClient(stripeSecretKey.value());
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

    // Create payment intent with destination charge
    // Funds are transferred to driver's connected account after platform fee
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency,
      application_fee_amount: platformFee,
      transfer_data: {destination: driverStripeAccountId},
      metadata: {rideId, driverId, riderId},
    });

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

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  },
);

// ============================================
// Stripe: Webhook Handler
// ============================================

export const stripeWebhook = onRequest(
  {secrets: [stripeSecretKey, stripeWebhookSecret], cors: true},
  async (req, res) => {
    const stripe = getStripeClient(stripeSecretKey.value());
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

        for (const doc of payments.docs) {
          await doc.ref.update({
            status: "completed",
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
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

        await db.collection("drivers").doc(userId).update({
          stripeAccountStatus: isActive ? "active" : "pending",
          chargesEnabled: account.charges_enabled,
          payoutsEnabled: account.payouts_enabled,
          detailsSubmitted: account.details_submitted,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        if (isActive) {
          await sendPushToUser(
            userId,
            "Stripe Account Active 🎉",
            "Your Stripe account is now active!",
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
