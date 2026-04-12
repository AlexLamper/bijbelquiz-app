---
description: "Use when creating, building, or maintaining the Flutter mobile application for Bijbelquiz. Covers architecture, API connection to Next.js, and state management."
applyTo: "bijbelquiz_mobile/**/*.dart"
---

# Flutter Mobile App Architecture & Guidelines

## Architecture & Communication
- **API First**: The mobile app is entirely independent and communicates *exclusively* with the Next.js API endpoints (`https://www.bijbelquiz.com/api/...`).
- **No Direct DB Access**: Never connect to MongoDB directly from the Flutter app. The Next.js backend is the single source of truth.
- **Project Structure**: Strict Feature-First Clean Architecture. Use `lib/core/` for app-wide shared routing, theme, and API client (Dio setup). Use `lib/features/<feature>/` subdiving into `data/` (repositories, models, local storage), `domain/` (entities, use cases), and `present/` (UI screens, widgets, Riverpod providers).

## Authentication Layer
- **Contract First**: Always build the backend endpoints (Next.js) first before building the Flutter UI. Real end-to-end integration is validated immediately against actual DTOs.
- **JWT Only**: Standard NextAuth cookies do not work natively. Use dedicated JWT endpoints (e.g., `/api/mobile/login`, `/api/mobile/register`) that return explicit JSON Web Tokens.
- **Token Storage**: Store JWT tokens securely on the device using `flutter_secure_storage`.
- **Interceptors**: Inject the stored token into the `Authorization: Bearer <token>` header of every outgoing API request using an HTTP interceptor.

## Tech Stack & Dependencies
- **API Calls**: Strictly use **Dio**. Natively excels at handling interceptors, token injection/refreshes, global error handling, and base URLs.
- **State Management**: Riverpod (`flutter_riverpod`).
- **Routing**: `go_router`.
- **Social Login**: `google_sign_in`.
- **Monetization**: Native In-App Purchases via `purchases_flutter` (RevenueCat) — *Do not use web Stripe checkout*.

## Design System
- Clone the web application's design system (colors, typography, logos).
- Store offline assets (e.g., logos) in the `assets/` folder to avoid unnecessary network payload.
- Consolidate theme management in a centralized `AppTheme` class supporting dark/light modes.

## Security & Best Practices
- **Environment Variables**: Use `.env` files for configuration. Never hardcode API keys or the prod base URL in the source code.
- **Local Dev**: Point base URL to `http://<LOCAL_IP>:3000/api` for local testing with the Next.js server.
