# RevenueCat dashboard checklist (manual)

Use this after deploying the webhook route to production.

1. **Project → Integrations → Webhooks → Add new configuration**
   - URL: `https://www.bijbelquiz.com/api/mobile/revenuecat-webhook`
   - **Authorization header**: set a strong random value; put the **same** value in `REVENUECAT_WEBHOOK_AUTHORIZATION` on the server (full header value, e.g. `Bearer yourlongsecret` if you configure it that way in the dashboard).
2. **Entitlements**: create entitlement id **`premium`** (matches Flutter `kRcPremiumEntitlement`).
3. **Products**: App Store + Play product IDs **`bijbelquiz_premium_monthly`**, **`bijbelquiz_premium_lifetime`** attached to `premium`.
4. **Offerings**: current offering includes both packages (optional if you only use direct product IDs in the app).
5. **Test**: Dashboard → send test webhook; confirm Mongo `premiumStore` / `effectiveIsPremium` updates for a known `app_user_id`.
6. **REST API key**: copy the **secret** key (`sk_...`) from Project → API keys into `REVENUECAT_REST_API_KEY`. Required by the webhook's live re-fetch **and** by `POST /api/mobile/sync-premium` (the client-triggered reconciliation the app uses for already-owned purchases / restores). Without it, neither can update Mongo.
7. **Recover an already-purchased account** (no new webhook will ever fire for it): once the REST key + `sync-premium` route are deployed, the app self-reconciles on next launch / restore. To fix immediately from the dashboard instead: open the customer (search their Mongo `_id` as `app_user_id`), confirm the `premium` entitlement is active, then either re-deliver the original event from **Webhooks → delivery logs**, or set `premiumStore: true` (and `isPremium: true`) on that Mongo user by hand.
