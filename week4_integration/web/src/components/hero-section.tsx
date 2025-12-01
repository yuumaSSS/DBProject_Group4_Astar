import Image from "next/image";
import Container from "./container";

const HeroSection = () => {
  return (
    <div className="relative w-full">
      <Image
        src="/pixelart_grandopening.webp"
        alt="Hero Background"
        width={1920}
        height={1080}
        className="w-full h-auto"
        priority
      />
      <div className="absolute inset-0 flex items-end justify-center pb-12">
        <button className="bg-white text-black px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">
          Shop Now
        </button>
      </div>
    </div>
  );
};

export default HeroSection;