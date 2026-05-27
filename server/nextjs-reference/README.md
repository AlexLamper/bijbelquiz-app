# Next.js reference: Stripe (web) + RevenueCat (mobile) → MongoDB

Copy files from this folder into your **Next.js** app at `bijbelquiz.com` (same repo or separate).

## Environment variables

| Variable | Purpose |
|----------|---------|
| `MONGODB_URI` | Mongo connection string |
| `REVENUECAT_WEBHOOK_AUTHORIZATION` | **Exact** value of the `Authorization` header RevenueCat sends (set in RevenueCat → Webhooks → optional auth header). If empty, webhook auth is skipped (dev only). |
| `REVENUECAT_REST_API_KEY` | RevenueCat **secret** API key (`sk_...`). **Recommended:** after each webhook, call `GET /v1/subscribers/{app_user_id}` and sync entitlements (official RevenueCat guidance). |
| `REVENUECAT_PREMIUM_ENTITLEMENT_ID` | Default `premium` (must match Flutter `kRcPremiumEntitlement`). |

## Copy map (App Router)

- `app/api/mobile/revenuecat-webhook/route.ts` → your `app/api/mobile/revenuecat-webhook/route.ts`
- `app/api/mobile/sync-premium/route.ts` → your `app/api/mobile/sync-premium/route.ts` (client-triggered reconciliation; **requires `REVENUECAT_REST_API_KEY`**). The Flutter app calls this after purchase/restore and on launch, because RevenueCat does **not** re-send a webhook for an already-owned purchase or a restore — without it, an account whose original purchase webhook failed can never unlock. Align its JWT verification with your real auth (it expects a `userId` claim, like `apple-login`).
- `lib/mongodb.ts` → adjust to your existing `connectDB`
- `lib/models/User.ts` → merge fields into your User model; run a one-time migration to backfill `premiumStripe` from legacy `isPremium` if needed
- `lib/userPremium.ts` → helpers for `effectiveIsPremium`
- `lib/stripe/setPremiumFromStripe.ts` → call from your existing Stripe webhook instead of toggling `isPremium` directly
- `app/api/stripe/webhook/route.example.ts` → merge patterns into your real route

## RevenueCat dashboard (manual)

See [revenuecat-dashboard-checklist.md](./revenuecat-dashboard-checklist.md).

## Flutter

`Purchases.logIn(user.id)` must use the same string as Mongo `User._id` (already true in this repo).
