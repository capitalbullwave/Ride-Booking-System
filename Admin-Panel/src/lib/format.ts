export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatNumber(num: number): string {
  if (num >= 10000000) return `${(num / 10000000).toFixed(1)}Cr`;
  if (num >= 100000) return `${(num / 100000).toFixed(1)}L`;
  if (num >= 1000) return `${(num / 1000).toFixed(1)}K`;
  return num.toString();
}

export function formatDate(date: string): string {
  return new Intl.DateTimeFormat("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(date));
}

export function formatDateTime(date: string): string {
  return new Intl.DateTimeFormat("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(date));
}

export function capitalize(str: string): string {
  return str.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

export function formatGender(value?: string | null): string {
  if (!value?.trim()) return "—";
  return capitalize(value.trim());
}

export function formatShortId(
  id: string,
  prefixLength = 8,
  suffixLength = 4,
): string {
  if (!id) return "—";
  if (/^BWR-[UDR]-\d{6}$/.test(id)) return id;
  if (id.length <= prefixLength + suffixLength + 1) return id;
  return `${id.slice(0, prefixLength)}…${id.slice(-suffixLength)}`;
}

export function formatPublicId(
  publicId?: string | null,
  fallbackId?: string,
): string {
  if (publicId?.trim()) return publicId;
  if (fallbackId?.trim()) return formatShortId(fallbackId);
  return "—";
}
