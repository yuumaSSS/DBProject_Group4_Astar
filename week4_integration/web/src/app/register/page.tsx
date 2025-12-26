"use client";

import React, { useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

interface RegisterPayload {
  email: string;
  password: string;
  username: string;
  full_name: string;
  phone_number: string;
  street: string;
  city: string;
  post_code: string;
}

export default function RegisterPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);

  const [formData, setFormData] = useState<RegisterPayload>({
    email: '',
    password: '',
    username: '',
    full_name: '',
    phone_number: '',
    street: '',
    city: '',
    post_code: '',
  });

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // 1. Validasi Keamanan
    if (isLoading) return; 
    if (formData.password.length < 6) {
      alert("Password minimal harus 6 karakter!");
      return;
    }

    setIsLoading(true);

    try {
      // TAHAP A: Daftarkan akun ke Supabase Auth
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: formData.email,
        password: formData.password,
      });

      if (authError) throw authError;

      if (authData.user) {
        // TAHAP B: Masukkan data profil ke tabel 'public.users'
        const { error: dbError } = await supabase
          .from('users') 
          .insert([
            {
              user_id: authData.user.id, 
              username: formData.username,
              full_name: formData.full_name,
              phone_number: formData.phone_number,
              street: formData.street,
              city: formData.city,
              post_code: formData.post_code,
              role: 'user' 
            },
          ]);

        if (dbError) {
          // JIKA DATABASE GAGAL: Kita punya masalah "Data Gantung"
          // Opsional: Kamu bisa membiarkannya, tapi untuk testing ini sering bikin pusing.
          console.error("Database Error:", dbError);
          throw new Error(dbError.message);
        }

        alert('Registrasi Berhasil! Silakan login.');
        router.push('/login');
      }
    } catch (error: any) {
      console.error("LOG DETAIL:", error);
      
      // Deteksi Error Duplikat (Username/Email sudah ada)
      if (error.message?.includes("unique constraint") || error.code === "23505") {
        alert("Gagal: Username atau Email sudah digunakan. Silakan gunakan yang lain.");
      } else {
        alert('Gagal mendaftar: ' + error.message);
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col pb-10 bg-white">
      {/* Header & Logo */}
      <div className="flex flex-col items-center pt-10">
        <Image src="/AStar-Logo.webp" alt="Logo" width={130} height={130} priority />
        <h1 className="text-xl md:text-2xl font-semibold italic text-[#1e293b]">Start Shopping With Us!</h1>
      </div>

      {/* Form Pendaftaran */}
      <form onSubmit={handleRegister} className="w-full max-w-[665px] mx-auto px-6 flex flex-col gap-3 pt-5">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-gray-700">Email Address</label>
            <input required type="email" placeholder="email@example.com" 
              className="px-4 py-3 bg-[#D6E1EC] outline-none rounded-sm text-black focus:ring-2 focus:ring-[#5B6EE1]"
              onChange={(e) => setFormData({...formData, email: e.target.value})} />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-gray-700">Username</label>
            <input required type="text" placeholder="dhimas_ghifari" 
              className="px-4 py-3 bg-[#D6E1EC] outline-none rounded-sm text-black focus:ring-2 focus:ring-[#5B6EE1]"
              onChange={(e) => setFormData({...formData, username: e.target.value})} />
          </div>
        </div>

        <label className="text-sm font-medium text-gray-700">Full Name</label>
        <input required type="text" placeholder="Dhimas Bahir Al Ghifari" 
          className="px-4 py-3 bg-[#D6E1EC] outline-none rounded-sm text-black focus:ring-2 focus:ring-[#5B6EE1]"
          onChange={(e) => setFormData({...formData, full_name: e.target.value})} />

        <label className="text-sm font-medium text-gray-700">Phone Number</label>
        <input required type="tel" placeholder="08123456789" 
          className="px-4 py-3 bg-[#D6E1EC] outline-none rounded-sm text-black focus:ring-2 focus:ring-[#5B6EE1]"
          onChange={(e) => setFormData({...formData, phone_number: e.target.value})} />

        <label className="text-sm font-medium text-gray-700">Street Address</label>
        <input required type="text" placeholder="Jl. Geografi No. 5" 
          className="px-4 py-3 bg-[#D6E1EC] outline-none rounded-sm text-black focus:ring-2 focus:ring-[#5B6EE1]"
          onChange={(e) => setFormData({...formData, street: e.target.value})} />

        <div className="grid grid-cols-2 gap-3">
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-gray-700">City</label>
            <input required type="text" placeholder="Sleman" 
              className="px-4 py-3 bg-[#D6E1EC] outline-none rounded-sm text-black focus:ring-2 focus:ring-[#5B6EE1]"
              onChange={(e) => setFormData({...formData, city: e.target.value})} />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-gray-700">Post Code</label>
            <input required type="text" placeholder="55281" 
              className="px-4 py-3 bg-[#D6E1EC] outline-none rounded-sm text-black focus:ring-2 focus:ring-[#5B6EE1]"
              onChange={(e) => setFormData({...formData, post_code: e.target.value})} />
          </div>
        </div>

        <label className="text-sm font-medium text-gray-700">Password</label>
        <input required type="password" placeholder="********" 
          className="px-4 py-3 bg-[#D6E1EC] outline-none rounded-sm text-black focus:ring-2 focus:ring-[#5B6EE1]"
          onChange={(e) => setFormData({...formData, password: e.target.value})} />

        <div className="flex flex-col md:flex-row justify-between items-center pt-5 gap-4">
          <p className="text-xs md:text-sm font-semibold text-gray-600">
            Already have an account?{' '}
            <Link href="/login">
              <span className="text-[#5B6EE1] hover:underline cursor-pointer">Sign In</span>
            </Link>
          </p>
          <button 
            type="submit"
            disabled={isLoading}
            className={`bg-[#5B6EE1] text-white px-10 py-3 font-semibold shadow-md hover:bg-[#4a5bc7] transition-all ${isLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            {isLoading ? 'REGISTERING...' : 'REGISTER'}
          </button>
        </div>
      </form>
    </div>
  );
}