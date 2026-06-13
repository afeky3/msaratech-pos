# Teddy POS System - Technical Documentation

## Overview

Teddy POS is a point-of-sale system built for **Teeddy Bear** (a children's clothing/toys retail store). It runs as a local web application on Windows, connects to Shopify for product catalog and order management, and supports thermal receipt printing via 80mm POS printers.

- **URL**: http://localhost:3001
- **Stack**: Node.js + Express (backend), Vanilla HTML/CSS/JS (frontend)
- **Platform**: Windows (required for printer discovery via WMI)
- **Currency**: EGP (Egyptian Pound)
- **Tax Rate**: 14% VAT (POS-side only — not recorded in Shopify line items)

---

## Project Structure

```
pos-system/
  server.js                # Express backend (single file, all API routes)
  package.json             # Dependencies: express only
  DOCUMENTATION.md         # This file
  public/
    index.html             # Full frontend SPA (HTML + CSS + JS in one file)
  data/
    shopify-config.json    # Shopify credentials and connection state
    shopify-products.json  # Cached product catalog from Shopify (470 products)
    orders-history.json    # Permanent log of all orders and returns
    shift.json             # Current open shift (deleted on close)
    shift_SHF-*.json       # Archived closed shifts
    pins.json              # Staff PIN codes (id -> 4-digit PIN)
  media/
    re-02.png              # Teeddy Bear logo (used on receipts)
    re-03.png              # QR code → teeddybear.com (used on receipts)
  node_modules/            # Express + dependencies
```

---

## Getting Started

### Prerequisites
- Node.js (v16+)
- Windows OS (for printer detection)
- Internet connection (for Shopify API calls)

### Installation & Run
```bash
cd pos-system
npm install
npm start
```
Server starts at **http://localhost:3001**

---

## Authentication & Users

### Staff Accounts

| ID | Name    | Role    | Default PIN |
|----|---------|---------|-------------|
| 1  | Admin   | admin   | 1234        |
| 2  | Cashier | cashier | 6666        |

### Login Flow
1. User selects their name on the login screen
2. Enters 4-digit PIN via on-screen keypad
3. System validates PIN against `data/pins.json`
4. On success, checks for an existing open shift

### PIN Management
- Only **Admin** (id:1) can change PINs
- Requires admin to enter their own PIN for confirmation
- PINs must be exactly 4 digits
- Changes persist to `data/pins.json`

---

## Shift Management

### Lifecycle
```
Login → Open Shift (enter opening cash) → Process Orders → Close Shift → Logout
```

### Shift Data Structure
```json
{
  "id": "SHF-1781128246004",
  "openedBy": "Admin",
  "openedAt": "2026-06-10T21:50:46.004Z",
  "openingCash": 0,
  "orders": [...],
  "totalCash": 4332,
  "totalVisa": 7524,
  "totalTransfer": 0,
  "nextOrderCounter": 1005
}
```

### Key Behaviors
- Only one shift can be open at a time (server-wide)
- Shift persists across server restarts (via `data/shift.json`)
- On close: shift is archived to `data/shift_SHF-{id}.json` and `shift.json` is deleted
- Closing prints an End-of-Day report summarizing all items sold and payment totals

---

## Order Reference Format

Every order gets a unique daily reference number:

```
Format:  YYMMDДНННNN
Example: 26061200001
         ^^           → year 26
           ^^^^       → month 06, day 12
               ^^^^^  → sequence 00001 (first order of that day)
```

- Sequence resets every day
- Returns do **not** consume a sequence number (sales only)
- Stored as `ref` in `orders-history.json`

---

## Shopify Integration

### Connection Method
**Direct Client Credentials** — no OAuth redirect, no browser flow.

### Credentials
| Field         | Value                                  |
|---------------|----------------------------------------|
| App Name      | Teddybear                              |
| Store URL     | (set in data/shopify-config.json)      |
| Client ID     | (set in data/shopify-config.json)      |
| Client Secret | (set in data/shopify-config.json)      |
| API Version   | 2025-01                                |

### How Connection Works
1. POS sends `grant_type=client_credentials` + Client ID + Secret to `/admin/oauth/access_token`
2. Shopify returns an access token (`shpat_xxxxx`)
3. Token saved to `data/shopify-config.json`
4. All API calls use `X-Shopify-Access-Token` header

### Product Sync
- `POST /api/shopify-sync` — fetches ALL active products (paginated, 250/page)
- Maps to POS format: id, variantId, inventoryItemId, title, price, barcode/SKU, image, category
- Cached locally in `data/shopify-products.json`
- Auto-fetches the store's primary location ID for inventory management

### Order Push (on every sale)
1. Creates Shopify order via `POST /orders.json` with:
   - Line items (variant ID + quantity only — **no tax lines**)
   - Transaction: full VAT-inclusive amount, correct gateway (Cash/Visa/Bank Transfer)
   - Financial status: `paid`, source: `Teddy POS`
2. Saves the returned Shopify order ID to `orders-history.json` for future cancellation
3. Manually decrements inventory via `POST /inventory_levels/adjust.json` (`-quantity`)
   — Admin API orders do not auto-decrement stock

### Return / Cancellation (on every return)
1. `POST /orders/{shopifyOrderId}/refunds.json` — creates refund transaction (VAT-inclusive amount, `restock_type: no_restock`)
2. `POST /orders/{shopifyOrderId}/cancel.json` — cancels the order (`reason: customer`)
3. Manually restores inventory via `POST /inventory_levels/adjust.json` (`+quantity`)

Shopify order result after return:
```
Status:   Cancelled
Payment:  Refunded  ✅
Refund:   EGP xx.xx ✅
```

### VAT Handling
| Where         | VAT behaviour                                              |
|---------------|------------------------------------------------------------|
| POS receipt   | Calculated at 14%, shown as separate line                  |
| Shopify order | Transaction = VAT-inclusive total; line items = base price only (no tax_lines) |
| Shopify refund| Transaction = VAT-inclusive refund amount                  |

### Customer Management
- **Lookup**: search by phone number → `GET /customers/search.json`
- **Create**: `POST /customers.json` with name, phone, email
- Attached to orders at checkout; passed to Shopify order

### Fallback Products
When Shopify is not connected, 12 hardcoded demo products are used (offline/demo mode).

---

## Order Processing

### Flow
1. Cashier adds products to cart (tap, search, or barcode scan)
2. Optionally: attach customer, add discount, add note
3. Select payment method: **Cash / Visa / Transfer**
4. If cash: enter amount received — system calculates change
5. Click **Charge** → receipt preview appears
6. **Print** (saves order + opens print dialog) or **New Order** (saves + clears cart)
7. Cancel discards the unsaved order

### Order Data Structure
```json
{
  "ref":          "26061200001",
  "type":         "sale",
  "items":        [{ "id": ..., "title": ..., "price": ..., "quantity": ... }],
  "payment":      "cash|visa|transfer",
  "discount":     0,
  "subtotal":     1900,
  "tax":          266,
  "total":        2166,
  "cashGiven":    2166,
  "date":         "2026-06-10T21:53:03.614Z",
  "customerId":   null,
  "customerName": "",
  "cashier":      "Admin",
  "shopifyOrderId": 123456789
}
```

### Tax Calculation
```
subtotal = sum(price × quantity)
taxable  = subtotal - discount
tax      = taxable × 0.14
total    = taxable + tax
```

---

## Order History

### Storage
All orders (sales + returns) saved permanently to `data/orders-history.json`.

### Access by Role
| Role    | Access                                      |
|---------|---------------------------------------------|
| Admin   | Full list — all orders, all dates           |
| Cashier | Search only — must enter exact order ref    |

### History Modal (frontend)
- **Admin**: full scrollable list with SALE/RETURN badges, dates, amounts
- **Cashier**: blank until a ref is typed + Enter or Search clicked
- Click any order → **Order Detail modal**

### Order Detail Modal
- Shows all items, payment, cashier, customer, totals
- For sale orders: "Return qty" input per item (capped at unreturned quantity)
- Fully returned items show "fully returned"
- Optional return reason field
- **Process Return** button triggers the return flow

---

## Return Flow

### Backend Steps
1. Validate original order exists (`type: sale`)
2. Check returnable quantities (`quantity - returnedQty`)
3. Calculate return amounts (proportional discount + 14% VAT)
4. Generate return ref (same format, sales-only sequence)
5. Save return record to history (`type: return`, `originalRef`)
6. Update `returnedQty` on original order items
7. Adjust shift totals (subtract from cash/visa/transfer)
8. Restore Shopify inventory (`+quantity`)
9. Create Shopify refund transaction
10. Cancel Shopify order

### Return Record Structure
```json
{
  "ref":         "26061200002",
  "type":        "return",
  "originalRef": "26061200001",
  "items":       [...],
  "payment":     "cash",
  "reason":      "Customer changed mind",
  "subtotal":    100,
  "tax":         14,
  "total":       114,
  "date":        "...",
  "cashier":     "Admin"
}
```

---

## Receipt Format

### Layout (top → bottom)
1. **Logo** — `media/re-02.png` (Teeddy Bear logo, 80–90px wide, centered)
2. Branch: **North Coast (Seashell)**
3. Website: **teeddybear.com**
4. Divider
5. Order ref, date, payment method, customer (if any), note (if any)
6. Divider
7. Item lines: name × qty, then unit price → line total
8. Divider
9. Subtotal, Discount (if any), Tax 14%
10. Divider
11. **TOTAL** (bold, larger)
12. Cash given / Change (if cash payment)
13. Divider
14. "Thank you for shopping with us!"
15. **QR Code** — `media/re-03.png` (80px wide, centered) → teeddybear.com
16. teeddybear.com (small grey text)

### Print
- Designed for **80mm thermal printers** (XP-80C default)
- Uses `window.print()` with `@media print` CSS
- Images served from `/media/` static route

---

## Barcode Scanner Support

- Physical scanners work by typing characters rapidly + Enter
- Frontend detects rapid keystrokes (< 200ms between chars)
- On Enter: if buffer ≥ 4 chars → lookup by barcode/SKU
- Matches `barcode` or `sku` field (case-insensitive)

---

## Printing

### Printer Discovery
- Windows WMI via temporary VBScript (`Win32_Printer`)
- Detects: name, driver, port, status (7=Offline, 3/4=Ready)

### Shift Report
- Printed on shift close
- Contains: all items sold (aggregated), payment breakdown, opening cash, shift times

---

## API Reference

### Authentication
| Method | Endpoint        | Description               |
|--------|-----------------|---------------------------|
| POST   | /api/login      | Verify PIN, return user   |
| GET    | /api/pins       | List staff (no PIN values)|
| POST   | /api/pin-change | Change a user's PIN       |

### Products
| Method | Endpoint        | Description                   |
|--------|-----------------|-------------------------------|
| GET    | /api/products   | Get all active products       |
| GET    | /api/barcode?c= | Lookup product by barcode/SKU |

### Orders & History
| Method | Endpoint                    | Description                          |
|--------|-----------------------------|--------------------------------------|
| POST   | /api/order                  | Create order (requires open shift)   |
| GET    | /api/orders-history?role=   | Full history (admin) or empty list   |
| GET    | /api/order-lookup?ref=      | Find single order by ref             |
| POST   | /api/order-return           | Process return + Shopify cancel      |

### Shift
| Method | Endpoint          | Description            |
|--------|-------------------|------------------------|
| POST   | /api/shift-status | Check if shift is open |
| POST   | /api/shift-open   | Open new shift         |
| POST   | /api/shift-close  | Close shift + archive  |

### Shopify
| Method | Endpoint                | Description                      |
|--------|-------------------------|----------------------------------|
| POST   | /api/shopify-connect    | Connect using Client ID + Secret |
| GET    | /api/shopify-config     | Get connection status            |
| POST   | /api/shopify-config     | Update location ID               |
| POST   | /api/shopify-sync       | Sync all products from Shopify   |
| POST   | /api/shopify-disconnect | Disconnect and clear data        |

### Customers
| Method | Endpoint             | Description                    |
|--------|----------------------|--------------------------------|
| GET    | /api/customer?phone= | Search customer by phone       |
| POST   | /api/customer        | Create new customer in Shopify |

### Printer
| Method | Endpoint             | Description               |
|--------|----------------------|---------------------------|
| GET    | /api/printer         | Get active printer + list |
| POST   | /api/printer-select  | Set active printer        |
| POST   | /api/printer-refresh | Re-scan Windows printers  |

---

## Frontend Architecture

Single-page application — 3 screens:

1. **Login** (`#loginScreen`) — staff selection + PIN entry
2. **Shift** (`#shiftScreen`) — open shift with opening cash amount
3. **POS** (`#posScreen`) — main working screen:
   - Top bar: shift info, clock, History, Sync, PIN (admin), Shopify (admin), Printer, Close Shift
   - Left panel: product grid, search, category filters
   - Right panel: cart, customer, totals, payment selector, charge button

### Modals
| Modal            | Purpose                                      |
|------------------|----------------------------------------------|
| Receipt          | Preview receipt + Print or New Order         |
| Close Shift      | Summary + confirm close                      |
| History          | Order history list / search                  |
| Order Detail     | View order + initiate return                 |
| Printer          | Discover + select printer                    |
| PIN              | Change PINs (admin only)                     |
| Shopify          | Connect / disconnect / sync products         |

### Role-Based UI
| Feature           | Admin | Cashier |
|-------------------|-------|---------|
| Shopify button    | ✅    | ❌      |
| PIN change button | ✅    | ❌      |
| Full history list | ✅    | ❌      |
| History search    | ✅    | ✅      |
| Process returns   | ✅    | ✅      |

---

## Data Persistence

| File                       | Purpose                        | Survives Restart |
|----------------------------|--------------------------------|------------------|
| data/shopify-config.json   | Shopify credentials/token      | Yes              |
| data/shopify-products.json | Product catalog cache          | Yes              |
| data/orders-history.json   | All orders + returns (permanent)| Yes             |
| data/shift.json            | Current open shift             | Yes              |
| data/shift_SHF-*.json      | Closed shift archives          | Yes (permanent)  |
| data/pins.json             | Staff PIN codes                | Yes              |

No database required — all JSON files.

---

## Security Notes

- PINs stored in plaintext in `pins.json` (local-only system)
- Shopify credentials in `shopify-config.json` (keep off version control)
- No HTTPS (localhost only)
- No session tokens — trust based on local network
- Admin PIN required for sensitive operations

---

## Deployment Notes

- Runs on a **single Windows PC** at the store counter
- Keep server running via PM2 or Windows Task Scheduler
- Printer must be installed as a Windows printer (driver required)
- Internet needed for: Shopify sync, order push, returns, customer lookup
- Offline: uses cached products, orders saved locally in shift file

---

## Store Information

| Field    | Value                              |
|----------|------------------------------------|
| Store    | Teeddy Bear                        |
| Website  | teeddybear.com                     |
| Domain   | 550a98-2.myshopify.com             |
| Branch   | North Coast (Seashell)             |
| Country  | Egypt                              |
| Currency | EGP                                |
| Email    | teddy.bear0855@gmail.com           |
| Phone    | 01067755833                        |
| Plan     | Shopify Basic                      |
| Products | 470 (clothing, swimwear, toys)     |
