import type { Metadata } from "next";
import { inter, playwriteEnglandJoined } from "@/lib/fonts";
import "./globals.css";

export const metadata: Metadata = {
  title: "WaveGo - Move Smarter. Travel Better.",
  description: "WaveGo is a premium ride-booking web application.",
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
