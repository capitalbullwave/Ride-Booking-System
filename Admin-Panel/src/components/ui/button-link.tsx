import Link from "next/link";
import { Button } from "@/components/ui/button";

type ButtonLinkProps = React.ComponentProps<typeof Button> & {
  href: string;
};

export function ButtonLink({ href, children, ...props }: ButtonLinkProps) {
  return (
    <Button nativeButton={false} render={<Link href={href} />} {...props}>
      {children}
    </Button>
  );
}
