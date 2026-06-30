"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Activity } from "lucide-react";

export default function SearchingAmbulancePage() {
  const router = useRouter();
  const [progress, setProgress] = useState(0);
  const [status, setStatus] = useState("Finding nearest ambulance...");

  useEffect(() => {
    const timer1 = setTimeout(() => {
      setProgress(40);
      setStatus("Contacting driver...");
    }, 2000);

    const timer2 = setTimeout(() => {
      setProgress(80);
      setStatus("Confirming availability...");
    }, 4000);

    const timer3 = setTimeout(() => {
      setProgress(100);
      router.push("/ambulance/assigned");
    }, 6000);

    return () => {
      clearTimeout(timer1);
      clearTimeout(timer2);
      clearTimeout(timer3);
    };
  }, [router]);

  return (
    <div className="flex min-h-screen w-full flex-col items-center justify-center bg-background px-6">
      
      {/* Pulse Animation Circle */}
      <div className="relative mb-12 flex h-32 w-32 items-center justify-center">
        <div className="absolute inset-0 animate-ping rounded-full bg-[#D66B6B]/20" />
        <div className="absolute inset-4 animate-pulse rounded-full bg-[#D66B6B]/40" />
        <div className="relative flex h-16 w-16 items-center justify-center rounded-full bg-[#D66B6B] text-white shadow-xl">
          <Activity className="h-8 w-8 animate-pulse" />
        </div>
      </div>

      <h1 className="font-heading text-2xl font-bold text-foreground mb-2">Searching...</h1>
      <p className="text-sm font-medium text-muted-foreground mb-8 text-center animate-pulse">
        {status}
      </p>

      {/* Progress Bar */}
      <div className="w-full max-w-xs h-2 rounded-full bg-muted overflow-hidden">
        <div 
          className="h-full bg-[#D66B6B] transition-all duration-1000 ease-out"
          style={{ width: `${progress}%` }}
        />
      </div>

      <p className="mt-8 text-xs text-muted-foreground">Estimated matching time: &lt; 1 min</p>

      {/* Cancel Button */}
      <button 
        onClick={() => router.back()}
        className="mt-12 rounded-full px-6 py-2 text-sm font-semibold text-muted-foreground hover:bg-muted transition-colors"
      >
        Cancel Request
      </button>

    </div>
  );
}
