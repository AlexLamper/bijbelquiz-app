# RevenueCat dashboard checklist (manual)

Use this after deploying the webhook route to production.

1. **Project → Integrations → Webhooks → Add new configuration**
   - URL: `https://www.bijbelquiz.com/api/mobile/revenuecat-webhook`
   - **Authorization header**: set a strong random value; put the **same** value in `REVENUECAT_WEBHOOK_AUTHORIZATION` on the server (full header value, e.g. `Bearer yourlongsecret` if you configure it that way in the dashboard).
2. **Entitlements**: create entitlement id **`premium`** (matches Flutter `kRcPremiumEntitlement`).
3. **Products**: App Store + Play product IDs **`bijbelquiz_premium_monthly`**, **`bijbelquiz_premium_lifetime`** attached to `premium`.
4. **Offerings**: current offering includes both packages (optional if you only use direct product IDs in the app).
5. **Test**: Dashboard → send test webhook; confirm Mongo `premiumStore` / `effectiveIsPremium` updates for a known `app_user_id`.
