"use client"; // Wajib karena kita akan memantau status login secara real-time

import { useEffect, useState } from "react";
import Container from "./container";
import Image from "next/image";
import { Search, ShoppingCart, User, LogOut } from "lucide-react";
import Link from "next/link";
import { supabase } from "@/lib/supabase"; // Import kabel koneksi kita
import { useRouter } from "next/navigation";

const Navbar = () => {
  const [user, setUser] = useState<any>(null);
  const router = useRouter();

  useEffect(() => {
    // 1. Cek status user saat pertama kali navbar muncul
    const checkUser = async () => {
      const { data } = await supabase.auth.getUser();
      setUser(data.user);
    };

    checkUser();

    // 2. Pantau perubahan status (Login/Logout) secara otomatis
    const { data: authListener } = supabase.auth.onAuthStateChange(
      (event, session) => {
        setUser(session?.user ?? null);
      }
    );

    return () => {
      authListener.subscription.unsubscribe();
    };
  }, []);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    alert("Berhasil Logout");
    router.push("/"); // Balik ke home
    router.refresh(); // Segarkan data
  };

  return (
    <div className="shadow-sm">
      <Container className="flex flex-row h-20 py-1 items-center justify-between">
        <div className="h-full aspect-square relative">
          <Link href="/">
            <Image src="/AStar-Logo.webp" alt="Logo" width={72} height={72} className="cursor-pointer" />
          </Link>
        </div>

        <div className="flex gap-8 text-black items-center">
          <Search className="cursor-pointer" />
          <ShoppingCart className="cursor-pointer" />

          {/* Logika Dinamis: Jika sudah login tampilkan Logout, jika belum tampilkan Link Register */}
          {user ? (
            <div className="flex items-center gap-4">
              <span className="text-xs font-bold bg-[#5B6EE1] text-white px-2 py-1 rounded">
                USER
              </span>
              <button 
                onClick={handleLogout}
                className="hover:text-red-500 transition-colors"
                title="Logout"
              >
                <LogOut size={22} />
              </button>
            </div>
          ) : (
            <Link href="/register" title="Login / Register">
              <User className="hover:text-[#5B6EE1] transition-colors" />
            </Link>
          )}
        </div>
      </Container>
    </div>
  );
};

export default Navbar;