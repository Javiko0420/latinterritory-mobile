# Mobile Auth Endpoints Specification

These 3 endpoints are **mobile-specific** and must be added to the web backend
to support the Flutter app's authentication flow. They differ from the existing
web auth routes because mobile clients cannot use HTTP-only cookies — they
need raw JWT tokens in the response body.

---

## 1. `POST /api/auth/mobile/login`

Email + password login that returns JWT tokens in the response body.

### Request

```
POST /api/auth/mobile/login
Content-Type: application/json
```

```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

| Field      | Type   | Required | Validation                    |
|------------|--------|----------|-------------------------------|
| `email`    | string | yes      | Valid email, case-insensitive |
| `password` | string | yes      | Min 8 characters              |

### Response — 200 OK

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "dGhpcyBpcyBhIHJlZnJl...",
  "user": {
    "id": "clx1abc2d0001...",
    "email": "user@example.com",
    "name": "María García",
    "image": "https://storage.example.com/avatars/abc.jpg",
    "role": "USER",
    "profileCompleted": true
  },
  "isNewUser": false
}
```

| Field                  | Type    | Nullable | Notes                                             |
|------------------------|---------|----------|----------------------------------------------------|
| `accessToken`          | string  | no       | Short-lived JWT (recommended 15 min TTL)           |
| `refreshToken`         | string  | no       | Long-lived opaque token (recommended 30 day TTL)   |
| `user.id`              | string  | no       | Prisma CUID / UUID                                 |
| `user.email`           | string  | no       |                                                    |
| `user.name`            | string  | yes      | `null` if not set                                  |
| `user.image`           | string  | yes      | `null` if no avatar                                |
| `user.role`            | string  | no       | `"USER"` or `"ADMIN"` (defaults to `"USER"`)       |
| `user.profileCompleted`| boolean | no       | `false` until user completes onboarding            |
| `isNewUser`            | boolean | no       | Always `false` for email login                     |

### Error Responses

| Status | When                                   | Body                                              |
|--------|----------------------------------------|---------------------------------------------------|
| 400    | Missing or malformed fields            | `{ "message": "Email and password are required." }`|
| 401    | Wrong email/password                   | `{ "message": "Invalid credentials." }`            |
| 403    | Email not verified yet                 | `{ "message": "Please verify your email first." }` |
| 429    | Too many attempts (rate limit)         | `{ "message": "Too many requests." }`              |

### Implementation Notes

- Reuse the existing `verifyPassword` / bcrypt logic from web login.
- **Do NOT set HTTP-only cookies** — mobile stores tokens in secure storage.
- Store the refresh token hash in the database (same `RefreshToken` table used by web).
- Apply rate limiting (e.g. 5 attempts per minute per IP).

---

## 2. `POST /api/auth/mobile/refresh`

Rotate the access + refresh token pair. Implements **refresh token rotation**
(each refresh token is single-use).

### Request

```
POST /api/auth/mobile/refresh
Content-Type: application/json
```

```json
{
  "refreshToken": "dGhpcyBpcyBhIHJlZnJl..."
}
```

| Field          | Type   | Required | Notes                          |
|----------------|--------|----------|--------------------------------|
| `refreshToken` | string | yes      | The current valid refresh token |

### Response — 200 OK

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "bmV3IHJlZnJlc2ggdG9r..."
}
```

| Field          | Type   | Notes                                        |
|----------------|--------|----------------------------------------------|
| `accessToken`  | string | New short-lived JWT (15 min)                 |
| `refreshToken` | string | New rotated refresh token (old one is revoked)|

### Error Responses

| Status | When                                     | Body                                               |
|--------|------------------------------------------|-----------------------------------------------------|
| 400    | Missing `refreshToken` field             | `{ "message": "Refresh token is required." }`       |
| 401    | Token expired, revoked, or not found     | `{ "message": "Invalid or expired refresh token." }`|
| 401    | Reuse detected (token already rotated)   | `{ "message": "Invalid or expired refresh token." }`|

### Implementation Notes

- Lookup the refresh token hash in the `RefreshToken` table.
- If found and not expired: **delete the old row**, generate a new access + refresh token pair, insert the new refresh token hash.
- If the token was already used (reuse detection): **revoke ALL refresh tokens for that user** as a security measure, return 401.
- The mobile `AuthInterceptor` calls this endpoint automatically on 401 or proactively 60 seconds before the access token expires.
- This endpoint is **public** (no `Authorization` header required).

---

## 3. `POST /api/auth/mobile/google`

Authenticate via Google ID token (from the native Google Sign-In SDK on iOS/Android).

### Request

```
POST /api/auth/mobile/google
Content-Type: application/json
```

```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIs..."
}
```

| Field     | Type   | Required | Notes                                       |
|-----------|--------|----------|---------------------------------------------|
| `idToken` | string | yes      | Google ID token from native Sign-In SDK      |

### Response — 200 OK

Same shape as `/api/auth/mobile/login`:

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "dGhpcyBpcyBhIHJlZnJl...",
  "user": {
    "id": "clx1abc2d0001...",
    "email": "user@gmail.com",
    "name": "María García",
    "image": "https://lh3.googleusercontent.com/...",
    "role": "USER",
    "profileCompleted": false
  },
  "isNewUser": true
}
```

| Field       | Notes                                                        |
|-------------|--------------------------------------------------------------|
| `isNewUser` | `true` when the Google account was just created in the DB    |

### Error Responses

| Status | When                                       | Body                                             |
|--------|--------------------------------------------|--------------------------------------------------|
| 400    | Missing `idToken`                          | `{ "message": "Google ID token is required." }`  |
| 401    | Token verification failed (expired, wrong audience, etc.) | `{ "message": "Invalid Google token." }`|
| 429    | Rate limit                                 | `{ "message": "Too many requests." }`            |

### Implementation Notes

- **Verify the ID token** server-side using the Google Auth Library:
  ```ts
  import { OAuth2Client } from 'google-auth-library';

  const client = new OAuth2Client(process.env.GOOGLE_WEB_CLIENT_ID);
  const ticket = await client.verifyIdToken({
    idToken,
    audience: process.env.GOOGLE_WEB_CLIENT_ID,
  });
  const payload = ticket.getPayload();
  // payload.email, payload.name, payload.picture, payload.sub
  ```
- **Find-or-create** the user by email:
  - If user exists: link Google account if not already linked, update `image` from Google if null.
  - If user doesn't exist: create user with `emailVerified: true`, set `isNewUser: true`.
- Generate JWT access + refresh token pair (same as login).
- **Do NOT trust the ID token claims blindly** — always verify with Google's public keys.
- The `audience` claim must match `GOOGLE_WEB_CLIENT_ID` (the same client ID passed to `GoogleSignIn.instance.initialize(serverClientId:)` in the Flutter app).

---

## Shared Conventions

### JWT Access Token Payload

```json
{
  "sub": "clx1abc2d0001...",
  "email": "user@example.com",
  "role": "USER",
  "iat": 1700000000,
  "exp": 1700000900
}
```

- `sub` = user ID
- TTL = 15 minutes (900 seconds)
- Signed with `JWT_SECRET` env var (HS256)

### Error Response Shape

All error responses follow this format for consistency:

```json
{
  "message": "Human-readable error description."
}
```

The mobile app extracts `message` (or falls back to `error`) from every error response body via `ErrorInterceptor._extractMessage()`.

### Security Checklist

- [ ] Rate limit all 3 endpoints (express-rate-limit or similar)
- [ ] Hash refresh tokens before storing (bcrypt or SHA-256)
- [ ] Implement refresh token rotation with reuse detection
- [ ] Verify Google ID tokens server-side (never trust client-side claims)
- [ ] Log authentication events for audit trail
- [ ] Never return password hashes or internal errors to the client
