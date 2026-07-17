import { getApiBaseUrl } from "@/lib/api";
import { getStoredSession } from "@/lib/auth";

function filenameFromDisposition(header: string | null, fallback: string): string {
  if (!header) return fallback.endsWith(".csv") ? fallback : `${fallback}.csv`;
  const utfMatch = /filename\*=UTF-8''([^;]+)/i.exec(header);
  if (utfMatch?.[1]) {
    try {
      return decodeURIComponent(utfMatch[1]);
    } catch {
      // fall through
    }
  }
  const plainMatch = /filename="?([^";]+)"?/i.exec(header);
  if (plainMatch?.[1]) return plainMatch[1];
  return fallback.endsWith(".csv") ? fallback : `${fallback}.csv`;
}

export async function downloadCsv(exportPath: string, filename: string) {
  const session = getStoredSession();
  const response = await fetch(`${getApiBaseUrl()}${exportPath}`, {
    method: "GET",
    credentials: "include",
    headers: {
      Accept: "text/csv,application/octet-stream,*/*",
      ...(session?.token ? { Authorization: `Bearer ${session.token}` } : {}),
    },
  });

  if (!response.ok) {
    let message = "Failed to export CSV";
    try {
      const data = (await response.json()) as { detail?: string | { msg?: string }[] };
      if (typeof data.detail === "string") {
        message = data.detail;
      } else if (Array.isArray(data.detail) && data.detail[0]?.msg) {
        message = data.detail[0].msg;
      }
    } catch {
      // ignore JSON parse errors
    }
    throw new Error(message);
  }

  const contentType = response.headers.get("content-type") ?? "";
  // Guard against HTML/JSON error pages being saved as .csv
  if (contentType.includes("application/json") || contentType.includes("text/html")) {
    throw new Error("Export endpoint did not return a CSV file");
  }

  const blob = await response.blob();
  if (blob.size === 0) {
    throw new Error("Exported CSV is empty");
  }

  const downloadName = filenameFromDisposition(
    response.headers.get("content-disposition"),
    filename,
  );
  const csvBlob =
    blob.type && blob.type.includes("csv")
      ? blob
      : new Blob([blob], { type: "text/csv;charset=utf-8" });

  const url = URL.createObjectURL(csvBlob);
  const link = document.createElement("a");
  link.href = url;
  link.download = downloadName;
  link.style.display = "none";
  document.body.appendChild(link);
  link.click();
  link.remove();
  // Delay revoke so the browser can start the download.
  window.setTimeout(() => URL.revokeObjectURL(url), 1000);
}
