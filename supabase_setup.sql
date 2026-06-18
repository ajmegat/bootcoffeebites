-- ============================================================
-- BŌOT Coffee & Bites — Supabase Database Setup
-- Run this entire file in your Supabase SQL Editor
-- (Dashboard → SQL Editor → New Query → paste → Run)
-- ============================================================


-- 1. PRODUCTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    category    TEXT NOT NULL CHECK (category IN ('combos', 'coffee', 'breakfast')),
    price       NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    badge       TEXT,
    details     TEXT,
    images      TEXT[] DEFAULT '{}',   -- array of public image URLs
    image_url   TEXT,                  -- first image shortcut
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order  INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);

-- Auto-update updated_at on every row change
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at ON products;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();


-- 2. ROW LEVEL SECURITY (RLS)
-- ============================================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Public (customers): can only read available products
CREATE POLICY "Public can read available products"
  ON products FOR SELECT
  USING (is_available = TRUE);

-- Authenticated admin: full access
CREATE POLICY "Authenticated users have full access"
  ON products FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');


-- 3. STORAGE BUCKET
-- ============================================================
-- Run this in the SQL Editor to create the storage bucket
-- (or create it manually: Storage → New Bucket → "product-images" → Public)
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Allow public to read images
CREATE POLICY "Public can view product images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');

-- Allow authenticated users to upload/delete images
CREATE POLICY "Auth users can upload product images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'product-images' AND auth.role() = 'authenticated');

CREATE POLICY "Auth users can delete product images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'product-images' AND auth.role() = 'authenticated');


-- 4. SEED DATA (your original menu items)
-- ============================================================
-- Delete existing seed if re-running
DELETE FROM products;

INSERT INTO products (name, category, price, badge, details, images, image_url, is_available, sort_order) VALUES
(
    'The Early Bird Fuel Set', 'combos', 9.00, 'Best Seller',
    '1x Freshly brewed rich Local Kopi Kampung (Hot) paired with 1x classic Nasi Lemak Bungkus with egg and fragrant spicy sambal.',
    ARRAY[
        'https://images.unsplash.com/photo-1579888944880-d98341148733?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1630514971083-057022c0ff88?q=80&w=600&auto=format&fit=crop'
    ],
    'https://images.unsplash.com/photo-1579888944880-d98341148733?q=80&w=600&auto=format&fit=crop',
    TRUE, 1
),
(
    'Premium Corporate Kick', 'combos', 12.00, 'Premium Pick',
    '1x Pre-bottled Premium Cold Brew Latte (made with fine Arabica blend) paired with 1x crispy, buttery French Croissant.',
    ARRAY[
        'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=600&auto=format&fit=crop'
    ],
    'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=600&auto=format&fit=crop',
    TRUE, 2
),
(
    'Arabica Bottled Cold Brew (White)', 'coffee', 8.00, 'Pre-Chilled',
    'Our signature smooth, low-acidity 12-hour steeped cold brew blended with rich, creamy full-cream milk. Handed over cold.',
    ARRAY[
        'https://images.unsplash.com/photo-1553909489-cd47e0907980?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1513530534585-c7b1394c6d51?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507133750040-4a8f57021571?q=80&w=600&auto=format&fit=crop'
    ],
    'https://images.unsplash.com/photo-1553909489-cd47e0907980?q=80&w=600&auto=format&fit=crop',
    TRUE, 3
),
(
    'Arabica Bottled Cold Brew (Black)', 'coffee', 7.00, 'Zero Sugar',
    'Pure, clean 12-hour steeped Arabica cold brew. Bold caffeine hit, smooth chocolatey notes, and strictly zero sugar.',
    ARRAY[
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1498804103079-a6351b050096?q=80&w=600&auto=format&fit=crop'
    ],
    'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=600&auto=format&fit=crop',
    TRUE, 4
),
(
    'Hot Filtered Kopi Kampung', 'coffee', 4.00, 'Classic Heat',
    'Sweet, bold local robusta coffee with condensed milk, steeped long in traditional cloth filters and stored in high-performance thermoses.',
    ARRAY[
        'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=600&auto=format&fit=crop'
    ],
    'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=600&auto=format&fit=crop',
    TRUE, 5
),
(
    'Classic Nasi Lemak Bungkus', 'breakfast', 4.00, 'Fresh Daily',
    'Fragrant coconut-steamed rice, signature slow-cooked spicy sambal, crunchy peanuts, anchovies, and a boiled egg slice in traditional packing.',
    ARRAY[
        'https://images.unsplash.com/photo-1630514971083-057022c0ff88?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1626132647523-66f5bf380027?q=80&w=600&auto=format&fit=crop'
    ],
    'https://images.unsplash.com/photo-1630514971083-057022c0ff88?q=80&w=600&auto=format&fit=crop',
    TRUE, 6
),
(
    'Flaky Butter Croissant', 'breakfast', 5.00, 'Freshly Baked',
    'Gently warmed, flaky artisanal French croissants sourced fresh from a local artisan bakery each morning.',
    ARRAY[
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=600&auto=format&fit=crop'
    ],
    'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=600&auto=format&fit=crop',
    TRUE, 7
);

-- Verify everything looks good
SELECT id, name, category, price, is_available, sort_order, array_length(images, 1) as image_count
FROM products
ORDER BY sort_order;
