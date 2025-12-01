import HeroSection from "@/components/hero-section";
import Navbar from "@/components/navbar";
import Footer from "@/components/footer";
import Collections from "@/components/collections";

export default function Home() {
  return (
    <>
      <Navbar />
      <HeroSection />
      <Collections />
      <Footer/>
    </>
  );
}
