import Container from "./container";
import ProductGrid from "./product-grid";
import { getProducts } from "@/lib/fetch-product";

const dummyProducts = [
  {
    productId: 1,
    productName: "Tufy Hoodie",
    productPrice: 350000,
    productImage: "/tufy_hoodie.webp",
    productStock: 2,
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
    productStock: 0,
    productCategory: "Jacket",
  },
];

const Collections = async () => {
  let products = dummyProducts;

  try {
    const apiProducts = await getProducts();
    
    // Map API data to our product format
    products = apiProducts.map((item) => ({
      productId: item.product_id,
      productName: item.product_name,
      productPrice: item.unit_price,
      productImage: item.image_url || "/tufy_hoodie.webp",
      productStock: item.stock,
      productCategory: item.category || "Uncategorized",
    }));
  } catch (error) {
    console.error("Failed to fetch products, using dummy data:", error);
    // products akan tetap menggunakan dummyProducts
  }

  // Sort products: in-stock first, out-of-stock last
  const sortedProducts = [...products].sort((a, b) => {
    if (a.productStock === 0 && b.productStock > 0) return 1;
    if (a.productStock > 0 && b.productStock === 0) return -1;
    return 0;
  });

  return (
    <section id="collections" className="py-12 md:py-16">
      <Container>
        <h2 className="text-3xl md:text-4xl font-bold text-center mb-8 md:mb-12">
          A*Star Collection
        </h2>
        <ProductGrid products={sortedProducts} />
      </Container>
    </section>
  );
};

export default Collections;
