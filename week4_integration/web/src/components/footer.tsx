import Image from "next/image";
import Container from "./container";

const Footer = () => {
  return (
    <footer className="bg-fff py-8">
      <Container className="flex flex-col md:flex-row justify-between gap-8">
        {/* Left Section */}
        <div className="flex flex-col gap-4">
          <div className="flex items-center gap-3">
            <Image
              src="/logo_footer.webp"
              alt="Logo"
              width={60}
              height={60}
              className="w-auto h-auto"
            />
            <h2 className="text-xl">A*STAR</h2>
          </div>
          <p className="text-sm max-w-md">
            Bulaksumur, Jl. Geografi, Kec. Mlati, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281
          </p>
          <p className="text-sm">
            AStarShop@gmail.com
          </p>
        </div>

        {/* Right Section */}
        <div className="flex items-end gap-4">
          <Image
            src="/thufail_1.webp"
            alt="Thufail"
            width={80}
            height={80}
            className="w-10 h-10 object-cover"
          />
          <Image
            src="/dhimas_1.webp"
            alt="Dhimas"
            width={80}
            height={80}
            className="w-10 h-10 object-cover"
          />
          <Image
            src="/faris_1.webp"
            alt="Faris"
            width={80}
            height={80}
            className="w-10 h-10 object-cover"
          />
        </div>
      </Container>
    </footer>
  );
};

export default Footer;