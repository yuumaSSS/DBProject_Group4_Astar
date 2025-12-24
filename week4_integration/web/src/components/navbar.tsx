import Container from "./container";
import Image from "next/image";
import { Search, ShoppingCart, User } from "lucide-react";

const Navbar = () => {
  return (
    <div className="shadow-sm">
      <Container className="flex flex-row h-20 py-1 items-center justify-between">
        <div className="h-full aspect-square relative">
          <Image src="/AStar-Logo.webp" alt="Logo" width={72} height={72} />
        </div>
        <div className="flex gap-8 text-black">
          <Search />
          <ShoppingCart />
          <User />
        </div>
      </Container>
    </div>
  );
};

export default Navbar;
