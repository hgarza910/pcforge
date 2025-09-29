"use client";

import { useMemo } from "react";
import Carousel from "@/components/Carousel";
import FlipCard, { ForgedCardData } from "@/components/FlipCard";

const CARDS: ForgedCardData[] = [
  {
    id: "emberstrike-01",
    title: "EMBERSTRIKE",
    tier: "High-End",
    price: "$2,199",
    frontImage: "/cards/emberstrike-front.jpg",
    backImage: "/cards/emberstrike-back.jpg",
    qrHref: "https://your-short.link/emberstrike",
    tags: ["4K", "RGB", "AM5"],
  },
  {
    id: "frostcore-02",
    title: "FROSTCORE",
    tier: "Balanced",
    price: "$1,299",
    frontImage: "/cards/frostcore-front.jpg",
    backImage: "/cards/frostcore-back.jpg",
    qrHref: "https://your-short.link/frostcore",
    tags: ["1440p", "Quiet", "Intel"],
  },
  {
    id: "bang4buck-03",
    title: "BANG 4 BUCK",
    tier: "Value",
    price: "$899",
    frontImage: "/cards/value-front.jpg",
    backImage: "/cards/value-back.jpg",
    qrHref: "https://your-short.link/value",
    tags: ["1080p+", "Compact", "No-RGB"],
  },
];

export default function Page() {
  const slides = useMemo(
    () =>
      CARDS.map((c) => (
        <div key={c.id} className="px-3 shrink-0 basis-[85%] md:basis-[58%] lg:basis-[44%]">
          <FlipCard data={c} />
        </div>
      )),
    []
  );

  return (
    <main className="relative mx-auto max-w-7xl px-4 py-10">
      <header className="mb-6">
        <h1 className="text-2xl md:text-3xl font-semibold tracking-wide">Forged Preview</h1>
        <p className="text-white/70">Swipe. Flip. Tell us what you think.</p>
      </header>

      <Carousel>{slides}</Carousel>

      <footer className="mt-10 text-center text-xs text-white/50">🔥 forging soon</footer>
    </main>
  );
}
