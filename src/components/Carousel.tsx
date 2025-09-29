"use client";

import { PropsWithChildren, useCallback } from "react";
import useEmblaCarousel from "embla-carousel-react";

export default function Carousel({ children }: PropsWithChildren) {
  const [viewportRef, embla] = useEmblaCarousel({ loop: true, align: "center", skipSnaps: false });

  const onWheel = useCallback((e: React.WheelEvent) => {
    if (!embla) return;
    if (Math.abs(e.deltaY) > Math.abs(e.deltaX)) {
      e.preventDefault();
      if (e.deltaY > 0) embla.scrollNext();
      else embla.scrollPrev();
    }
  }, [embla]);

  return (
    <div className="relative">
      <div ref={viewportRef} onWheel={onWheel} className="overflow-hidden">
        <div className="flex touch-pan-x">{children}</div>
      </div>
    </div>
  );
}
