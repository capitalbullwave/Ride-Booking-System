import type { Metadata } from "next";
import { BackendWarmup } from "@/components/BackendWarmup";
import { FloatingChatWidget } from "@/components/chat/FloatingChatWidget";
import { inter, playwriteEnglandJoined } from "@/lib/fonts";
import "./globals.css";

const siteUrl = (process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000")
  .trim()
  .replace(/\/+$/, "");

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: "Bullwave Rides",
    template: "%s | Bullwave Rides",
  },
  description:
    "Bullwave Rides is a premium ride-booking web application for fast, reliable, and safe rides.",
  applicationName: "Bullwave Rides",
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "any" },
      { url: "/icon.png", type: "image/png", sizes: "48x48" },
      { url: "/icon-192.png", type: "image/png", sizes: "192x192" },
      { url: "/icon-512.png", type: "image/png", sizes: "512x512" },
    ],
    apple: [{ url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" }],
    shortcut: "/favicon.ico",
  },
  alternates: {
    canonical: "/",
  },
  openGraph: {
    type: "website",
    url: "/",
    siteName: "Bullwave Rides",
    title: "Bullwave Rides",
    description:
      "Premium ride-booking platform for fast, reliable, and safe rides.",
    images: [
      {
        url: "/opengraph-image",
        width: 1200,
        height: 630,
        alt: "Bullwave Rides",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Bullwave Rides",
    description:
      "Premium ride-booking platform for fast, reliable, and safe rides.",
    images: ["/twitter-image"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
      "max-video-preview": -1,
    },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        name: "Bullwave Rides",
        url: siteUrl,
        logo: `${siteUrl}/images/bw-rides-logo.png`,
      },
      {
        "@type": "WebSite",
        name: "Bullwave Rides",
        url: siteUrl,
        potentialAction: {
          "@type": "SearchAction",
          target: `${siteUrl}/blogs?search={search_term_string}`,
          "query-input": "required name=search_term_string",
        },
      },
    ],
  };

  return (
    <html lang="en">
      <body
        className={`${inter.variable} ${playwriteEnglandJoined.variable} font-sans antialiased bg-background text-foreground`}
      >
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        <BackendWarmup />
        {children}
        <FloatingChatWidget />
      </body>
    </html>
  );
}
