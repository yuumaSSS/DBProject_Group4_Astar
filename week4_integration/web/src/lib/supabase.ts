import { createBrowserClient } from '@supabase/ssr'

// Fungsi ini adalah "Alat" untuk menghubungkan aplikasi ke Supabase
export const createClient = () =>
  createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )

// Kita buat satu instance 'supabase' yang bisa langsung dipakai di komponen
export const supabase = createClient()