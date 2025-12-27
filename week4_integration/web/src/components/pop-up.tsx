"use client";

import Image from "next/image";
import { X } from "lucide-react";
import { supabase } from "@/lib/supabase";
import { useRouter } from "next/navigation"; // Import router

interface Product {
  productId: number;
  productName: string;
  productPrice: number;
  productImage: string;
  productStock: number;
  productCategory: string;
}

interface PopUpProps {
  product: Product;
  onClose: () => void;
}

const PopUp = ({ product, onClose }: PopUpProps) => {
  const router = useRouter(); // Inisialisasi router

  const handleOrderNow = async () => {
    try {
      // 1. Cek status login user
      const { data: { user } } = await supabase.auth.getUser();
      
      // 2. PROTEKSI: Jika tidak ada user, arahkan ke register
      if (!user) {
        alert("You must have an account to place an order!");
        router.push("/register");
        return; // Hentikan fungsi agar tidak lanjut ke WhatsApp
      }

      // 3. Jika user login, tarik data alamat lengkap dari tabel 'users'
      let addressInfo = "";
      const { data: profile } = await supabase
        .from('users')
        .select('full_name, phone_number, street, city, post_code')
        .eq('user_id', user.id)
        .single();

      if (profile) {
        addressInfo = `
*--- DATA PENGIRIMAN ---*
*User ID :*
${user.id}

*Nama:* ${profile.full_name}
*No. HP:* ${profile.phone_number}
*Alamat:* ${profile.street}
*Kota:* ${profile.city}
*Kode Pos:* ${profile.post_code}
*----------------------*`;
      }

      // 4. Susun pesan WhatsApp
      const phoneNumber = "6281357135429";
      const message = `Hai admin saya ingin order:
*Produk:* ${product.productName} 
*ID:* ${product.productId}
*Harga:* Rp ${product.productPrice.toLocaleString("id-ID")}
${addressInfo}

Mohon pesanan saya diproses ya, terima kasih!`;

      const encodedMessage = encodeURIComponent(message);
      const whatsappUrl = `https://wa.me/${phoneNumber}?text=${encodedMessage}`;
      
      window.open(whatsappUrl, '_blank');
    } catch (error) {
      console.error("Gagal memproses order:", error);
      alert("Terjadi kesalahan teknis. Silakan coba lagi.");
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white relative max-w-4xl w-full md:h-[600px] max-h-[90vh] flex flex-col md:flex-row overflow-auto">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-2 right-2 md:top-4 md:right-4 z-10 hover:bg-gray-100 p-2 transition-colors bg-white/80"
        >
          <X size={20} className="md:w-6 md:h-6" />
        </button>

        {/* Left Section - Product Image */}
        <div className="relative w-full md:w-1/2 h-[300px] md:h-full shrink-0">
          <Image
            src={product.productImage}
            alt={product.productName}
            fill
            className="object-cover"
          />
        </div>

        {/* Right Section - Product Details */}
        <div className="w-full md:w-1/2 p-4 md:p-8 flex flex-col justify-between">
          <div className="flex flex-col gap-3 md:gap-1">
            <h2 className="text-xl md:text-3xl font-bold pb-1 md:pb-2">{product.productName}</h2>
            <p className="text-xl md:text-2xl font-bold text-[#5B6EE1]">
              Rp {product.productPrice.toLocaleString("id-ID")}
            </p>
            <p className="text-base md:text-lg">
              <span className="font-semibold">Available:</span> {product.productStock} items
            </p>
            <button 
              onClick={handleOrderNow}
              className="bg-[#5B6EE1] text-white px-6 md:px-8 py-2 md:py-3 font-semibold hover:bg-[#4a5dd0] transition-colors w-full mt-2"
            >
              Order Now
            </button>
          </div>

          {/* Bottom Right - Team Images */}
          <div className="flex gap-2 md:gap-3 justify-end mt-4 md:mt-0">
            <Image
              src="/thufail_1.webp"
              alt="Thufail"
              width={50}
              height={50}
              className="w-8 h-8 md:w-10 md:h-10 object-cover rounded"
            />
            <Image
              src="/dhimas_1.webp"
              alt="Dhimas"
              width={50}
              height={50}
              className="w-8 h-8 md:w-10 md:h-10 object-cover rounded"
            />
            <Image
              src="/faris_1.webp"
              alt="Faris"
              width={50}
              height={50}
              className="w-8 h-8 md:w-10 md:h-10 object-cover rounded"
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default PopUp;