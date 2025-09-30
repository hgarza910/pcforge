"use client";

import { useState, useCallback, type CSSProperties } from "react";
import { motion, type Transition } from "framer-motion";
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

type FlipCardProps = {
  data: ForgedCardData;
  /** Optional: start in flipped state */
  defaultFlipped?: boolean;
};

const preserve3d: CSSProperties = { transformStyle: "preserve-3d" };
const perspective: CSSProperties = { perspective: 1200 };

const flipSpring: Transition = { type: "spring", stiffness: 260, damping: 22 };

export default function FlipCard({ data, defaultFlipped = false }: FlipCardProps) {
  const [flipped, setFlipped] = useState<boolean>(defaultFlipped);

  const toggle = useCallback(() => setFlipped((f) => !f), []);

  const onKeyDown = useCallback(
      (e: React.KeyboardEvent<HTMLDivElement>) => {
        // Space / Enter toggles
        if (e.key === " " || e.key === "Enter") {
          e.preventDefault();
          toggle();
        }
        // Escape always returns to front
        if (e.key === "Escape") setFlipped(false);
      },
      [toggle]
  );

  return (
      <div
          className="relative h-[440px] select-none"
          style={perspective}
          onClick={toggle}
          onKeyDown={onKeyDown}
          role="button"
          tabIndex={0}
          aria-pressed={flipped}
          aria-label={`${data.title} card; ${flipped ? "back" : "front"} shown. Press Enter or Space to flip.`}
      >
        <motion.div
            className="relative h-full w-full rounded-2xl shadow-2xl"
            style={preserve3d}
            animate={{ rotateY: flipped ? 180 : 0 }}
            transition={flipSpring}
        >
          {/* FRONT */}
          <div className="absolute inset-0 rounded-2xl overflow-hidden border border-white/10 [backface-visibility:hidden]">
            <Image
                src={data.frontImage}
                alt={`${data.title} front`}
                fill
                priority
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
              aria-hidden={!flipped}
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

        {/* subtle outer glow */}
        <div className="pointer-events-none absolute -inset-px rounded-2xl ring-1 ring-white/10 shadow-[0_0_40px_-10px_rgba(255,255,255,0.25)]" />
      </div>
  );
}
