import { useEffect, useRef } from "react";

interface UseAutoRefreshOptions {
  intervalMs?: number;
  enabled?: boolean;
}

export function useAutoRefresh(
  callback: () => void | Promise<void>,
  { intervalMs = 5000, enabled = true }: UseAutoRefreshOptions = {},
) {
  const callbackRef = useRef(callback);
  callbackRef.current = callback;

  useEffect(() => {
    if (!enabled) return;

    const refresh = () => {
      void callbackRef.current();
    };

    const onFocus = () => refresh();
    const onVisibilityChange = () => {
      if (document.visibilityState === "visible") {
        refresh();
      }
    };

    window.addEventListener("focus", onFocus);
    document.addEventListener("visibilitychange", onVisibilityChange);
    const interval = window.setInterval(refresh, intervalMs);

    return () => {
      window.removeEventListener("focus", onFocus);
      document.removeEventListener("visibilitychange", onVisibilityChange);
      window.clearInterval(interval);
    };
  }, [enabled, intervalMs]);
}
