import type { Metadata } from "next";
import "./globals.css";
import Script from "next/script";

export const metadata: Metadata = {
  title: "Forged Preview",
  description: "A tiny interactive tease of PCForge forged cards.",
  openGraph: {
    title: "Forged Preview",
    description: "Flip the forged cards. Tell us what you think.",
    images: [{ url: "/og.jpg", width: 1200, height: 630 }],
  },
  twitter: { card: "summary_large_image" },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        {/* Cloudflare Web Analytics — replace YOUR_TOKEN when ready */}
        <Script
          id="cf-analytics"
          strategy="afterInteractive"
          src="https://static.cloudflareinsights.com/beacon.min.js"
          data-cf-beacon='{"token": "YOUR_TOKEN"}'
        />
      </head>
      <body className="min-h-dvh bg-forge text-white antialiased">{children}</body>
    </html>
  );
}
