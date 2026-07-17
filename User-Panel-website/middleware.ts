import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { AUTH_COOKIE_NAME, PROFILE_COMPLETE_COOKIE } from "@/constants/auth";
import { ROUTES } from "@/constants/routes";

/** Exact paths anyone can open without login (marketing + auth + legal). */
const PUBLIC_PATHS = new Set<string>([
  ROUTES.landing,
  ROUTES.login,
  ROUTES.signup,
  ROUTES.createProfile,
  ROUTES.otp,
  ROUTES.about,
  ROUTES.blogs,
  ROUTES.safety,
  ROUTES.terms,
  ROUTES.privacy,
  ROUTES.legalSafety,
  "/robots.txt",
  "/sitemap.xml",
  "/opengraph-image",
  "/twitter-image",
  "/icon",
]);

/** Nested public sections (blog articles, legal pages, safety sub-pages). */
const PUBLIC_PREFIXES = [
  `${ROUTES.blogs}/`,
  `${ROUTES.safety}/`,
  "/legal/",
] as const;

function isPublicPath(pathname: string) {
  if (PUBLIC_PATHS.has(pathname)) return true;
  return PUBLIC_PREFIXES.some((prefix) => pathname.startsWith(prefix));
}

function postAuthDestination(request: NextRequest, profileComplete: boolean) {
  return new URL(profileComplete ? ROUTES.home : ROUTES.createProfile, request.url);
}

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const isAuthenticated = request.cookies.get(AUTH_COOKIE_NAME)?.value === "1";
  const profileComplete = request.cookies.get(PROFILE_COMPLETE_COOKIE)?.value === "1";

  if (isPublicPath(pathname)) {
    if (
      isAuthenticated &&
      (pathname === ROUTES.login || pathname === ROUTES.signup || pathname === ROUTES.otp)
    ) {
      return NextResponse.redirect(postAuthDestination(request, profileComplete));
    }
    if (isAuthenticated && pathname === ROUTES.createProfile && profileComplete) {
      return NextResponse.redirect(new URL(ROUTES.home, request.url));
    }
    return NextResponse.next();
  }

  if (!isAuthenticated) {
    const loginUrl = new URL(ROUTES.login, request.url);
    loginUrl.searchParams.set("redirect", pathname);
    return NextResponse.redirect(loginUrl);
  }

  if (!profileComplete && pathname !== ROUTES.createProfile) {
    return NextResponse.redirect(new URL(ROUTES.createProfile, request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|robots.txt|sitemap.xml|opengraph-image|twitter-image|icon|images|api|uploads|.*\\.(?:svg|png|jpg|jpeg|gif|webp|apk)$).*)",
  ],
};
