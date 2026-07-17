import { ImageResponse } from "next/og";

export const runtime = "edge";

export const size = {
  width: 32,
  height: 32,
};

export const contentType = "image/png";

export default async function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          backgroundColor: "#0b0f19",
        }}
      >
        <img
          src={"/images/bw-rides-logo-transparent.png"}
          width={26}
          height={26}
          alt="Bullwave Rides"
          style={{ borderRadius: 6 }}
        />
      </div>
    ),
    size
  );
}

