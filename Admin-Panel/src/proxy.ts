import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

import { AUTH_COOKIE_NAME } from "@/lib/auth";

const PUBLIC_PATHS = ["/login"];

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const isPublic = PUBLIC_PATHS.some(
    (path) => pathname === path || pathname.startsWith(`${path}/`),
  );
  const isAuthenticated = request.cookies.get(AUTH_COOKIE_NAME)?.value === "1";

  if (!isAuthenticated && !isPublic) {
    const loginUrl = new URL("/login", request.url);
    if (pathname !== "/") {
      loginUrl.searchParams.set("from", pathname);
    }
    return NextResponse.redirect(loginUrl);
  }

  if (isAuthenticated && pathname === "/login") {
    return NextResponse.redirect(new URL("/", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!api/v1|_next/static|_next/image|favicon.ico|logo.svg|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico)$).*)",
  ],
};
