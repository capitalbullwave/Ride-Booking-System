import { Suspense } from "react";
import { HomeView } from "@/components/home";

function HomeFallback() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
      Loading…
    </div>
  );
}

export default function HomePage() {
  return (
    <Suspense fallback={<HomeFallback />}>
      <HomeView />
    </Suspense>
  );
}
