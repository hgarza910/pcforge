import type { Metadata } from "next";
import "./globals.css";
import Script from "next/script";

export const metadata: Metadata = {
  title: "Forge Preview",
  description: "A tiny interactive tease of PCForge forged cards.",
  // ↓ so social images resolve to your real domain
  metadataBase: new URL("https://pcforge.pages.dev"),
  openGraph: {
    title: "Forge Preview",
    description: "Flip the forged cards. Tell us what you think.",
    images: [{ url: "/og.jpg", width: 1200, height: 630 }],
  },
  twitter: { card: "summary_large_image" },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
      <html lang="en">
      <head>
        {/* Cloudflare Web Analytics — replace YOUR_TOKEN */}
        <Script
            id="cf-analytics"
            strategy="afterInteractive"
            src="https://static.cloudflareinsights.com/beacon.min.js"
            data-cf-beacon='{"token": "YOUR_TOKEN"}'
        />
      </head>
      {/* use svh for mobile browser chrome and safe-area padding */}
      <body className="min-h-svh bg-forge text-white antialiased pb-[env(safe-area-inset-bottom)]">
      {children}
      </body>
      </html>
  );
}
