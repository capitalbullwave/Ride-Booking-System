import { Suspense } from "react";
import { CreateProfileView } from "@/components/auth/CreateProfileView";

function CreateProfileFallback() {
  return (
    <div className="flex h-[100dvh] w-full items-center justify-center overflow-hidden bg-background text-muted-foreground">
      Loading…
    </div>
  );
}

export default function CreateProfilePage() {
  return (
    <Suspense fallback={<CreateProfileFallback />}>
      <CreateProfileView />
    </Suspense>
  );
}
