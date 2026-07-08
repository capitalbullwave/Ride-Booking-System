import type { Metadata } from "next";
import { inter, playwriteEnglandJoined } from "@/lib/fonts";
import "./globals.css";

export const metadata: Metadata = {
  title: "Bull Wave Rides - Move Smarter. Travel Better.",
  description: "Bull Wave Rides is a premium ride-booking web application.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${inter.variable} ${playwriteEnglandJoined.variable} font-sans antialiased bg-background text-foreground`}
      >
        {children}
      </body>
    </html>
  );
}
