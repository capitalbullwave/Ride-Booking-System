"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { LandingHeader } from "@/components/landing/LandingHeader";
import { CaptainSafetyView } from "@/components/landing/CaptainSafetyView";
import { CustomerSafetyView } from "@/components/landing/CustomerSafetyView";
import { SafetyOverviewView } from "@/components/landing/SafetyOverviewView";
import { WaveGoLogo } from "@/components/layout/WaveGoLogo";
import {
  safetyFooterLinks,
  safetySocialLinks,
  safetyTabs,
  type SafetyAudience,
} from "@/constants/safety-content";
import { cn } from "@/lib/utils";

function SocialIcon({ icon }: { icon: (typeof safetySocialLinks)[number]["icon"] }) {
  const className = "h-5 w-5";
  if (icon === "facebook") {
    return (
      <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
        <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
      </svg>
    );
  }
  if (icon === "twitter") {
    return (
      <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
      </svg>
    );
  }
  if (icon === "linkedin") {
    return (
      <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
        <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
      </svg>
    );
  }
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z" />
    </svg>
  );
}

export function SafetyPolicyView() {
  const [activeTab, setActiveTab] = useState<SafetyAudience>("all");

  useEffect(() => {
    window.scrollTo({ top: 0, left: 0, behavior: "instant" });
  }, [activeTab]);

  return (
    <div className="min-h-screen bg-background font-sans">
      <LandingHeader />

      <div className="border-b border-border bg-card px-6">
        <div className="mx-auto flex max-w-6xl gap-6 overflow-x-auto sm:gap-10">
          {safetyTabs.map((tab) => (
            <button
              key={tab.id}
              type="button"
              onClick={() => setActiveTab(tab.id)}
              className={cn(
                "relative shrink-0 py-4 text-sm font-medium transition-colors",
                "after:absolute after:bottom-0 after:left-0 after:h-0.5 after:w-full after:origin-left after:rounded-full after:bg-primary after:transition-transform after:duration-200",
                activeTab === tab.id
                  ? "font-bold text-foreground after:scale-x-100"
                  : "text-muted-foreground after:scale-x-0 hover:text-primary hover:after:scale-x-100"
              )}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {activeTab === "customer" ? (
        <CustomerSafetyView />
      ) : activeTab === "captain" ? (
        <CaptainSafetyView />
      ) : (
        <SafetyOverviewView onTabChange={(tab) => setActiveTab(tab)} />
      )}

      <footer className="bg-foreground px-6 py-14 text-background">
        <div className="mx-auto max-w-6xl">
          <div className="grid gap-10 sm:grid-cols-2 lg:grid-cols-4">
            <div className="sm:col-span-2 lg:col-span-1">
              <WaveGoLogo size="md" />
              <p className="mt-4 max-w-xs text-sm leading-relaxed text-white/60">
                Premium rides, smart deliveries, and emergency ambulance — one trusted mobility
                platform for modern India.
              </p>
            </div>

            <div>
              <p className="mb-4 text-sm font-bold text-white">Company</p>
              <nav className="flex flex-col gap-3 text-sm text-white/70">
                {safetyFooterLinks.company.map((link) => (
                  <Link
                    key={link.label}
                    href={link.href}
                    className="transition-colors hover:text-secondary"
                  >
                    {link.label}
                  </Link>
                ))}
              </nav>
            </div>

            <div>
              <p className="mb-4 text-sm font-bold text-white">Legal</p>
              <nav className="flex flex-col gap-3 text-sm text-white/70">
                {safetyFooterLinks.legal.map((link) => (
                  <Link
                    key={link.label}
                    href={link.href}
                    className="transition-colors hover:text-secondary"
                  >
                    {link.label}
                  </Link>
                ))}
              </nav>
            </div>

            <div>
              <p className="mb-4 text-sm font-bold text-white">Follow Us</p>
              <div className="flex gap-4">
                {safetySocialLinks.map(({ label, href, icon }) => (
                  <a
                    key={label}
                    href={href}
                    aria-label={label}
                    className="text-white/70 transition-colors hover:text-secondary"
                  >
                    <SocialIcon icon={icon} />
                  </a>
                ))}
              </div>
            </div>
          </div>

          <p className="mt-12 border-t border-white/10 pt-8 text-center text-sm text-white/50">
            © 2026 Fast Bull Technologies. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
