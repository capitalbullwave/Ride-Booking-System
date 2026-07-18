import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";

export const size = {
  width: 1200,
  height: 630,
};

export const contentType = "image/png";

export default async function OpenGraphImage() {
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
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          background:
            "linear-gradient(135deg, rgba(0,0,0,0.92) 0%, rgba(17,24,39,1) 55%, rgba(0,0,0,0.92) 100%)",
          color: "white",
          padding: 64,
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 28,
            width: "100%",
          }}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={logoSrc}
            width={140}
            height={140}
            alt="Bullwave Rides"
            style={{
              borderRadius: 28,
              backgroundColor: "rgba(255,255,255,0.06)",
              padding: 18,
            }}
          />
          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            <div style={{ fontSize: 64, fontWeight: 800, lineHeight: 1 }}>
              Bullwave Rides
            </div>
            <div
              style={{
                fontSize: 30,
                opacity: 0.9,
                lineHeight: 1.25,
                maxWidth: 820,
              }}
            >
              Premium ride-booking platform for fast, reliable, and safe rides.
            </div>
          </div>
        </div>

        <div
          style={{
            marginTop: 44,
            display: "flex",
            width: "100%",
            justifyContent: "space-between",
            opacity: 0.85,
            fontSize: 22,
          }}
        >
          <div>Book rides • Track trips • Safety-first</div>
          <div>bullwaverides</div>
        </div>
      </div>
    ),
    size
  );
}
