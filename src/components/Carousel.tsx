"use client";

import { PropsWithChildren, useCallback } from "react";
import useEmblaCarousel from "embla-carousel-react";

export default function Carousel({ children }: PropsWithChildren) {
  const [viewportRef, embla] = useEmblaCarousel({
    loop: true,
    align: "center",
    skipSnaps: false,
    dragFree: true,
    containScroll: "trimSnaps",
  });

  // mouse wheel → horizontal scroll (prevents vertical jank)
  const onWheel = useCallback(
      (e: React.WheelEvent) => {
        if (!embla) return;
        const vertical = Math.abs(e.deltaY) > Math.abs(e.deltaX);
        if (vertical) {
          e.preventDefault();
          if (e.deltaY > 0) embla.scrollNext();
          else embla.scrollPrev();
        }
      },
      [embla]
  );

  return (
      <div className="relative" role="region" aria-roledescription="carousel" aria-label="Forged cards">
        <div ref={viewportRef} onWheel={onWheel} className="overflow-hidden">
          <div className="flex touch-pan-x">{children}</div>
        </div>
      </div>
  );
}
