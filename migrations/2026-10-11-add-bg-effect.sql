-- Tambah setting aurora ke app_settings
-- Jalankan sekali saja

INSERT INTO app_settings (key, value, updatedAt)
VALUES 
  ('bg_effect', 'aurora', now()::text),
  ('bg_effect_intensity', '1.0', now()::text)
ON CONFLICT (key) DO NOTHING;
