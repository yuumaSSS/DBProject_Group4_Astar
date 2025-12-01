"use client"

import Image from "next/image";
import { X } from "lucide-react";

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
  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white relative max-w-4xl w-full h-[600px] flex">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 z-10 hover:bg-gray-100 p-2 transition-colors"
        >
          <X size={24} />
        </button>

        {/* Left Section - Product Image */}
        <div className="relative w-1/2 h-full">
          <Image
            src={product.productImage}
            alt={product.productName}
            fill
            className="object-cover"
          />
        </div>

        {/* Right Section - Product Details */}
        <div className="w-1/2 p-8 flex flex-col justify-between">
          <div className="flex flex-col gap-1">
            <h2 className="text-3xl font-bold pb-2">{product.productName}</h2>
            <p className="text-2xl font-bold text-[#5B6EE1]">
              Rp {product.productPrice.toLocaleString("id-ID")}
            </p>
            <p className="text-lg">
              <span className="font-semibold">Available:</span> {product.productStock} items
            </p>
            <button className="bg-[#5B6EE1] text-white px-8 py-3 font-semibold hover:bg-[#4a5dd0] transition-colors w-full">
              Order Now
            </button>
          </div>

          {/* Bottom Right - Team Images */}
          <div className="flex gap-3 justify-end">
            <Image
              src="/thufail_1.webp"
              alt="Thufail"
              width={50}
              height={50}
              className="w-10 h-10 object-cover"
            />
            <Image
              src="/dhimas_1.webp"
              alt="Dhimas"
              width={50}
              height={50}
              className="w-10 h-10 object-cover"
            />
            <Image
              src="/faris_1.webp"
              alt="Faris"
              width={50}
              height={50}
              className="w-10 h-10 object-cover"
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default PopUp;
