"use client";

import { useMemo } from "react";

export default function Page() {
  const search = typeof window !== "undefined" ? window.location.search : "";
  const flutterURL = useMemo(
      () => `https://forge-cards.pages.dev/${search}`, // replace with your Pages URL
      [search]
  );

  return (
      <main className="relative min-h-dvh bg-forge">
        <header className="px-4 pt-6 text-center">
          <h1 className="text-3xl font-bold tracking-wide">Forged Preview</h1>
          <p className="text-white/70">Swipe. Flip. Tell us what you think.</p>
        </header>

        <section className="px-4 py-6">
          <div className="mx-auto max-w-5xl h-[72svh] rounded-xl overflow-hidden border border-white/10 shadow-2xl">
            <iframe
                src={flutterURL}
                className="w-full h-full"
                loading="lazy"
                title="Forge Cards"
            />
          </div>
        </section>

        <footer className="pb-6 text-center text-xs text-white/50">🔥 forging soon</footer>
      </main>
  );
}
