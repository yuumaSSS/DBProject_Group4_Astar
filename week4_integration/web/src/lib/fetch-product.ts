export interface Product {
  product_id: number;
  product_name: string;
  unit_price: number;
  image_url?: string;
  stock: number;
  category?: string;
}

export interface ProductsResponse {
  success?: boolean;
  data?: Product[];
  message?: string;
}

const API_BASE_URL = "https://backend-astar.vercel.app/api";

export async function getProducts(): Promise<Product[]> {
  try {
    const response = await fetch(`${API_BASE_URL}/products`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
      cache: "no-store", // Always fetch fresh data
    });

    if (!response.ok) {
      console.error(`HTTP error! status: ${response.status}`);
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    
    // Check if result is directly an array
    if (Array.isArray(result)) {
      return result;
    }
    
    // Check if result has data property
    if (result.data && Array.isArray(result.data)) {
      return result.data;
    }

    // Check if result has success field and data
    if (result.success && result.data) {
      return result.data;
    }

    console.error("Unexpected API response format:", result);
    throw new Error("Unexpected API response format");
  } catch (error) {
    console.error("Error fetching products:", error);
    throw error;
  }
}

export async function getProductById(productId: number): Promise<Product | null> {
  try {
    const products = await getProducts();
    return products.find((p) => p.product_id === productId) || null;
  } catch (error) {
    console.error(`Error fetching product ${productId}:`, error);
    throw error;
  }
}
