/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: { unoptimized: true }, // keeps export simple for static hosting
};
export default nextConfig;
