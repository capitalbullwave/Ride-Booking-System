import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";

export const size = {
  width: 1200,
  height: 600,
};

export const contentType = "image/png";

export default async function TwitterImage() {
  const logo = await readFile(
    join(process.cwd(), "public/images/bw-rides-logo-transparent.png")
  );
  const logoSrc = `data:image/png;base64,${logo.toString("base64")}`;

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          background:
            "linear-gradient(135deg, rgba(15,23,42,1) 0%, rgba(0,0,0,0.95) 100%)",
          color: "white",
          padding: 64,
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 26,
          }}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={logoSrc}
            width={120}
            height={120}
            alt="Bullwave Rides"
            style={{
              borderRadius: 24,
              backgroundColor: "rgba(255,255,255,0.06)",
              padding: 16,
            }}
          />
          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            <div style={{ fontSize: 56, fontWeight: 800, lineHeight: 1 }}>
              Bullwave Rides
            </div>
            <div style={{ fontSize: 26, opacity: 0.9, lineHeight: 1.25 }}>
              Fast, reliable, and safe rides.
            </div>
          </div>
        </div>
      </div>
    ),
    size
  );
}
