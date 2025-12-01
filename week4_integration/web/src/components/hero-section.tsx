import Image from "next/image";
import Container from "./container";

const HeroSection = () => {
  return (
    <div className="relative w-full h-[400px] md:h-auto">
      <Image
        src="/pixelart_grandopening.webp"
        alt="Hero Background"
        width={1920}
        height={1080}
        className="hidden md:block w-full h-auto"
        priority
      />
      <Image
        src="/pixelart_grandopening.webp"
        alt="Hero Background"
        fill
        className="md:hidden object-cover"
        priority
      />
      <div className="absolute inset-0 flex items-end justify-center pb-6 md:pb-12">
        <button className="hover:scale-110 transition-transform border-0 bg-transparent p-0 cursor-pointer">
          <Image
            src="/shop_button.webp"
            alt="Shop Now"
            width={400}
            height={120}
            className="w-40 md:w-70"
          />
        </button>
      </div>
    </div>
  );
};

export default HeroSection;