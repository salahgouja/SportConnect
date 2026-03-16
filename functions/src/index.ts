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
import {logger} from "firebase-functions/v2";
import * as admin from "firebase-admin";
import Stripe from "stripe";

admin.initializeApp();

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

const PLATFORM_FEE_PERCENT = 0.15; // 15%

// Stripe Express Connect is only available in specific countries.
// If the driver's detected country is not supported, fall back to "FR".
const STRIPE_EXPRESS_COUNTRIES = new Set([
  "AU", "AT", "BE", "BR", "BG", "CA", "HR", "CY", "CZ", "DK", "EE",
  "FI", "FR", "DE", "GH", "GI", "GR", "HK", "HU", "IN", "ID", "IE",
  "IT", "JP", "KE", "LV", "LI", "LT", "LU", "MY", "MT", "MX", "NL",
  "NZ", "NG", "NO", "PL", "PT", "RO", "SG", "SK", "SI", "ZA", "ES",
  "SE", "CH", "TH", "GB", "US",
]);

// ============================================
// Helper: Clean up a single stale FCM token
// ============================================

async function removeStaleToken(userId: string): Promise<void> {
  logger.info(`Removing stale FCM token for user ${userId}`);
  await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .update({fcmToken: admin.firestore.FieldValue.delete()});
}

// ============================================
// Helper: Send FCM Push Notification (single user)
// Used for single-recipient notifications only.
// For multi-recipient use sendPushToMultipleUsers().
// ============================================

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
      logger.info(`No FCM token for user ${userId}, skipping push`);
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
            // FIX: badge removed — hardcoding 1 was wrong.
            // Badge counts must be managed client-side or via a counter,
            // not hardcoded to 1 on the server.
          },
        },
      },
    });

    logger.info(`Push sent to ${userId}: "${title}"`);
  } catch (error: unknown) {
    const e = error as {code?: string};
    // FIX: Added all valid FCM v1 API invalid-token error codes.
    // The HTTP v1 API maps stale/invalid tokens to both
    // "messaging/registration-token-not-registered" (UNREGISTERED)
    // and "messaging/invalid-argument" (INVALID_ARGUMENT).
    if (
      e.code === "messaging/registration-token-not-registered" ||
      e.code === "messaging/invalid-registration-token" ||
      e.code === "messaging/invalid-argument"
    ) {
      await removeStaleToken(userId);
    } else {
      logger.error(`Failed to send push to ${userId}:`, error);
    }
  }
}

// ============================================
// Helper: Send FCM Push to Multiple Users (batch)
// FIX: Replaced N individual sendPushToUser() calls with a single
// sendEachForMulticast() to avoid N Firestore reads + N FCM HTTP calls.
// Uses admin.firestore().getAll() to batch-fetch all tokens in one read,
// then sends one multicast request. Stale tokens are cleaned up per-response.
// ============================================

async function sendPushToMultipleUsers(
  userIds: string[],
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  if (userIds.length === 0) return;

  // Batch-fetch all user documents in a single Firestore call
  const userRefs = userIds.map((id) =>
    admin.firestore().collection("users").doc(id),
  );
  const userDocs = await admin.firestore().getAll(...userRefs);

  // Map tokens back to userIds so we can clean up stale ones later
  const tokenToUserId: Record<string, string> = {};
  const tokens: string[] = [];

  userDocs.forEach((doc, idx) => {
    const token = doc.data()?.fcmToken as string | undefined;
    if (token) {
      tokens.push(token);
      tokenToUserId[token] = userIds[idx];
    } else {
      logger.info(`No FCM token for user ${userIds[idx]}, skipping`);
    }
  });

  if (tokens.length === 0) return;

  const channelId =
    data.type === "message"
      ? "sport_connect_messages"
      : data.type === "ride_request" || data.type === "ride_update"
        ? "sport_connect_rides"
        : "sport_connect_general";

  const response = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {title, body},
    data,
    android: {
      priority: "high",
      notification: {
        channelId,
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          // FIX: No hardcoded badge — managed client-side
        },
      },
    },
  });

  // Handle per-token failures — clean up stale tokens
  if (response.failureCount > 0) {
    const cleanupPromises: Promise<void>[] = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success && resp.error) {
        const code = resp.error.code;
        const staleToken = tokens[idx];
        const userId = tokenToUserId[staleToken];
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token" ||
          code === "messaging/invalid-argument"
        ) {
          cleanupPromises.push(removeStaleToken(userId));
        } else {
          logger.error(`FCM send failed for user ${userId}:`, resp.error);
        }
      }
    });
    await Promise.all(cleanupPromises);
  }

  logger.info(
    `Multicast sent: ${response.successCount} success, ${response.failureCount} failure out of ${tokens.length}`,
  );
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
    const chatId = event.params.chatId;

    // FIX: Do NOT include raw message content in the push payload.
    // Sending real content through FCM exposes it on Google's infrastructure.
    // Use a generic body and let the app fetch the actual message on open.
    const notificationBody = "You have a new message";

    const chatDoc = await admin
      .firestore()
      .collection("chats")
      .doc(chatId)
      .get();
    const chatData = chatDoc.data();
    if (!chatData) return;

    const participantIds = (chatData.participantIds as string[]) || [];
    const recipients = participantIds.filter((id: string) => id !== senderId);

    if (recipients.length === 0) return;

    // FIX: Use batch multicast instead of N individual calls
    await sendPushToMultipleUsers(
      recipients,
      senderName,
      notificationBody,
      {
        type: "message",
        referenceId: chatId,
        senderId,
      },
    );
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
      `${riderName} wants to join your ride${pickup ? " from " + pickup : ""}`,
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
      return;
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

    // Notify passengers when ride starts or completes.
    // passengerIds are NOT embedded on the ride document — they live in the
    // separate `bookings` collection.  Query accepted bookings to get them.
    const isStarting = before.status !== "active" && after.status === "active";
    const isCompleting = before.status !== "completed" && after.status === "completed";

    if (!isStarting && !isCompleting) return;

    const db = admin.firestore();
    const bookingsSnap = await db
      .collection("bookings")
      .where("rideId", "==", event.params.rideId)
      .where("status", "==", "accepted")
      .get();

    const passengerIds = bookingsSnap.docs
      .map((doc) => doc.data().passengerId as string)
      .filter(Boolean);

    if (passengerIds.length === 0) return;

    if (isStarting) {
      const driverName = (after.driverName as string) || "Your driver";
      await sendPushToMultipleUsers(
        passengerIds,
        "Your Ride Has Started! 🚗",
        `${driverName} has started the ride. Track your trip in the app.`,
        {
          type: "ride_update",
          referenceId: event.params.rideId,
          status: "active",
        },
      );
    }

    if (isCompleting) {
      await sendPushToMultipleUsers(
        passengerIds,
        "Ride Completed ✅",
        "Your ride is complete. Don't forget to rate your driver!",
        {
          type: "ride_update",
          referenceId: event.params.rideId,
          status: "completed",
        },
      );
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

    const participantsBefore = (before.participantIds as string[]) || [];
    const participantsAfter = (after.participantIds as string[]) || [];

    const newParticipants = participantsAfter.filter(
      (id: string) => !participantsBefore.includes(id),
    );

    // ── 1. New participant joined ─────────────────────────────────────────
    for (const participantId of newParticipants) {
      if (participantId !== creatorId) {
        let joinerName = "A new player";
        try {
          const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(participantId)
            .get();
          joinerName = (userDoc.data()?.displayName as string) || joinerName;
        } catch {
          // Graceful fallback — name is cosmetic only
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

      // Confirm to the joining participant
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

    // ── 2. Event cancelled ────────────────────────────────────────────────
    if (before.isActive === true && after.isActive === false) {
      const allParticipants = participantsAfter.filter(
        (id: string) => id !== creatorId,
      );

      // FIX: Use batch multicast for cancellation notifications
      await sendPushToMultipleUsers(
        allParticipants,
        "Event cancelled 😞",
        `Unfortunately "${eventTitle}" has been cancelled by the organiser.`,
        {
          type: "event_cancelled",
          referenceId: eventId,
        },
      );
    }

    // ── 3. Event is now full ──────────────────────────────────────────────
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
    logger.info("createConnectedAccount called", {
      userId: request.data?.userId,
      country: request.data?.country,
      authUid: request.auth?.uid,
    });

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
    logger.info("Parsed - userId:", userId, "email:", email, "country:", country);

    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required");
    }

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    // Normalize and validate country — Stripe Express only supports ~44 countries.
    // Fall back to FR if the user's detected country is not in the list.
    const normalizedCountry = (country as string).toUpperCase();
    const stripeCountry = STRIPE_EXPRESS_COUNTRIES.has(normalizedCountry)
      ? normalizedCountry
      : "FR";
    if (stripeCountry !== normalizedCountry) {
      logger.warn(
        `Country "${normalizedCountry}" is not supported for Stripe Express. Falling back to "FR".`,
        {userId, country: normalizedCountry},
      );
    }

    let stripeApiKey: string;
    try {
      stripeApiKey = stripeSecretKey.value().trim();
      logger.info("Stripe API key loaded successfully");
    } catch (err) {
      logger.error("Error getting Stripe secret:", err);
      throw new HttpsError("internal", "Failed to load Stripe API key");
    }

    const stripe = getStripeClient(stripeApiKey);
    const db = admin.firestore();

    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();

    if (!userData) {
      throw new HttpsError("not-found", "User not found in database");
    }

    if (userData.role !== "driver") {
      throw new HttpsError(
        "failed-precondition",
        "User is not registered as a driver",
      );
    }

    let accountId = userData.stripeAccountId;
    logger.info("User data - role:", userData.role, "stripeAccountId:", accountId);

    if (accountId) {
      logger.info("Found existing stripeAccountId:", accountId);
      try {
        const existingAccount = await stripe.accounts.retrieve(accountId);
        logger.info("Existing Stripe account found:", existingAccount.id);
      } catch (error) {
        logger.info("Existing Stripe account not valid, creating new one:", error);
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
      logger.info("Creating new Stripe Connect account for:", email);

      const individual: Record<string, unknown> = {};
      if (firstName) individual.first_name = firstName;
      if (lastName) individual.last_name = lastName;
      if (email) individual.email = email;
      if (phone) {
        // Use phone as-is if it already contains a + prefix (E.164),
        // otherwise don't include it (Stripe accepts blank phone)
        const normalizedPhone = String(phone).trim();
        if (normalizedPhone.startsWith('+')) {
          individual.phone = normalizedPhone;
        }
      }

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

      if (addressLine1 || city) {
        individual.address = {
          ...(addressLine1 && {line1: addressLine1}),
          ...(city && {city}),
          country: stripeCountry,
        };
      }

      let createdAccount: Stripe.Account;
      try {
        createdAccount = await stripe.accounts.create({
          type: "express",
          country: stripeCountry,
          email,
          capabilities: {
            card_payments: {requested: true},
            transfers: {requested: true},
          },
          business_type: "individual",
          business_profile: {
            mcc: "4121",
            product_description:
              "Carpooling driver on SportConnect - providing shared ride services to passengers for cost-sharing commutes and sports events",
          },
          individual: individual as Stripe.AccountCreateParams.Individual,
          metadata: {userId, userType: "driver"},
        });
      } catch (stripeError: unknown) {
        const e = stripeError as {message?: string; type?: string; code?: string};
        logger.error("stripe.accounts.create failed", {
          error: e.message,
          type: e.type,
          code: e.code,
          userId,
          country: stripeCountry,
        });
        throw new HttpsError(
          "internal",
          `Stripe account creation failed: ${e.message ?? "unknown error"}`,
        );
      }

      accountId = createdAccount.id;
      logger.info("New Stripe account created:", accountId);

      await db.collection("users").doc(userId).update({
        stripeAccountId: accountId,
        stripeAccountStatus: "pending",
        chargesEnabled: false,
        payoutsEnabled: false,
        detailsSubmitted: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    const baseUrl = "https://sportaxitrip.com";

    let accountLink: Stripe.AccountLink;
    try {
      accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: `${baseUrl}/stripe-refresh.html?userId=${userId}`,
        return_url: `${baseUrl}/stripe-return.html?userId=${userId}`,
        type: "account_onboarding",
      });
    } catch (stripeError: unknown) {
      const e = stripeError as {message?: string};
      logger.error("stripe.accountLinks.create failed", {
        error: e.message,
        accountId,
        userId,
      });
      throw new HttpsError(
        "internal",
        `Failed to generate Stripe onboarding link: ${e.message ?? "unknown error"}`,
      );
    }

    return {accountId, onboardingUrl: accountLink.url};
  },
);

// ============================================
// Stripe: Create Account Link (re-onboarding)
// ============================================

export const createAccountLink = onCall(
  {secrets: [stripeSecretKey], cors: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const {accountId, refreshUrl, returnUrl} = request.data;

    if (!accountId) {
      throw new HttpsError("invalid-argument", "accountId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const baseUrl = "https://sportaxitrip.com";

    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: refreshUrl || `${baseUrl}/stripe-refresh.html`,
      return_url: returnUrl || `${baseUrl}/stripe-return.html`,
      type: "account_onboarding",
    });

    return {url: accountLink.url};
  },
);

// ============================================
// Stripe: Get Account Status
// ============================================

export const getAccountStatus = onCall(
  {secrets: [stripeSecretKey], cors: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const {accountId} = request.data;

    if (!accountId) {
      throw new HttpsError("invalid-argument", "accountId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());

    try {
      const account = await stripe.accounts.retrieve(accountId);
      return {
        chargesEnabled: account.charges_enabled ?? false,
        payoutsEnabled: account.payouts_enabled ?? false,
        detailsSubmitted: account.details_submitted ?? false,
        requirements: account.requirements?.currently_due ?? [],
        disabledReason: account.requirements?.disabled_reason ?? null,
      };
    } catch (error: unknown) {
      // FIX: Use typed error handling instead of `any`
      const e = error as {message?: string};
      logger.error("getAccountStatus failed", {accountId, error: e.message});
      throw new HttpsError(
        "not-found",
        `Stripe account not found: ${e.message ?? "unknown error"}`,
      );
    }
  },
);

// ============================================
// Stripe: Create Instant Payout
// ============================================

export const createInstantPayout = onCall(
  {secrets: [stripeSecretKey], cors: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const {stripeAccountId, amount, currency = "eur"} = request.data;

    if (!stripeAccountId || !amount) {
      throw new HttpsError(
        "invalid-argument",
        "stripeAccountId and amount are required",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    const callerDoc = await db.collection("users").doc(request.auth.uid).get();
    const callerData = callerDoc.data();
    if (!callerData || callerData.stripeAccountId !== stripeAccountId) {
      throw new HttpsError(
        "permission-denied",
        "You are not authorized to create payouts for this account",
      );
    }

    const amountInCents = Math.round(amount * 100);

    // FIX: Moved charges_enabled check OUTSIDE the try/catch so the
    // meaningful HttpsError message is preserved and not caught+re-wrapped.
    const account = await stripe.accounts.retrieve(stripeAccountId).catch(
      (error: unknown) => {
        const e = error as {message?: string};
        logger.error("createInstantPayout: account verification failed", {
          stripeAccountId,
          uid: request.auth?.uid,
          error: e.message,
        });
        throw new HttpsError(
          "not-found",
          `Stripe account verification failed: ${e.message ?? "unknown error"}`,
        );
      },
    );

    if (!account.payouts_enabled) {
      throw new HttpsError(
        "failed-precondition",
        "Payouts are not enabled for this account",
      );
    }

    const payout = await stripe.payouts.create(
      {
        amount: amountInCents,
        currency: currency.toLowerCase(),
        method: "instant",
      },
      {stripeAccount: stripeAccountId},
    );

    const payoutRef = await db.collection("payouts").add({
      driverId: request.auth.uid,
      stripePayoutId: payout.id,
      connectedAccountId: stripeAccountId,
      amount,
      currency,
      status: payout.status === "paid" ? "completed" : "inTransit",
      isInstantPayout: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expectedArrivalDate: payout.arrival_date
        ? new Date(payout.arrival_date * 1000)
        : null,
    });

    return {
      payoutId: payoutRef.id,
      stripePayoutId: payout.id,
      status: payout.status,
      arrivalDate: payout.arrival_date,
    };
  },
);

// ============================================
// Stripe: Refund Payment
// ============================================

export const refundPayment = onCall(
  {secrets: [stripeSecretKey], cors: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const {paymentIntentId, amount, reason = "requested_by_customer"} =
      request.data;

    if (!paymentIntentId) {
      throw new HttpsError("invalid-argument", "paymentIntentId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    // FIX: Single Firestore query — reuse paymentSnap for both auth check
    // and update loop. The original code queried the same collection twice.
    const paymentSnap = await db
      .collection("payments")
      .where("paymentIntentId", "==", paymentIntentId)
      .get();

    if (paymentSnap.empty) {
      throw new HttpsError("not-found", "Payment not found");
    }

    const paymentDoc = paymentSnap.docs[0].data();
    if (
      paymentDoc.passengerId !== request.auth.uid &&
      paymentDoc.driverId !== request.auth.uid
    ) {
      throw new HttpsError(
        "permission-denied",
        "You are not authorized to refund this payment",
      );
    }

    const refundParams: Record<string, unknown> = {
      payment_intent: paymentIntentId,
      reason,
    };

    if (amount) {
      refundParams.amount = Math.round(amount * 100);
    }

    const refund = await stripe.refunds.create(
      refundParams as Parameters<typeof stripe.refunds.create>[0],
    );

    // FIX: Reuse paymentSnap.docs instead of running a second identical query
    for (const doc of paymentSnap.docs) {
      const isFullRefund = !amount || amount >= (doc.data().amount ?? 0);
      await doc.ref.update({
        status: isFullRefund ? "refunded" : "partiallyRefunded",
        refundedAt: admin.firestore.FieldValue.serverTimestamp(),
        refundReason: reason,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      refundId: refund.id,
      status: refund.status,
      amount: (refund.amount ?? 0) / 100,
    };
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

    if (existingCustomerId) {
      try {
        const existing = await stripe.customers.retrieve(existingCustomerId);
        if (!existing.deleted) {
          return {customerId: existingCustomerId};
        }
      } catch {
        logger.info("Existing customer not found, creating new one");
      }
    }

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
        logger.info("Stored customer ID invalid, creating new one");
      }
    }

    const customer = await stripe.customers.create({
      email,
      ...(name && {name}),
      ...(phone && {phone}),
      metadata: {userId},
    });

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
      riderName,
      driverName,
      driverStripeAccountId,
      description,
      customerId,
      // FIX: The client SDK's required API version must be passed from Flutter.
      // The ephemeral key apiVersion must match the Flutter stripe package version,
      // not the server's Stripe API version. Pass it as `stripeApiVersion`.
      stripeApiVersion,
    } = request.data;

    if (!amount || !rideId || !driverId || !riderId) {
      throw new HttpsError("invalid-argument", "Missing required fields");
    }

    if (!driverStripeAccountId) {
      throw new HttpsError(
        "failed-precondition",
        "Driver has not set up Stripe Connect account. Payment cannot be processed.",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    // FIX: Moved charges_enabled check OUTSIDE the try/catch to preserve
    // the meaningful error message. The original swallowed it into a generic catch.
    const account = await stripe.accounts.retrieve(driverStripeAccountId).catch(
      (error: unknown) => {
        const e = error as {message?: string};
        logger.error("Error retrieving Stripe account:", {
          driverStripeAccountId,
          driverId,
          error: e.message,
        });
        throw new HttpsError(
          "failed-precondition",
          `Driver's Stripe account verification failed: ${e.message ?? "unknown error"}`,
        );
      },
    );

    if (!account.charges_enabled) {
      throw new HttpsError(
        "failed-precondition",
        "Driver's Stripe account is not fully activated. Charges are not enabled.",
      );
    }

    if (!account.payouts_enabled) {
      logger.warn(`Driver ${driverId} has charges enabled but payouts disabled`);
    }

    const amountInCents = Math.round(amount * 100);
    const {platformFee, driverAmount} = calculateFees(amountInCents);

    const idempotencyKey = `pi_${rideId}_${riderId}_${amountInCents}`;

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

    await db.collection("payments").add({
      paymentIntentId: paymentIntent.id,
      rideId,
      driverId,
      riderId,
      riderName: riderName || "",
      driverName: driverName || "",
      driverStripeAccountId,
      amount,
      currency,
      platformFee: platformFee / 100,
      driverEarnings: driverAmount / 100,
      stripeFee: 0,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // FIX: The ephemeral key apiVersion MUST be the version required by the
    // Flutter stripe SDK (client-side), NOT the server API version.
    // The client passes its required version as `stripeApiVersion`.
    // Stripe enforces that ephemeral keys must be created with the client's version.
    let ephemeralKey: string | undefined;
    if (customerId) {
      const ephemeralKeyVersion = stripeApiVersion || "2025-12-15.clover";
      const ephemeralKeyObj = await stripe.ephemeralKeys.create(
        {customer: customerId},
        {apiVersion: ephemeralKeyVersion},
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
  // FIX: Webhooks do NOT need cors:true — they are called by Stripe, not by browsers.
  // Enabling CORS on a webhook can expose it unnecessarily.
  {secrets: [stripeSecretKey, stripeWebhookSecret]},
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
      logger.error("Webhook signature verification failed:", err);
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

        const paymentMethodId =
          typeof pi.payment_method === "string"
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
            logger.warn("Could not retrieve payment method details");
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

        const rideId = pi.metadata?.rideId;
        const riderId = pi.metadata?.riderId;
        if (rideId && riderId) {
          const bookingsSnap = await db
            .collection("bookings")
            .where("rideId", "==", rideId)
            .where("passengerId", "==", riderId)
            .where("status", "==", "accepted")
            .get();

          const matchingBookings = bookingsSnap.docs
            .filter((doc) => !doc.data()["paidAt"])
            .sort((a, b) => {
              const aTimestamp =
                (a.data()["createdAt"] ??
                  a.data()["respondedAt"]) as admin.firestore.Timestamp | undefined;
              const bTimestamp =
                (b.data()["createdAt"] ??
                  b.data()["respondedAt"]) as admin.firestore.Timestamp | undefined;

              const aMillis = aTimestamp?.toMillis() ?? 0;
              const bMillis = bTimestamp?.toMillis() ?? 0;
              return bMillis - aMillis;
            });

          const bookingDoc = matchingBookings[0];

          if (bookingDoc) {
            await bookingDoc.ref.update({
              paymentIntentId: pi.id,
              paidAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
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

        let onboardingStatus = "pending";
        if (isActive) {
          onboardingStatus = "active";
        } else if (account.details_submitted) {
          onboardingStatus = "under_review";
        } else if (account.requirements?.currently_due?.length) {
          onboardingStatus = "incomplete";
        }

        await db.collection("users").doc(userId).update({
          stripeAccountStatus: onboardingStatus,
          chargesEnabled: account.charges_enabled ?? false,
          payoutsEnabled: account.payouts_enabled ?? false,
          detailsSubmitted: account.details_submitted ?? false,
          isStripeEnabled: account.charges_enabled ?? false,
          isStripeOnboarded: isActive,
          stripeRequirements: account.requirements?.currently_due ?? [],
          stripeDisabledReason:
            account.requirements?.disabled_reason ?? null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        if (isActive) {
          await sendPushToUser(
            userId,
            "Stripe Account Active! 🎉",
            "Your payout account is ready. You can now receive ride payments directly!",
            {type: "stripe", referenceId: userId},
          );
        } else if (onboardingStatus === "incomplete") {
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
        logger.info(`Unhandled event type: ${event.type}`);
      }

      res.status(200).json({received: true});
    } catch (error) {
      logger.error("Error processing webhook", {
        eventType: event.type,
        eventId: event.id,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      res.status(500).json({error: "Webhook processing failed"});
    }
  },
);