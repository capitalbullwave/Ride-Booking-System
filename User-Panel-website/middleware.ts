import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { AUTH_COOKIE_NAME } from "@/constants/auth";
import { ROUTES } from "@/constants/routes";

const PUBLIC_PATHS = new Set<string>([
  ROUTES.landing,
  ROUTES.login,
  ROUTES.signup,
  ROUTES.createProfile,
  ROUTES.otp,
  ROUTES.terms,
  ROUTES.privacy,
  ROUTES.safety,
]);

function isPublicPath(pathname: string) {
  if (PUBLIC_PATHS.has(pathname)) return true;
  return false;
}

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const isAuthenticated = request.cookies.get(AUTH_COOKIE_NAME)?.value === "1";

  if (isPublicPath(pathname)) {
    if (isAuthenticated && (pathname === ROUTES.login || pathname === ROUTES.signup || pathname === ROUTES.createProfile)) {
      return NextResponse.redirect(new URL(ROUTES.home, request.url));
    }
    return NextResponse.next();
  }

  if (!isAuthenticated) {
    const loginUrl = new URL(ROUTES.login, request.url);
    loginUrl.searchParams.set("redirect", pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|images|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
