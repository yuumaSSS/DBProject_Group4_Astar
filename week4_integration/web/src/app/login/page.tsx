"use client";

import React, { useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase'; 

export default function LoginPage() {
  const router = useRouter();
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      // 1. Login ke Supabase Auth (Menggunakan email & password)
      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email: email,
        password: password,
      });

      if (authError) throw authError;

      if (data.user) {
        // 2. Ambil Role dari tabel 'users' milikmu (Bukan profiles)
        // Saya sesuaikan kolomnya dengan referensi Flutter kamu: 'user_id'
        const { data: userData, error: userError } = await supabase
          .from('users') 
          .select('role')
          .eq('user_id', data.user.id) // Di tabel 'users', kolomnya biasanya user_id atau id
          .single();

        if (userError) {
          console.error("Error fetching user data:", userError);
          // Jika data di tabel users belum ada, kita tetap izinkan login tapi peringatkan
          alert("Login Auth berhasil, tapi data di tabel 'users' tidak ditemukan.");
        }

        // 3. Logika Role (Opsional: Aktifkan jika ingin proteksi Admin)
        /* if (userData?.role !== 'admin') {
           console.log("User ini bukan admin, tapi tetap bisa masuk sebagai customer");
        } 
        */

        alert("Login Berhasil!");
        router.push('/'); 
        router.refresh();
      }
    } catch (error: any) {
      alert("Login Gagal: " + (error.message || "Periksa kembali email/password"));
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col">
      <div className="flex flex-col items-center pt-10">
        <Image src="/AStar-Logo.webp" alt="AStar Logo" width={130} height={130} />
        <h1 className="text-xl md:text-2xl lg:text-3xl font-semibold">
          Welcome Back! Let&apos;s Shop!
        </h1>
      </div>

      <form onSubmit={handleSignIn} className="w-full max-w-[665px] mx-auto px-6 md:px-0 mb-16 flex flex-col gap-3 pt-6">
        <label className="text-sm md:text-base">Email Address</label>
        <input
          required
          type="email"
          placeholder="email@example.com"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171] outline-none"
        />

        <label className="text-sm md:text-base">Password</label>
        <input
          required
          type="password"
          placeholder="*********"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] outline-none"
        />

        <div className="flex flex-col md:flex-row justify-between items-center pt-5 gap-4">
          <p className="text-xs md:text-sm font-semibold mb-3 md:mb-0">
            Don&apos;t have an account?{' '}
            <Link href="/register">
              <span className="text-[#5B6EE1] hover:underline">Sign Up</span>
            </Link>
          </p>

          <button 
            type="submit"
            disabled={isLoading}
            className={`bg-[#5B6EE1] text-white px-10 py-3 w-full md:w-auto font-semibold ${isLoading ? 'opacity-50' : ''}`}
          >
            {isLoading ? 'SIGNING IN...' : 'SIGN IN'}
          </button>
        </div>
      </form>
    </div>
  );
}