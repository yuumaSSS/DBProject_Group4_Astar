import Image from "next/image";
import Link from "next/link";

export default function LoginPage() {
  return (
    <div className="min-h-screen flex flex-col">
      <div className="flex flex-col items-center pt-10">
        <Image
          src="/AStar-Logo.webp"
          alt="AStar Logo"
          width={130}
          height={130}
        />
        <h1 className="text-xl md:text-2xl lg:text-3xl font-semibold">
          Welcome Back! Let&apos;s Shop!
        </h1>

        <div className="w-full max-w-[665px] mx-auto px-6 md:px-0 mb-16 flex flex-col gap-3 pt-3 md:pt-0">
          <label className="text-sm md:text-base">Username</label>
          <input
            name="name"
            placeholder="Dhimas Bahir Al Ghifari"
            className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171]"
          />
          <label className="text-sm md:text-base">Password</label>
          <input
            name="password"
            type="password"
            placeholder="*********"
            className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
          />

          <div className="flex flex-col md:flex-row justify-between items-center pt-3">
            <p className="text-xs md:text-sm font-semibold mb-8 md:mb-0">
              <Link href="/login">
                <span className="text-[#5B6EE1]">Forgot Password?</span>
              </Link>
            </p>

            <Link href="/">
              <button className="bg-[#5B6EE1] text-white px-6 py-3 w-full md:w-auto">
                Sign in
              </button>
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}