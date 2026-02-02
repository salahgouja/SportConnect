/**
 * SportConnect Firebase Cloud Functions
 *
 * Stripe payment processing functions for the SportConnect app.
 *
 * Available Functions:
 * - createPaymentIntent - Create payment intent for ride booking
 * - getOrCreateCustomer - Get or create Stripe customer
 * - createConnectedAccount - Create driver's Stripe Connect account
 * - createAccountLink - Create Stripe onboarding link
 * - createInstantPayout - Instant payout to driver
 * - refundPayment - Refund a payment
 * - stripeWebhook - Handle Stripe webhooks
 *
 * Environment Variables Required (set with firebase functions:config:set):
 * - stripe.secret_key - Stripe secret key
 * - stripe.webhook_secret - Stripe webhook signing secret
 */

import {onRequest, onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import Stripe from "stripe";

// Initialize Firebase Admin
admin.initializeApp();

// Define secrets
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

// Platform fee configuration
const PLATFORM_FEE_PERCENT = 0.15; // 15%
const STRIPE_FEE_PERCENT = 0.029; // 2.9%
const STRIPE_FIXED_FEE = 30; // $0.30 in cents

/**
 * Create and return a configured Stripe client.
 *
 * @param {string} secretKey - Stripe secret key.
 * @return {Stripe} Initialized Stripe client.
 */
function getStripeClient(secretKey: string): Stripe {
  return new Stripe(secretKey, {
    apiVersion: "2025-12-15.clover",
  });
}

/**
 * Calculate payment fees and the driver's share.
 *
 * @param {number} amount - Amount in cents.
 * @return {{
 *   platformFee: number,
 *   stripeFee: number,
 *   driverAmount: number
 * }} Fee breakdown in cents.
 */
function calculateFees(amount: number) {
  const platformFee = Math.round(amount * PLATFORM_FEE_PERCENT);
  const stripeFee = Math.round(amount * STRIPE_FEE_PERCENT + STRIPE_FIXED_FEE);
  const driverAmount = amount - platformFee - stripeFee;

  return {platformFee, stripeFee, driverAmount};
}

// =============================================================================
// CALLABLE FUNCTIONS (for Flutter client)
// =============================================================================

/**
 * Create Payment Intent for ride booking
 *
 * Request data:
 * - rideId: string
 * - riderId: string
 * - riderName: string
 * - driverId: string
 * - driverName: string
 * - driverStripeAccountId?: string (driver's connected account)
 * - amount: number (in cents)
 * - currency: string
 * - customerId?: string
 * - description?: string
 */
export const createPaymentIntent = onCall(
  {
    secrets: [stripeSecretKey],
    cors: true,
  },
  async (request) => {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    const {
      rideId,
      riderId,
      driverId,
      driverStripeAccountId,
      amount,
      currency = "usd",
      customerId,
      description,
      riderName,
      driverName,
    } = data;

    // Validate required fields
    if (!rideId || !riderId || !driverId || !amount) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields: rideId, riderId, driverId, amount",
      );
    }

    // Security: Verify caller is the rider
    if (request.auth.uid !== riderId) {
      throw new HttpsError(
        "permission-denied",
        "Cannot create payment for another user",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value());
    const fees = calculateFees(amount);
    const hasDriverAccount = driverStripeAccountId?.startsWith("acct_");

    try {
      // Build payment intent options
      const paymentIntentOptions: Stripe.PaymentIntentCreateParams = {
        amount: Math.round(amount),
        currency: currency.toLowerCase(),
        customer: customerId || undefined,
        description: description || `Ride booking #${rideId}`,
        metadata: {
          rideId,
          driverId,
          riderId,
          platformFee: fees.platformFee.toString(),
          stripeFee: fees.stripeFee.toString(),
          driverAmount: fees.driverAmount.toString(),
        },
        automatic_payment_methods: {
          enabled: true,
        },
      };

      // Add destination charges if driver has Stripe account
      if (hasDriverAccount && driverStripeAccountId) {
        paymentIntentOptions.transfer_data = {
          destination: driverStripeAccountId,
          amount: fees.driverAmount,
        };
        paymentIntentOptions.application_fee_amount = fees.platformFee;
      }

      const paymentIntent =
        await stripe.paymentIntents.create(paymentIntentOptions);

      console.log(
        `Created payment intent ${paymentIntent.id} for ride ${rideId}`,
      );

      return {
        paymentIntentId: paymentIntent.id,
        clientSecret: paymentIntent.client_secret,
        amount: Math.round(amount),
        driverAmount: fees.driverAmount,
        platformFee: fees.platformFee,
        stripeFee: fees.stripeFee,
        hasDriverAccount,
        firestoreData: {
          rideId,
          riderId,
          riderName: riderName || "Rider",
          driverId,
          driverName: driverName || "Driver",
          amount: Math.round(amount),
          currency,
          status: "pending",
          stripePaymentIntentId: paymentIntent.id,
          stripeCustomerId: customerId || null,
          platformFee: fees.platformFee,
          stripeFee: fees.stripeFee,
          driverAmount: fees.driverAmount,
          hasDriverStripeAccount: hasDriverAccount,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      };
    } catch (error) {
      console.error("Error creating payment intent:", error);
      throw new HttpsError("internal", `Failed to create payment: ${error}`);
    }
  },
);

/**
 * Get or Create Stripe Customer
 *
 * Request data:
 * - email: string
 * - name?: string
 * - phone?: string
 * - existingCustomerId?: string
 */
export const getOrCreateCustomer = onCall(
  {
    secrets: [stripeSecretKey],
    cors: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    const {email, name, phone, existingCustomerId} = data;

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value());
    const userId = request.auth.uid;

    try {
      // Check if existing customer
      if (existingCustomerId) {
        try {
          const existing = await stripe.customers.retrieve(existingCustomerId);
          if (existing && !existing.deleted) {
            return {
              customerId: existing.id,
              email: (existing as Stripe.Customer).email,
              isNew: false,
            };
          }
        } catch {
          // Customer doesn't exist, create new one
        }
      }

      // Create new customer
      const customer = await stripe.customers.create({
        email,
        name,
        phone,
        metadata: {userId},
      });

      console.log(`Created Stripe customer ${customer.id} for user ${userId}`);

      return {
        customerId: customer.id,
        email: customer.email,
        isNew: true,
      };
    } catch (error) {
      console.error("Error creating customer:", error);
      throw new HttpsError("internal", `Failed to create customer: ${error}`);
    }
  },
);

/**
 * Create Connected Account for Driver
 *
 * Request data:
 * - email: string
 * - country?: string (default: US)
 */
export const createConnectedAccount = onCall(
  {
    secrets: [stripeSecretKey],
    cors: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    const {email, country = "US"} = data;

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value());
    const userId = request.auth.uid;

    try {
      const account = await stripe.accounts.create({
        type: "express",
        country,
        email,
        capabilities: {
          transfers: {requested: true},
        },
        metadata: {userId},
      });

      console.log(`Created connected account ${account.id} for user ${userId}`);

      return {
        accountId: account.id,
        email: account.email,
      };
    } catch (error) {
      console.error("Error creating connected account:", error);
      throw new HttpsError(
        "internal",
        `Failed to create connected account: ${error}`,
      );
    }
  },
);

/**
 * Create Account Link for Stripe Onboarding
 *
 * Request data:
 * - accountId: string
 * - refreshUrl: string
 * - returnUrl: string
 */
export const createAccountLink = onCall(
  {
    secrets: [stripeSecretKey],
    cors: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    const {accountId, refreshUrl, returnUrl} = data;

    if (!accountId || !refreshUrl || !returnUrl) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields: accountId, refreshUrl, returnUrl",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value());

    try {
      const accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: refreshUrl,
        return_url: returnUrl,
        type: "account_onboarding",
      });

      return {
        url: accountLink.url,
        expiresAt: accountLink.expires_at,
      };
    } catch (error) {
      console.error("Error creating account link:", error);
      throw new HttpsError(
        "internal",
        `Failed to create account link: ${error}`,
      );
    }
  },
);

/**
 * Create Instant Payout for Driver
 *
 * Request data:
 * - stripeAccountId: string
 * - amount: number (in cents)
 * - currency: string
 */
export const createInstantPayout = onCall(
  {
    secrets: [stripeSecretKey],
    cors: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    const {stripeAccountId, amount, currency = "usd"} = data;

    if (!stripeAccountId || !amount) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields: stripeAccountId, amount",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value());
    const driverId = request.auth.uid;

    try {
      const payout = await stripe.payouts.create(
        {
          amount,
          currency: currency.toLowerCase(),
          method: "instant",
          description: `Instant payout for driver ${driverId}`,
        },
        {
          stripeAccount: stripeAccountId,
        },
      );

      console.log(`Created instant payout ${payout.id} for driver ${driverId}`);

      return {
        payoutId: payout.id,
        amount: payout.amount,
        status: payout.status,
        arrivalDate: payout.arrival_date,
      };
    } catch (error) {
      console.error("Error creating instant payout:", error);
      throw new HttpsError(
        "internal",
        `Failed to create instant payout: ${error}`,
      );
    }
  },
);

/**
 * Refund Payment
 *
 * Request data:
 * - paymentIntentId: string
 * - amount?: number (partial refund, full if not provided)
 * - reason?: string
 */
export const refundPayment = onCall(
  {
    secrets: [stripeSecretKey],
    cors: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    const {paymentIntentId, amount, reason} = data;

    if (!paymentIntentId) {
      throw new HttpsError("invalid-argument", "paymentIntentId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value());
    const refundedBy = request.auth.uid;

    try {
      const refund = await stripe.refunds.create({
        payment_intent: paymentIntentId,
        amount: amount || undefined,
        reason:
          (reason as Stripe.RefundCreateParams.Reason) ||
          "requested_by_customer",
        metadata: {refundedBy},
      });

      console.log(`Created refund ${refund.id} for payment ${paymentIntentId}`);

      return {
        refundId: refund.id,
        amount: refund.amount,
        status: refund.status,
      };
    } catch (error) {
      console.error("Error creating refund:", error);
      throw new HttpsError("internal", `Failed to create refund: ${error}`);
    }
  },
);

/**
 * Get Connected Account Status
 *
 * Request data:
 * - accountId: string
 */
export const getAccountStatus = onCall(
  {
    secrets: [stripeSecretKey],
    cors: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    const {accountId} = data;

    if (!accountId) {
      throw new HttpsError("invalid-argument", "accountId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value());

    try {
      const account = await stripe.accounts.retrieve(accountId);

      return {
        accountId: account.id,
        chargesEnabled: account.charges_enabled,
        payoutsEnabled: account.payouts_enabled,
        detailsSubmitted: account.details_submitted,
        email: account.email,
      };
    } catch (error) {
      console.error("Error retrieving account:", error);
      throw new HttpsError("internal", `Failed to retrieve account: ${error}`);
    }
  },
);

// =============================================================================
// HTTP ENDPOINT FOR WEBHOOKS
// =============================================================================

/**
 * Stripe Webhook Handler
 *
 * Handles Stripe events:
 * - payment_intent.succeeded
 * - payment_intent.payment_failed
 * - account.updated
 * - payout.paid
 * - payout.failed
 */
export const stripeWebhook = onRequest(
  {
    secrets: [stripeSecretKey, stripeWebhookSecret],
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const stripe = getStripeClient(stripeSecretKey.value());
    const sig = req.headers["stripe-signature"];
    const webhookSecret = stripeWebhookSecret.value();

    let event: Stripe.Event;

    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig as string,
        webhookSecret,
      );
    } catch (err) {
      console.error("Webhook signature verification failed:", err);
      res.status(400).send(`Webhook Error: ${err}`);
      return;
    }

    const db = admin.firestore();

    try {
      switch (event.type) {
      case "payment_intent.succeeded": {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        const rideId = paymentIntent.metadata.rideId;

        if (rideId) {
          await db.collection("payments").doc(paymentIntent.id).update({
            status: "succeeded",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // Update ride status
          await db.collection("rides").doc(rideId).update({
            paymentStatus: "paid",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        console.log(`Payment succeeded: ${paymentIntent.id}`);
        break;
      }

      case "payment_intent.payment_failed": {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        const rideId = paymentIntent.metadata.rideId;

        if (rideId) {
          await db
            .collection("payments")
            .doc(paymentIntent.id)
            .update({
              status: "failed",
              failureMessage:
                  paymentIntent.last_payment_error?.message || "Payment failed",
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        console.log(`Payment failed: ${paymentIntent.id}`);
        break;
      }

      case "account.updated": {
        const account = event.data.object as Stripe.Account;
        const userId = account.metadata?.userId;

        if (userId) {
          await db.collection("users").doc(userId).update({
            "stripeConnect.chargesEnabled": account.charges_enabled,
            "stripeConnect.payoutsEnabled": account.payouts_enabled,
            "stripeConnect.detailsSubmitted": account.details_submitted,
            "stripeConnect.updatedAt":
                admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        console.log(`Account updated: ${account.id}`);
        break;
      }

      case "payout.paid": {
        const payout = event.data.object as Stripe.Payout;
        console.log(`Payout paid: ${payout.id}`);
        break;
      }

      case "payout.failed": {
        const payout = event.data.object as Stripe.Payout;
        console.log(
          `Payout failed: ${payout.id} - ${payout.failure_message}`,
        );
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
