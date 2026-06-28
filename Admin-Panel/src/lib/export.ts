import { getApiBaseUrl } from "@/lib/api";

export async function downloadCsv(exportPath: string, filename: string) {
  const response = await fetch(`${getApiBaseUrl()}${exportPath}`);

  if (!response.ok) {
    let message = "Failed to export CSV";
    try {
      const data = (await response.json()) as { detail?: string };
      message = data.detail ?? message;
    } catch {
      // ignore JSON parse errors
    }
    throw new Error(message);
  }

  const blob = await response.blob();
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename.endsWith(".csv") ? filename : `${filename}.csv`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}
