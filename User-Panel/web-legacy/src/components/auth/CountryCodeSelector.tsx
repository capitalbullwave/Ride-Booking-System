"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { ChevronDown, Search } from "lucide-react";
import { cn } from "@/lib/utils";
import { countries, type Country } from "@/data/countries";
import { Input } from "@/components/ui/input";

interface CountryCodeSelectorProps {
  value: Country;
  onChange: (country: Country) => void;
  className?: string;
  size?: "default" | "lg";
  showDialCode?: boolean;
}

export function CountryCodeSelector({
  value,
  onChange,
  className,
  size = "default",
  showDialCode = false,
}: CountryCodeSelectorProps) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const containerRef = useRef<HTMLDivElement>(null);

  const filteredCountries = useMemo(() => {
    const query = search.trim().toLowerCase();
    if (!query) return countries;

    return countries.filter(
      (country) =>
        country.name.toLowerCase().includes(query) ||
        country.nativeName.toLowerCase().includes(query) ||
        country.code.toLowerCase().includes(query) ||
        country.dialCode.includes(query)
    );
  }, [search]);

  useEffect(() => {
    if (!open) return;

    const handleClickOutside = (event: MouseEvent) => {
      if (
        containerRef.current &&
        !containerRef.current.contains(event.target as Node)
      ) {
        setOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open]);

  const handleSelect = (country: Country) => {
    onChange(country);
    setOpen(false);
    setSearch("");
  };

  return (
    <div ref={containerRef} className="relative shrink-0">
      <button
        type="button"
        onClick={() => setOpen((prev) => !prev)}
        className={cn(
          "flex items-center justify-center gap-1 rounded-[14px] border border-border bg-muted px-3 text-sm font-medium text-foreground transition-colors hover:bg-muted/80",
          size === "lg" ? "h-14 rounded-[16px] border-input bg-muted/50 px-4" : "h-12",
          open && "ring-2 ring-primary/20",
          className
        )}
        aria-label="Select country code"
        aria-expanded={open}
      >
        <span className="whitespace-nowrap">
          {value.code}
          {showDialCode && ` ${value.dialCode}`}
        </span>
        <ChevronDown
          className={cn(
            "h-4 w-4 text-muted-foreground transition-transform",
            open && "rotate-180"
          )}
        />
      </button>

      {open && (
        <div className="absolute left-0 top-[calc(100%+6px)] z-50 w-[min(100vw-3rem,340px)] overflow-hidden rounded-lg border border-border bg-card shadow-lg">
          <div className="border-b border-border p-2">
            <div className="relative">
              <Search className="absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
              <Input
                type="search"
                placeholder="Search"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-8 rounded-md border-border bg-muted pl-8 text-xs"
              />
            </div>
          </div>
          <ul className="max-h-[200px] overflow-y-auto py-1">
            {filteredCountries.length > 0 ? (
              filteredCountries.map((country) => (
                <li key={country.code}>
                  <button
                    type="button"
                    onClick={() => handleSelect(country)}
                    className={cn(
                      "flex w-full items-center gap-2 px-3 py-2 text-left text-sm transition-colors hover:bg-muted",
                      value.code === country.code && "bg-primary/10"
                    )}
                  >
                    <span className="w-7 shrink-0 font-bold text-foreground">
                      {country.code}
                    </span>
                    <span className="min-w-0 flex-1 truncate text-foreground">
                      {country.name}{" "}
                      <span className="text-muted-foreground">
                        ({country.nativeName})
                      </span>
                    </span>
                    <span className="shrink-0 tabular-nums text-foreground">
                      {country.dialCode}
                    </span>
                  </button>
                </li>
              ))
            ) : (
              <li className="px-3 py-4 text-center text-xs text-muted-foreground">
                No countries found
              </li>
            )}
          </ul>
        </div>
      )}
    </div>
  );
}
