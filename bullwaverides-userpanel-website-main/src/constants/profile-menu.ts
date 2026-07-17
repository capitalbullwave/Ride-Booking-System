import { Crown, GraduationCap, HelpCircle, Info, MapPin, Settings } from "lucide-react";
import { ROUTES } from "./routes";

export const profileMenuItems = [
  { id: "account-settings", label: "Account Settings", icon: Settings, route: ROUTES.profileAccountSettings },
  { id: "saved-places", label: "Saved Places", icon: MapPin, route: ROUTES.profileSavedPlaces },
  { id: "subscription", label: "Subscriptions", icon: Crown, route: ROUTES.profileSubscription },
  { id: "student-pass", label: "Student Pass", icon: GraduationCap, route: ROUTES.profileStudentPass },
  { id: "help", label: "Help & Support", icon: HelpCircle, route: ROUTES.profileHelp },
  { id: "about", label: "About Bull Wave rides", icon: Info, route: ROUTES.profileAbout },
] as const;
