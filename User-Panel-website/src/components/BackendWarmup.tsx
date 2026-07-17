"use client";

import { useEffect } from "react";
import { warmBackend } from "@/lib/api";

/** Pings staging backend on first paint so Render cold-starts before user actions. */
export function BackendWarmup() {
  useEffect(() => {
    void warmBackend();
  }, []);

  return null;
}
