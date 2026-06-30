"use client";

import { X, Home, CalendarCheck, Wallet, User, HelpCircle, FileText, ShieldCheck, LogOut } from "lucide-react";
import { useRouter } from "next/navigation";
import { ROUTES } from "@/constants/routes";
import { clearAuthSession } from "@/lib/auth-session";
import { useAuthUser } from "@/hooks/useAuthUser";

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  const router = useRouter();
  const user = useAuthUser();

  const handleLogout = () => {
    clearAuthSession();
    onClose();
    router.push(ROUTES.landing);
  };

  return (
    <>
      {/* Backdrop */}
      {isOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/50 backdrop-blur-sm transition-opacity"
          onClick={onClose}
        />
      )}

      {/* Sidebar Panel */}
      <div
        className={`fixed top-0 left-0 z-50 h-full w-[280px] bg-white shadow-2xl transition-transform duration-300 ease-in-out ${
          isOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        {/* User Profile Section */}
        <div className="flex items-center gap-4 border-b border-border p-6 bg-muted/20 relative">
          <button 
            onClick={onClose}
            className="absolute top-4 right-4 text-muted-foreground hover:text-foreground"
          >
            <X className="h-5 w-5" />
          </button>
          
          <div className="flex h-14 w-14 items-center justify-center rounded-full bg-primary/10 font-heading text-lg font-bold text-primary">
            {user.initial}
          </div>
          <div>
            <h2 className="font-heading font-bold text-foreground">{user.name}</h2>
            <p className="text-xs text-muted-foreground">{user.phone}</p>
          </div>
        </div>

        {/* Navigation Links */}
        <div className="flex flex-col py-4">
          <button 
            onClick={() => { onClose(); router.push(ROUTES.home); }}
            className="flex items-center gap-4 px-6 py-4 text-sm font-medium text-foreground hover:bg-muted/50 transition-colors"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-secondary/30 text-primary">
              <Home className="h-4 w-4" />
            </div>
            Home
          </button>

          <button 
            onClick={() => { onClose(); router.push(ROUTES.bookings); }}
            className="flex items-center gap-4 px-6 py-4 text-sm font-medium text-foreground hover:bg-muted/50 transition-colors"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-secondary/30 text-primary">
              <CalendarCheck className="h-4 w-4" />
            </div>
            Bookings
          </button>

          <button 
            onClick={() => { onClose(); router.push(ROUTES.wallet); }}
            className="flex items-center gap-4 px-6 py-4 text-sm font-medium text-foreground hover:bg-muted/50 transition-colors"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-secondary/30 text-primary">
              <Wallet className="h-4 w-4" />
            </div>
            Wallet
          </button>

          <button 
            onClick={() => { onClose(); router.push(ROUTES.profile); }}
            className="flex items-center gap-4 px-6 py-4 text-sm font-medium text-foreground hover:bg-muted/50 transition-colors"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-secondary/30 text-primary">
              <User className="h-4 w-4" />
            </div>
            Profile
          </button>
          
          <button 
            onClick={() => { onClose(); router.push(ROUTES.profileHelp); }}
            className="flex items-center gap-4 px-6 py-4 text-sm font-medium text-foreground hover:bg-muted/50 transition-colors"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-secondary/30 text-primary">
              <HelpCircle className="h-4 w-4" />
            </div>
            Support
          </button>

          <button 
            onClick={() => { onClose(); router.push(ROUTES.terms); }}
            className="flex items-center gap-4 px-6 py-4 text-sm font-medium text-foreground hover:bg-muted/50 transition-colors"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-secondary/30 text-primary">
              <FileText className="h-4 w-4" />
            </div>
            Terms & Conditions
          </button>

          <button 
            onClick={() => { onClose(); router.push(ROUTES.safety); }}
            className="flex items-center gap-4 px-6 py-4 text-sm font-medium text-foreground hover:bg-muted/50 transition-colors"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-secondary/30 text-primary">
              <ShieldCheck className="h-4 w-4" />
            </div>
            Safety Policy
          </button>

          <button 
            onClick={handleLogout}
            className="flex items-center gap-4 px-6 py-4 text-sm font-medium text-foreground hover:bg-muted/50 transition-colors mt-auto"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-secondary/30 text-primary">
              <LogOut className="h-4 w-4" />
            </div>
            Logout
          </button>
        </div>
      </div>
    </>
  );
}
