/**
 * Reserved for optional manual refresh wiring.
 * Automatic polling is disabled — pages load once on mount via useEffect.
 */
export function useAutoRefresh(
  _callback: () => void | Promise<void>,
  _options?: { intervalMs?: number; enabled?: boolean },
) {
  // Intentionally no-op: data loads once on page open; refresh only via user action.
}
