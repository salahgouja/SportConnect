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
import * as admin from "firebase-admin";
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
export declare const createPaymentIntent: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    paymentIntentId: string;
    clientSecret: string | null;
    amount: number;
    driverAmount: number;
    platformFee: number;
    stripeFee: number;
    hasDriverAccount: any;
    firestoreData: {
        rideId: any;
        riderId: any;
        riderName: any;
        driverId: any;
        driverName: any;
        amount: number;
        currency: any;
        status: string;
        stripePaymentIntentId: string;
        stripeCustomerId: any;
        platformFee: number;
        stripeFee: number;
        driverAmount: number;
        hasDriverStripeAccount: any;
        createdAt: admin.firestore.FieldValue;
    };
}>, unknown>;
/**
 * Get or Create Stripe Customer
 *
 * Request data:
 * - email: string
 * - name?: string
 * - phone?: string
 * - existingCustomerId?: string
 */
export declare const getOrCreateCustomer: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    customerId: string;
    email: string | null;
    isNew: boolean;
}>, unknown>;
/**
 * Create Connected Account for Driver
 *
 * Request data:
 * - email: string
 * - country?: string (default: US)
 */
export declare const createConnectedAccount: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    accountId: string;
    email: string | null;
}>, unknown>;
/**
 * Create Account Link for Stripe Onboarding
 *
 * Request data:
 * - accountId: string
 * - refreshUrl: string
 * - returnUrl: string
 */
export declare const createAccountLink: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    url: string;
    expiresAt: number;
}>, unknown>;
/**
 * Create Instant Payout for Driver
 *
 * Request data:
 * - stripeAccountId: string
 * - amount: number (in cents)
 * - currency: string
 */
export declare const createInstantPayout: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    payoutId: string;
    amount: number;
    status: string;
    arrivalDate: number;
}>, unknown>;
/**
 * Refund Payment
 *
 * Request data:
 * - paymentIntentId: string
 * - amount?: number (partial refund, full if not provided)
 * - reason?: string
 */
export declare const refundPayment: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    refundId: string;
    amount: number;
    status: string | null;
}>, unknown>;
/**
 * Get Connected Account Status
 *
 * Request data:
 * - accountId: string
 */
export declare const getAccountStatus: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    accountId: string;
    chargesEnabled: boolean;
    payoutsEnabled: boolean;
    detailsSubmitted: boolean;
    email: string | null;
}>, unknown>;
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
export declare const stripeWebhook: import("firebase-functions/v2/https").HttpsFunction;
