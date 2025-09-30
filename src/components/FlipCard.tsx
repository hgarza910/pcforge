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
  defaultFlipped?: boolean;
};

const preserve3d: CSSProperties = { transformStyle: "preserve-3d" };
const perspective: CSSProperties = { perspective: 1200 };
const flipSpring: Transition = { type: "spring", stiffness: 260, damping: 22 };

/** Merge stored UTMs into a destination URL (keeps existing params). */
function withUTM(dest: string, cardId?: string) {
  try {
    // SSR safety
    if (typeof window === "undefined") return dest;

    const u = new URL(dest, window.location.origin);
    const utmKeys = ["utm_source", "utm_medium", "utm_campaign", "utm_content", "utm_term"] as const;

    utmKeys.forEach((k) => {
      const v = localStorage.getItem(k);
      if (v && !u.searchParams.get(k)) u.searchParams.set(k, v);
    });

    // optional: tag which card sent them
    if (cardId && !u.searchParams.get("ref_card")) u.searchParams.set("ref_card", cardId);

    return u.toString();
  } catch {
    return dest; // if URL parsing fails, just return original
  }
}

export default function FlipCard({ data, defaultFlipped = false }: FlipCardProps) {
  const [flipped, setFlipped] = useState<boolean>(defaultFlipped);

  const toggle = useCallback(() => setFlipped((f) => !f), []);

  const onKeyDown = useCallback(
      (e: React.KeyboardEvent<HTMLDivElement>) => {
        if (e.key === " " || e.key === "Enter") {
          e.preventDefault();
          toggle();
        }
        if (e.key === "Escape") setFlipped(false);
      },
      [toggle]
  );

  return (
      <div
          className="
        relative select-none
        h-[68svh] sm:h-[60svh] min-h-[360px] max-h-[560px]
      "
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
                sizes="(max-width:640px) 92vw, (max-width:1024px) 60vw, 40vw"
                className="object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/10 to-transparent" />
            <div
                className="absolute left-4 bottom-4 right-4 space-y-1
                       pb-[calc(env(safe-area-inset-bottom)+0px)]"
            >
              <div className="text-xs sm:text-sm uppercase tracking-widest text-white/70">{data.tier}</div>
              <div className="text-lg sm:text-xl font-semibold">{data.title}</div>
              <div className="text-emerald-300 font-medium">{data.price}</div>

              {data.tags?.length ? (
                  <div className="flex flex-wrap gap-2 pt-2">
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
                sizes="(max-width:640px) 92vw, (max-width:1024px) 60vw, 40vw"
                className="object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
            <div
                className="absolute left-4 right-4 bottom-4 flex items-center gap-3
                       pb-[calc(env(safe-area-inset-bottom)+0px)]"
            >
              <a
                  href={withUTM(data.qrHref, data.id)}
                  target="_blank"
                  rel="noreferrer"
                  className="
                inline-flex items-center justify-center
                rounded-lg bg-white/10 px-4 py-3 text-base
                min-h-11 min-w-28 text-center
                backdrop-blur hover:bg-white/20 active:scale-[0.99] transition
              "
                  onClick={(e) => e.stopPropagation()}
              >
                Open Build
              </a>
              <span className="text-xs sm:text-sm text-white/60">flip to front ↻</span>
            </div>
          </div>
        </motion.div>

        {/* subtle outer glow */}
        <div className="pointer-events-none absolute -inset-px rounded-2xl ring-1 ring-white/10 shadow-[0_0_40px_-10px_rgba(255,255,255,0.25)]" />
      </div>
  );
}
