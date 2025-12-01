import HeroSection from "@/components/hero-section";
import Navbar from "@/components/navbar";
import Footer from "@/components/footer";

export default function Home() {
  return (
    <>
      <Navbar />
      <HeroSection />
      <div className="flex min-h-screen items-center justify-center bg-zinc-50 font-sans ">
        <p> HI</p>
      </div>
      <Footer/>
    </>
  );
}
