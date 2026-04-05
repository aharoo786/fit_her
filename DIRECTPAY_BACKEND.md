# Direct Pay (Payin PWA) – Backend Integration

The Flutter app calls your backend to get a Direct Pay payment URL. **Never put `client_secret` in the app.** The backend builds the URL and checksum and returns the full Payin PWA URL to the app.

---

## 1. New endpoint

**POST** `/pay/directpay_payment`

**Headers:** `accessToken` (required) – same as your existing auth.

**Request body (JSON):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `planId` | string | Yes | Plan ID for this payment. |
| `amount` | string or number | Yes | Amount in **PKR** (e.g. `"100"` or `100.50`). Backend converts to paisas. |
| `payerName` | string | Yes | Customer full name. |
| `email` | string | Yes | Customer email. |
| `msisdn` | string | Yes | Pakistan mobile: `03xxxxxxxxx` (11 digits). |
| `successRedirectUrl` | string | Yes | URL Direct Pay redirects to on success (app sends `fither://payment/success?planId=...`). |
| `failedRedirectUrl` | string | Yes | URL Direct Pay redirects to on failure (app sends `fither://payment/failed`). |

**Response (JSON):**

- Success: `{ "status": "1", "message": "OK", "data": { "url": "https://payin-pwa.directpay.pro/pay?...", "client_transaction_id": "..." } }`
- Error: same shape as your other APIs, e.g. `{ "status": "0", "message": "Error message" }`.

The app opens `data.url` in a WebView. When the user completes or cancels, Direct Pay redirects to `successRedirectUrl` or `failedRedirectUrl`; the app intercepts those and closes the WebView (and on success calls your existing “payment success” API with `planId`).

---

## 2. Backend logic (what you implement)

1. **Validate** `accessToken` and get user (you can optionally ignore `payerName` / `email` / `msisdn` from the body and use your own user record).
2. **Obtain Direct Pay credentials** (from env/config):
   - `DIRECTPAY_CLIENT_ID`
   - `DIRECTPAY_CLIENT_SECRET`
3. **Build Payin PWA URL:**
   - **Base URL:** `https://payin-pwa.directpay.pro/pay`
   - **Amount in paisas:** `amount_paisas = round(amount_pkr * 100)` (e.g. 100.00 PKR → 10000 paisas). Use **string** in the URL, e.g. `"10000"`.
   - **client_transaction_id:** unique per transaction, e.g. `FITHER-{planId}-{userId}-{timestamp}`. Max 50 chars, alphanumeric + dashes only.
   - **description:** e.g. `"Fit Her Plan {planId}"`. Max 500 chars; no `<>{}[]|~!@#$%^&*()_+=-\``. Use this **exact** string (unencoded) for checksum; URL-encode only when appending to the URL.
4. **Checksum (HMAC-SHA256):**
   - `plainText = "DirectPay:" + client_transaction_id + ":" + description + ":" + amount_paisas_string`
   - `checksum = HMAC-SHA256(plainText, DIRECTPAY_CLIENT_SECRET)` → output **hex string** (lowercase or uppercase; comparison is case-insensitive).
5. **Query parameters (snake_case):**  
   Add all of these to the base URL (URL-encode values as needed):
   - `client_id` = DIRECTPAY_CLIENT_ID  
   - `client_transaction_id`  
   - `amount` = amount_paisas_string  
   - `description` = URL-encoded description  
   - `payer_name` = payer name  
   - `email`  
   - `msisdn`  
   - `checksum`  
   - `currency` = `PKR` (or `USD` if you support it)  
   - `success_redirect_url`  
   - `failed_redirect_url`  
6. **Return** the full URL in `data.url` (and optionally `data.client_transaction_id`).

---

## 3. Validation (align with Direct Pay docs)

- **Amount:** 1000–5,000,000 paisas (10–50,000 PKR).
- **client_transaction_id:** 1–50 chars, alphanumeric + dashes.
- **description:** max 500 chars, no special chars listed above.
- **msisdn:** `03` + 9 digits (11 digits total).
- **email:** valid email format.

Reject invalid input with your usual error response before building the URL.

---

## 4. After payment (optional)

When the user lands on `fither://payment/success?planId=...`, the app already calls your existing **payment success** endpoint (e.g. `POST /admin/payment_success` with `userId` and `planId`) to update plan status. You don’t need a new endpoint for that.

If Direct Pay supports a **webhook** for payment confirmation, you can add a server-to-server handler to double-check and update orders; that’s independent of the redirect URLs above.

---

## 5. Summary

| Item | Action |
|------|--------|
| New route | `POST /pay/directpay_payment` (auth via `accessToken`). |
| Env vars | `DIRECTPAY_CLIENT_ID`, `DIRECTPAY_CLIENT_SECRET`. |
| Logic | Validate body → convert PKR to paisas → build `client_transaction_id` and `description` → compute HMAC-SHA256 checksum → build full Payin PWA URL → return `{ status, message, data: { url, client_transaction_id? } }`. |
| Redirect URLs | Use exactly what the app sends (`fither://payment/success?planId=...`, `fither://payment/failed`). No need to host extra redirect pages. |

Frontend is already implemented: the app calls this endpoint and opens the returned URL in a WebView, and handles success/failure redirects and plan update.
