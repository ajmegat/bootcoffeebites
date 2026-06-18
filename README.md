# BŌOT Coffee & Bites — Deployment Guide

## Files in this package

| File | Purpose |
|---|---|
| `index.html` | Customer-facing storefront (rename from `boot_customer.html`) |
| `admin.html` | Admin panel for managing menu items |
| `supabase_setup.sql` | Run once in Supabase to create tables, policies, and seed data |

---

## Step 1: Create your Supabase project

1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Give it a name (e.g. `boot-coffee`) and set a strong DB password
3. Choose a region close to Malaysia (e.g. Singapore `ap-southeast-1`)
4. Wait ~2 minutes for the project to spin up

---

## Step 2: Run the database setup

1. In Supabase dashboard → **SQL Editor** → **New Query**
2. Paste the entire contents of `supabase_setup.sql`
3. Click **Run** — you should see your 7 products listed at the bottom

---

## Step 3: Create your admin user

1. Supabase dashboard → **Authentication** → **Users** → **Invite User**
2. Enter your email → click **Invite**
3. Check your email and set a password
4. This is the login you'll use at `admin.html`

---

## Step 4: Get your Supabase credentials

1. Supabase dashboard → **Settings** → **API**
2. Copy:
   - **Project URL** (looks like `https://xxxx.supabase.co`)
   - **anon public key** (long JWT string)

---

## Step 5: Add credentials to both HTML files

Open `index.html` and `admin.html` — near the top of each `<script>` block, replace:

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

with your actual values:

```javascript
const SUPABASE_URL = 'https://xxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## Step 6: Deploy to GitHub Pages

1. Create a new **public** GitHub repository (e.g. `bootcoffeebites`)
2. Upload `index.html` and `admin.html` to the repo root
3. Go to repo **Settings** → **Pages** → Source: **Deploy from branch** → `main` / `root`
4. Your store will be live at: `https://yourusername.github.io/bootcoffeebites/`
5. Admin panel: `https://yourusername.github.io/bootcoffeebites/admin.html`

---

## Using the Admin Panel

### Adding a new item
1. Go to `admin.html` → Sign in with your email/password
2. Click **Add Item** (top right)
3. Fill in name, category, price, description
4. Upload 1–5 photos (drag & drop or click to browse)
5. Click **Save Item** — it goes live immediately

### Editing / hiding an item
- Click **Edit** on any row to change details or swap images
- Click **Hide** to remove it from the customer menu (without deleting)
- Click **Show** to bring it back

### Adding your own product photos
- Upload real photos of your coffee and food in the admin panel
- Recommended size: 800×800px, under 2MB each
- First image = main photo shown on the store card

---

## Bugs fixed from original prototype

1. **Error box CSS conflict** — `hidden` + `flex` classes fight each other; fixed with a custom `.error-box.show` approach
2. **Double navigation on logo click** — `href="#"` + `onclick` both fired; replaced with a `<div onclick>` 
3. **Nav links were `<a>` tags** — caused page hash conflicts on mobile; converted to `<button>` elements
4. **No XSS protection** — product names/details rendered raw into innerHTML; added `escHtml()` sanitizer
5. **Broken `+` button in cart** — called `addToCart()` but didn't re-render the cart; fixed to call `renderPreorderCart()` too
6. **Form validation incomplete** — original only checked cart, not name/car/plate/time; all fields now validated before WhatsApp sends
7. **No fallback images** — broken image URLs showed broken icon; added `onerror` placeholder
8. **Products hardcoded in JS** — replaced with live Supabase fetch
9. **No loading/empty states** — added spinner while products load and empty state for filtered categories

---

## Supabase Storage note

Images uploaded via the admin panel go into the `product-images` bucket in Supabase Storage (free tier includes 1GB). The SQL script creates this bucket automatically. If you get a storage error, go to **Supabase → Storage → New Bucket** and create it manually with the name `product-images` set to **Public**.
