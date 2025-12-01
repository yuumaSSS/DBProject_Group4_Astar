import Image from "next/image";
import Container from "./container";

const dummyProducts = [
  {
    productId: 1,
    productName: "Tufy Hoodie",
    productPrice: 350000,
    productImage: "/tufy_hoodie.webp",
    productStock: 25,
    productCategory: "Hoodie",
  },
  {
    productId: 2,
    productName: "Classic T-Shirt",
    productPrice: 150000,
    productImage: "/tufy_hoodie.webp",
    productStock: 50,
    productCategory: "T-Shirt",
  },
  {
    productId: 3,
    productName: "Premium Jacket",
    productPrice: 500000,
    productImage: "/tufy_hoodie.webp",
    productStock: 15,
    productCategory: "Jacket",
  },
  {
    productId: 4,
    productName: "Casual Pants",
    productPrice: 300000,
    productImage: "/tufy_hoodie.webp",
    productStock: 30,
    productCategory: "Pants",
  },
  {
    productId: 5,
    productName: "Sports Jacket",
    productPrice: 450000,
    productImage: "/tufy_hoodie.webp",
    productStock: 20,
    productCategory: "Jacket",
  },
  {
    productId: 6,
    productName: "Vintage Hoodie",
    productPrice: 380000,
    productImage: "/tufy_hoodie.webp",
    productStock: 18,
    productCategory: "Hoodie",
  },
  {
    productId: 7,
    productName: "Graphic Tee",
    productPrice: 180000,
    productImage: "/tufy_hoodie.webp",
    productStock: 40,
    productCategory: "T-Shirt",
  },
  {
    productId: 8,
    productName: "Denim Jacket",
    productPrice: 550000,
    productImage: "/tufy_hoodie.webp",
    productStock: 12,
    productCategory: "Jacket",
  },
];

const Collections = () => {
  return (
    <section className="py-12 md:py-16">
      <Container>
        <h2 className="text-3xl md:text-4xl font-bold text-center mb-8 md:mb-12">
          A*Star Collection
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6">
          {dummyProducts.map((product) => (
            <div
              key={product.productId}
              className="flex flex-col gap-2 p-3 md:p-4 hover:shadow-lg transition-shadow rounded-lg cursor-pointer"
            >
              <div className="relative aspect-5/7 w-full overflow-hidden rounded-lg bg-gray-100">
                <Image
                  src={product.productImage}
                  alt={product.productName}
                  fill
                  className="object-cover"
                />
              </div>
              <div className="">
                <h3 className="font-semibold text-sm md:text-base line-clamp-1">
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
      </Container>
    </section>
  );
};

export default Collections;
