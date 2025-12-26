"use client";

import { useEffect, useState } from "react";
import Container from "./container";
import Image from "next/image";
import { Search, ShoppingCart, User, LogOut } from "lucide-react";
import Link from "next/link";
import { supabase } from "@/lib/supabase"; 
import { useRouter } from "next/navigation";

const Navbar = () => {
  const [user, setUser] = useState<any>(null);
  const [username, setUsername] = useState<string | null>(null); // State untuk nama asli
  const router = useRouter();

  // Fungsi untuk mengambil username dari tabel 'users'
  const fetchUsername = async (userId: string) => {
    const { data, error } = await supabase
      .from('users')
      .select('username')
      .eq('user_id', userId) // Menggunakan user_id sesuai struktur tabelmu
      .single();

    if (data) setUsername(data.username);
    if (error) console.error("Error fetching username:", error.message);
  };

  useEffect(() => {
    const checkUser = async () => {
      const { data } = await supabase.auth.getUser();
      if (data.user) {
        setUser(data.user);
        fetchUsername(data.user.id); // Tarik username jika ada user
      }
    };

    checkUser();

    const { data: authListener } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        const currentUser = session?.user ?? null;
        setUser(currentUser);
        
        if (currentUser) {
          fetchUsername(currentUser.id);
        } else {
          setUsername(null);
        }
      }
    );

    return () => {
      authListener.subscription.unsubscribe();
    };
  }, []);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    alert("Berhasil Logout");
    router.push("/");
    router.refresh();
  };

  return (
    <div className="shadow-sm bg-white sticky top-0 z-50">
      <Container className="flex flex-row h-20 py-1 items-center justify-between">
        <div className="h-full aspect-square relative">
          <Link href="/">
            <Image src="/AStar-Logo.webp" alt="Logo" width={72} height={72} className="cursor-pointer" />
          </Link>
        </div>

        <div className="flex gap-6 text-black items-center">
          <Search className="cursor-pointer hover:text-[#5B6EE1] transition-colors" size={20} />
          <div className="relative cursor-pointer group">
            <ShoppingCart size={20} className="group-hover:text-[#5B6EE1] transition-colors" />
            <span className="absolute -top-2 -right-2 bg-red-500 text-white text-[10px] w-4 h-4 rounded-full flex items-center justify-center">0</span>
          </div>

          {user ? (
            <div className="flex items-center gap-3 border-l pl-6 ml-2">
              {/* Stylish Username Badge */}
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-[#5B6EE1] flex items-center justify-center text-white text-xs font-bold shadow-sm">
                  {username ? username.charAt(0).toUpperCase() : "U"}
                </div>
                <div className="hidden md:flex flex-col">
                  <p className="text-sm font-bold text-[#1e293b] leading-tight italic">
                    @{username || "User"}
                  </p>
                </div>
              </div>

              <button 
                onClick={handleLogout}
                className="ml-2 p-2 rounded-full hover:bg-red-50 transition-all text-gray-400 hover:text-red-500"
                title="Logout"
              >
                <LogOut size={18} />
              </button>
            </div>
          ) : (
            <Link href="/register" className="flex items-center gap-2 group">
              <div className="p-2 rounded-full group-hover:bg-[#f0f4ff] transition-all">
                <User className="group-hover:text-[#5B6EE1] transition-colors" size={22} />
              </div>
            </Link>
          )}
        </div>
      </Container>
    </div>
  );
};

export default Navbar;