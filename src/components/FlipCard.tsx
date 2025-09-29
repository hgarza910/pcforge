"use client";

import { motion } from "framer-motion";
import { useState } from "react";
import Image from "next/image";

export type ForgedCardData = {
  id: string;
  title: string;
  tier: string;
  price: string;
  frontImage: string;
  backImage: string;
  qrHref: string;
  tags?: string[];
};

export default function FlipCard({ data }: { data: ForgedCardData }) {
  const [flipped, setFlipped] = useState(false);

  return (
    <div
      className="relative h-[440px] select-none"
      style={{ perspective: 1200 }}
      onClick={() => setFlipped((f) => !f)}
    >
      <motion.div
        className="relative h-full w-full rounded-2xl shadow-2xl"
        style={{ transformStyle: "preserve-3d" as any }}
        animate={{ rotateY: flipped ? 180 : 0 }}
        transition={{ type: "spring", stiffness: 260, damping: 22 }}
      >
        {/* FRONT */}
        <div className="absolute inset-0 rounded-2xl overflow-hidden border border-white/10 [backface-visibility:hidden]">
          <Image
            src={data.frontImage}
            alt={`${data.title} front`}
            fill
            priority={true}
            sizes="(max-width:768px) 90vw, 40vw"
            className="object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/10 to-transparent" />
          <div className="absolute left-4 bottom-4 space-y-1">
            <div className="text-sm uppercase tracking-widest text-white/70">{data.tier}</div>
            <div className="text-xl font-semibold">{data.title}</div>
            <div className="text-emerald-300 font-medium">{data.price}</div>
            {data.tags?.length ? (
              <div className="flex gap-2 pt-2">
                {data.tags.map((t) => (
                  <span key={t} className="text-[10px] px-2 py-1 rounded-full bg-white/10">
                    {t}
                  </span>
                ))}
              </div>
            ) : null}
          </div>
        </div>

        {/* BACK */}
        <div
          className="absolute inset-0 rounded-2xl overflow-hidden border border-white/10 [backface-visibility:hidden]"
          style={{ transform: "rotateY(180deg)" }}
        >
          <Image
            src={data.backImage}
            alt={`${data.title} back`}
            fill
            sizes="(max-width:768px) 90vw, 40vw"
            className="object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
          <div className="absolute left-4 bottom-4 flex items-center gap-3">
            <a
              href={data.qrHref}
              target="_blank"
              rel="noreferrer"
              className="rounded-lg bg-white/10 px-3 py-2 text-sm backdrop-blur hover:bg-white/20"
              onClick={(e) => e.stopPropagation()}
            >
              Open Build
            </a>
            <span className="text-xs text-white/60">flip to front ↻</span>
          </div>
        </div>
      </motion.div>
      <div className="pointer-events-none absolute -inset-px rounded-2xl ring-1 ring-white/10 shadow-[0_0_40px_-10px_rgba(255,255,255,0.25)]" />
    </div>
  );
}
