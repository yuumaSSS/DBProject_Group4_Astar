"use client"; // Wajib agar bisa interaktif

import React, { useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase'; // Jembatan yang kita buat tadi

export default function RegisterPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  // 1. Kantong data (State) untuk menampung semua input
  const [formData, setFormData] = useState({
    email: '',
    username: '',
    phone: '',
    street: '',
    city: '',
    postal: '',
    password: '',
    confirmPassword: '',
  });

  // 2. Fungsi untuk mencatat ketikan user
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  // 3. Fungsi Utama: Kirim ke Database
  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Validasi sederhana
    if (formData.password !== formData.confirmPassword) {
      alert("Password dan Konfirmasi Password tidak cocok!");
      setLoading(false);
      return;
    }

    // TAHAP A: Daftarkan ke Supabase Auth (Email & Password)
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: formData.email,
      password: formData.password,
    });

    if (authError) {
      alert("Error Auth: " + authError.message);
      setLoading(false);
      return;
    }

    // TAHAP B: Simpan detail profil ke tabel 'profiles' di PostgreSQL
    if (authData.user) {
      const { error: dbError } = await supabase
        .from('profiles')
        .insert([
          {
            id: authData.user.id, // ID yang sama dengan Auth
            username: formData.username,
            phone_number: formData.phone,
            street: formData.street,
            city: formData.city,
            postal_code: formData.postal,
          },
        ]);

      if (dbError) {
        alert("Error Database: " + dbError.message);
      } else {
        alert("Registrasi Berhasil! Silakan Login.");
        router.push('/login');
      }
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex flex-col">
      <div className="flex flex-col items-center pt-10">
        <Image src="/AStar-Logo.webp" alt="AStar Logo" width={130} height={130} />
        <h1 className="text-xl md:text-2xl lg:text-3xl font-semibold">
          Start Shopping With Us!
        </h1>
      </div>

      {/* Gunakan tag <form> agar tombol Register berfungsi otomatis */}
      <form onSubmit={handleRegister} className="w-full max-w-[665px] mx-auto px-6 md:px-0 mb-16 flex flex-col gap-3 pt-3 md:pt-0">
        
        {/* TAMBAHAN: Input Email (Wajib untuk Supabase) */}
        <label className="text-sm md:text-base">Email Address</label>
        <input
          required
          name="email"
          type="email"
          placeholder="yourname@example.com"
          value={formData.email}
          onChange={handleChange}
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171]"
        />

        <label className="text-sm md:text-base">Username</label>
        <input
          name="username"
          placeholder="Dhimas Bahir Al Ghifari"
          value={formData.username}
          onChange={handleChange}
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171]"
        />

        <label className="text-sm md:text-base">Phone Number</label>
        <input
          name="phone"
          type="tel"
          placeholder="+XX XX XXXX XXXX"
          value={formData.phone}
          onChange={handleChange}
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171]"
        />

        <label className="text-sm md:text-base">Street</label>
        <input
          name="street"
          type="text"
          placeholder="Pogung Street"
          value={formData.street}
          onChange={handleChange}
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171]"
        />

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-5">
          <div>
            <label className="text-sm md:text-base">City</label>
            <input
              name="city"
              type="text"
              placeholder="Yogyakarta"
              value={formData.city}
              onChange={handleChange}
              className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
            />
          </div>

          <div>
            <label className="text-sm md:text-base">Postal Code</label>
            <input
              name="postal"
              type="text"
              placeholder="55555"
              value={formData.postal}
              onChange={handleChange}
              className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
            />
          </div>
        </div>

        <label className="text-sm md:text-base">Password</label>
        <input
          name="password"
          type="password"
          placeholder="*********"
          value={formData.password}
          onChange={handleChange}
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
        />

        <label className="text-sm md:text-base">Confirm Password</label>
        <input
          name="confirmPassword"
          type="password"
          placeholder="*********"
          value={formData.confirmPassword}
          onChange={handleChange}
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
        />

        <div className="flex flex-col md:flex-row justify-between items-center pt-5">
          <p className="text-xs md:text-sm font-semibold mb-3 md:mb-0">
            Already Have An Account?{' '}
            <Link href="/login">
              <span className="text-[#5B6EE1]">Sign In</span>
            </Link>
          </p>

          <button 
            type="submit" 
            disabled={loading}
            className="bg-[#5B6EE1] text-white px-6 py-3 w-full md:w-auto hover:bg-[#4a5bc7] disabled:bg-gray-400"
          >
            {loading ? "Registering..." : "Register"}
          </button>
        </div>
      </form>
    </div>
  );
}