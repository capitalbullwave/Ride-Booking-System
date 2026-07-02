import Image from "next/image";
import { cn } from "@/lib/utils";

interface ServiceImageProps {
  src: string;
  alt: string;
  className?: string;
  imageClassName?: string;
}

export function ServiceImage({ src, alt, className, imageClassName }: ServiceImageProps) {
  return (
    <div className={cn("relative h-full w-full", className)}>
      <Image
        src={src}
        alt={alt}
        fill
        unoptimized
        sizes="112px"
        className={cn("object-contain p-1", imageClassName)}
      />
    </div>
  );
}
