/** @type {import('next').NextConfig} */
const nextConfig = {
  async redirects() {
    return [
      {
        source: '/',
        destination: '/forge/',
        permanent: false, // flip to true (308) when you're sure
      },
    ];
  },
};

export default nextConfig;
