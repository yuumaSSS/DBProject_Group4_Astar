import React from 'react';
import Image from 'next/image';
import Link from 'next/link';

export default function RegisterPage() {
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
          Start Shopping With Us!
        </h1>
      </div>

      <div className="w-full max-w-[665px] mx-auto px-6 md:px-0 mb-16 flex flex-col gap-3 pt-3 md:pt-0">
        <label className="text-sm md:text-base">Username</label>
        <input
          name="name"
          placeholder="Dhimas Bahir Al Ghifari"
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171]"
        />

        <label className="text-sm md:text-base">Phone Number</label>
        <input
          name="phone"
          type="tel"
          placeholder="+XX XX XXXX XXXX"
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171]"
        />

        <label className="text-sm md:text-base">Street</label>
        <input
          name="street"
          type="text"
          placeholder="Pogung Street"
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC] placeholder:text-[#747171]"
        />

        {/* CITY + POSTAL → always 1 column on mobile, 2 columns on >= md */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-5">
          <div>
            <label className="text-sm md:text-base">City</label>
            <input
              name="city"
              type="text"
              placeholder="Yogyakarta"
              className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
            />
          </div>

          <div>
            <label className="text-sm md:text-base">Postal Code</label>
            <input
              name="postal"
              type="text"
              placeholder="55555"
              className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
            />
          </div>
        </div>

        <label className="text-sm md:text-base">Password</label>
        <input
          name="password"
          type="password"
          placeholder="*********"
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
        />

        <label className="text-sm md:text-base">Confirm Password</label>
        <input
          name="confirmPassword"
          type="password"
          placeholder="*********"
          className="text-sm md:text-base w-full px-4 py-3 bg-[#D6E1EC]"
        />

        <div className="flex flex-col md:flex-row justify-between items-center pt-5">
          <p className="text-xs md:text-sm font-semibold mb-3 md:mb-0">
            Already Have An Account?{' '}
            <Link href="/login">
              <span className="text-[#5B6EE1]">Sign In</span>
            </Link>
          </p>

          <Link href="/login">
            <button className="bg-[#5B6EE1] text-white px-6 py-3 w-full md:w-auto">
              Register
            </button>
          </Link>
        </div>
      </div>
    </div>
  );
}
