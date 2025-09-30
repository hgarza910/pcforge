"use client";

if (typeof window !== "undefined") {
  const p = new URLSearchParams(window.location.search);
  ["utm_source","utm_medium","utm_campaign","utm_content","utm_term"].forEach((k)=>{
    const v = p.get(k);
    if (v) localStorage.setItem(k, v);
  });
}

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
              <div
                  key={c.id}
                  className="
            px-2 sm:px-3
            shrink-0
            basis-[88%] xs:basis-[80%] sm:basis-[66%] md:basis-[56%] lg:basis-[44%]
          "
              >
                <FlipCard data={c} />
              </div>
          )),
      []
  );

  return (
      <main
          className="
        relative mx-auto
        w-full max-w-screen-lg
        px-3 sm:px-4
        pt-6 sm:pt-8 pb-10
        pb-[max(2rem,env(safe-area-inset-bottom))]
      "
      >
        <header className="mb-6 text-center sm:text-left">
          <h1 className="font-semibold tracking-wide text-[clamp(1.25rem,2.5vw,1.75rem)]">
            Forged Preview
          </h1>
          <p className="text-white/70 text-sm sm:text-base">
            Swipe. Flip. Tell us what you think.
          </p>
        </header>

        <section aria-label="Forged cards carousel" className="mx-auto max-w-3xl sm:max-w-none">
          <Carousel>{slides}</Carousel>
        </section>

        <footer className="mt-10 text-center text-xs text-white/50">
          🔥 forging soon
        </footer>
      </main>
  );
}
