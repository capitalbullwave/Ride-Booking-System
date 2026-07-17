export const APP_DOWNLOAD = {
  androidApkUrl: "/app-release-user.apk",
  androidFileName: "Bull-wave-rides-user.apk",
  captainAndroidApkUrl: "/app-release-driver.apk",
  captainAndroidFileName: "Bull-wave-rides-captain.apk",
  iosAppStoreUrl:
    process.env.NEXT_PUBLIC_IOS_APP_STORE_URL ?? "",
  captainIosAppStoreUrl:
    process.env.NEXT_PUBLIC_CAPTAIN_IOS_APP_STORE_URL ?? "",
} as const;
