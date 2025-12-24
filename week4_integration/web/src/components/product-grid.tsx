"use client"

import Image from "next/image";
import { useState } from "react";
import PopUp from "./pop-up";

interface Product {
  productId: number;
  productName: string;
  productPrice: number;
  productImage: string;
  productStock: number;
  productCategory: string;
}

interface ProductGridProps {
  products: Product[];
}

const ProductGrid = ({ products }: ProductGridProps) => {
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

  return (
    <>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6">
        {products.map((product) => (
          <div
            key={product.productId}
            onClick={() => product.productStock > 0 && setSelectedProduct(product)}
            className={`flex flex-col gap-2 p-3 md:p-4 hover:shadow-lg transition-shadow rounded-lg relative ${product.productStock > 0 ? 'cursor-pointer' : 'cursor-not-allowed'}`}
          >
            <div className="relative aspect-5/7 w-full overflow-hidden rounded-lg bg-gray-100">
              <Image
                src={product.productImage}
                alt={product.productName}
                fill
                sizes="(max-width: 768px) 50vw, 25vw"
                className="object-cover"
              />
              {product.productStock === 0 && (
                <div className="absolute inset-0 bg-black/60 flex items-center justify-center">
                  <p className="text-white font-bold text-lg md:text-xl">OUT OF STOCK</p>
                </div>
              )}
            </div>
            <div className="">
              <h3 className="font-semibold text-sm md:text-base">
                {product.productName}
              </h3>
              <div className="text-xs md:text-sm text-white my-1">
                <p className="bg-[#5B6EE1] px-2 py-1 inline-block">{product.productCategory}</p>
              </div>
              <p className="font-bold text-sm md:text-base text-[#5B6EE1]">
                Rp {product.productPrice.toLocaleString("id-ID")}
              </p>
            </div>
          </div>
        ))}
      </div>

      {selectedProduct && (
        <PopUp product={selectedProduct} onClose={() => setSelectedProduct(null)} />
      )}
    </>
  );
};

export default ProductGrid;
