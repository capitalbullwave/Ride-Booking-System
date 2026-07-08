import { FileText } from "lucide-react";
import { LegalDocumentView } from "@/components/legal";
import { ROUTES } from "@/constants/routes";

export default function TermsPage() {
  return (
    <LegalDocumentView
      title="Terms of Service"
      subtitle="These terms govern your use of Bull Wave Rides rides, deliveries, wallet, and emergency ambulance services."
      icon={FileText}
      sections={[
        {
          title: "Using Bull Wave Rides",
          content:
            "By creating an account or booking a service, you agree to follow community guidelines, pay applicable fares and fees, and treat captains, medical partners, and support staff with respect.",
        },
        {
          title: "Bookings & cancellations",
          content:
            "Fares are shown before you confirm a booking. Cancellation charges may apply depending on the service type and how close you are to pickup. Emergency ambulance misuse may result in account suspension.",
        },
        {
          title: "Captain & partner relationship",
          content:
            "Bull Wave Rides connects riders with independent captains and licensed ambulance partners. We do not employ captains directly, but we enforce platform standards through verification and ratings.",
        },
        {
          title: "Account & conduct",
          content:
            "You are responsible for activity on your account. Fraud, harassment, unsafe behaviour, or repeated policy violations may lead to temporary or permanent account removal.",
        },
      ]}
      relatedLinks={[
        { label: "Privacy Policy", href: ROUTES.privacy },
        { label: "Safety Policy", href: ROUTES.safety },
      ]}
    />
  );
}
