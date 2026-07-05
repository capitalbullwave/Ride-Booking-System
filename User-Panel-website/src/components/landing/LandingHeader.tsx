"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Menu, X } from "lucide-react";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { WaveGoLogo } from "@/components/layout/WaveGoLogo";
import { ROUTES } from "@/constants/routes";
import { landingNavLinks } from "@/constants/services";
import { cn } from "@/lib/utils";

function getActiveFromUrl(pathname: string) {
  if (pathname === ROUTES.about) {
    return ROUTES.about;
  }

  if (pathname === ROUTES.safety) {
    return ROUTES.safety;
  }

  if (pathname === ROUTES.blogs || pathname.startsWith(`${ROUTES.blogs}/`)) {
    return ROUTES.blogs;
  }

  if (pathname === ROUTES.landing) {
    const hash = window.location.hash;
    if (hash && landingNavLinks.some((link) => link.href === hash)) {
      return hash;
    }
    return ROUTES.landing;
  }

  return ROUTES.landing;
}

export function LandingHeader() {
  const router = useRouter();
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [activeNav, setActiveNav] = useState<string>(ROUTES.landing);

  useEffect(() => {
    setActiveNav(getActiveFromUrl(pathname));

    const onHashChange = () => {
      setActiveNav(getActiveFromUrl(pathname));
    };

    window.addEventListener("hashchange", onHashChange);
    return () => window.removeEventListener("hashchange", onHashChange);
  }, [pathname]);

  const resolveHref = (href: string) => {
    if (href.startsWith("#") && pathname !== ROUTES.landing) {
      return `${ROUTES.landing}${href}`;
    }
    return href;
  };

  const isActive = (href: string) => activeNav === href;

  const handleNavClick = (href: string) => {
    setActiveNav(href);
    setMobileMenuOpen(false);
  };

  const linkClassName = (href: string, mobile = false) =>
    cn(
      "text-sm font-medium transition-colors",
      mobile
        ? cn(
            "block rounded-lg px-3 py-3 hover:bg-primary/5 hover:text-primary",
            isActive(href) ? "text-primary" : "text-foreground"
          )
        : cn(
            "relative py-1 hover:text-primary",
            "after:absolute after:bottom-0 after:left-0 after:h-0.5 after:w-full after:origin-left after:scale-x-0 after:rounded-full after:bg-primary after:transition-transform after:duration-200 hover:after:scale-x-100",
            isActive(href)
              ? "text-primary after:scale-x-100"
              : "text-foreground/80"
          )
    );

  return (
    <header className="wavego-site-header">
      <div className="wavego-site-header-top" aria-hidden />
      <div className="wavego-site-header-body">
      <div className="mx-auto flex h-24 max-w-6xl items-center justify-between px-6">
        <Link href={ROUTES.landing} onClick={() => handleNavClick(ROUTES.landing)}>
          <WaveGoLogo size="sm" priority />
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {landingNavLinks.map((link) => (
            <Link
              key={link.label}
              href={resolveHref(link.href)}
              onClick={() => handleNavClick(link.href)}
              className={linkClassName(link.href)}
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="hidden items-center gap-2 md:flex">
          <Button
            variant="ghost"
            className="font-medium text-foreground hover:bg-primary/10 hover:text-primary"
            onClick={() => router.push(ROUTES.login)}
          >
            Sign in
          </Button>
          <Button
            className="rounded-lg px-5 font-semibold"
            onClick={() => router.push(ROUTES.login)}
          >
            Download App
          </Button>
        </div>

        <button
          type="button"
          className="rounded-lg p-2 md:hidden"
          onClick={() => setMobileMenuOpen((open) => !open)}
          aria-label="Toggle menu"
        >
          {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {mobileMenuOpen && (
        <div className="border-t border-primary/10 bg-secondary px-6 py-4 md:hidden">
          {landingNavLinks.map((link) => (
            <Link
              key={link.label}
              href={resolveHref(link.href)}
              onClick={() => handleNavClick(link.href)}
              className={linkClassName(link.href, true)}
            >
              {link.label}
            </Link>
          ))}
          <div className="mt-3 flex flex-col gap-2">
            <Button variant="outline" onClick={() => router.push(ROUTES.login)}>
              Sign in
            </Button>
            <Button onClick={() => router.push(ROUTES.login)}>Download App</Button>
          </div>
        </div>
      )}
      </div>
    </header>
  );
}
