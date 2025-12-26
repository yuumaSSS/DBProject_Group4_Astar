import Image from "next/image";
import Container from "./container";

const Footer = () => {
  return (
    <footer className="bg-fff py-6 md:py-8">
      <Container className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 md:gap-8">
        {/* Left Section */}
        <div className="flex flex-col gap-3 md:gap-4 w-full md:w-auto">
          <div className="flex items-center gap-2 md:gap-3">
            <Image
              src="/logo_footer.webp"
              alt="Logo"
              width={60}
              height={60}
              className="w-12 h-12 md:w-15 md:h-15 object-contain"
            />
            <h2 className="text-lg md:text-xl font-semibold">A*STAR</h2>
          </div>
          <p className="text-xs md:text-sm max-w-md">
            Bulaksumur, Jl. Geografi, Kec. Mlati, Kabupaten Sleman, Daerah
            Istimewa Yogyakarta 55281
          </p>
          <p className="text-xs md:text-sm">AStarShop@gmail.com</p>
        </div>

        {/* Right Section */}
        <div className="flex items-end gap-3 md:gap-4">
          <Image
            src="/thufail_1.webp"
            alt="Thufail"
            width={80}
            height={80}
            className="w-9 h-9 md:w-10 md:h-10 object-cover"
          />
          <Image
            src="/dhimas_1.webp"
            alt="Dhimas"
            width={80}
            height={80}
            className="w-9 h-9 md:w-10 md:h-10 object-cover"
          />
          <Image
            src="/faris.webp"
            alt="Faris"
            width={80}
            height={80}
            className="w-9 h-9 md:w-10 md:h-10 object-cover"
          />
        </div>
      </Container>
    </footer>
  );
};

export default Footer;
