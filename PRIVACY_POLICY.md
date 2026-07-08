# Privacy Policy

**Last updated:** 2026-07-08

This document describes data handling for the **Ride-Booking-System** repository (WaveGo / Fast Bull apps + backend). It is written based on the code and dependencies present in this repo.

---

## 1) Information we collect

Based on this repository, the Service may handle the following categories of data.

### Account & verification
- Phone number (for OTP login)
- Name and optional profile details (e.g., email) you provide
  - The backend user profile update supports fields including emergency contact name/phone and FCM token.

### Trip & location data
- Pickup/drop locations and trip details (time, route, fare, status)
- **Real-time location during active trips** (and during driver online/availability where enabled)
- Location search queries (to help you find pickup/drop points)

### Payments & wallet
- Transaction records and payment status for fares/wallet flows
- The repo includes integrations for payment providers (e.g., Razorpay and Stripe) on the backend and Razorpay on the Flutter client.

### Device & app data
- Device identifiers and basic device/app info (OS version, app version, language)
- Diagnostics (crash logs, performance data) to improve reliability and prevent abuse

### Support & safety
- Messages and metadata when you contact support
- Reports related to safety incidents, disputes, or fraud prevention

### Driver-specific information (Driver app)
- Identity/verification documents you upload (where applicable)
- Vehicle and licensing details (where applicable)
- Availability/online status and operational logs needed to complete rides

---

## 2) How we use information

We use information to:

- Provide OTP login and secure access to your account
- Match riders with nearby drivers and enable trip execution
- Enable navigation, routing, and location-based features
- Process payments, wallet operations, refunds, and receipts
- Provide customer support and resolve disputes
- Improve the Service (analytics, debugging, performance monitoring)
- Promote safety, detect fraud, and comply with legal obligations

---

## 3) How we share information

We share information only as needed to operate the Service:

- **Between riders and assigned drivers**: limited contact and trip/location details necessary to complete an active booking
- **Service providers** (processors and infrastructure):
  - **Payments**: Razorpay (Flutter client dependency) and Razorpay/Stripe (backend dependencies)
  - **Maps / geocoding / routing**: Google Maps APIs (backend dependency), and OpenStreetMap Nominatim + OSRM fallbacks (backend code)
  - **OTP / notifications**: Twilio and Firebase Admin are present as backend dependencies (actual usage depends on deployment configuration)
- **Legal and safety**: when required by law, to protect users, to investigate abuse, or to respond to emergencies

---

## 4) Data retention

Retention behavior depends on backend configuration and operational requirements. The backend includes account deletion services; however, some records may need to be retained (e.g., payments or safety logs) depending on your jurisdiction and business rules.

In general, data is retained as long as necessary to:

- Provide the Service and maintain account functionality
- Meet legal, tax, accounting, and regulatory obligations
- Resolve disputes and enforce our terms
- Maintain safety and fraud-prevention records

Retention periods may vary by data type and jurisdiction. Some records (e.g., transactions) may be retained even after account deletion where legally required.

---

## 5) Security

We use reasonable administrative, technical, and organizational safeguards to protect information, including encryption in transit (TLS) and access controls. No method of transmission or storage is 100% secure, and we cannot guarantee absolute security.

---

## 6) Your choices and rights

Depending on your location and how this repo is deployed, you may be able to:

- Access and update certain profile details in the app
- Manage permissions (location, notifications) in your device settings
- Request a copy of your data
- Request deletion of your account/data (subject to legal retention requirements)

---

## 7) Permissions (mobile apps)

The apps may request permissions such as:

- **Location** (to set pickup/drop points, track trips, and enable driver availability)
- **Notifications** (trip updates and operational alerts)
- **Camera / Photos** (for document upload where applicable)

You can grant/deny permissions in your device settings. Some features may not work without certain permissions.

---

## 8) Children’s privacy

The Service is not intended for children under the age of 13 (or the minimum age required in your jurisdiction). We do not knowingly collect personal information from children. If you believe a child has provided personal information, contact us so we can take appropriate action.

---

## 9) International transfers

If we operate in multiple regions, your information may be processed in countries other than where you live. Where required, we use appropriate safeguards for cross-border transfers.

---

## 10) Changes to this policy

We may update this policy from time to time. We will update the “Last updated” date and, if changes are material, provide additional notice where required.

---

## 11) Contact us

This backend exposes contact info via `GET /api/v1/public/contact` and `GET /api/v1/public/about`, backed by `AppSetting` entries such as `contact_email`, `contact_phone`, and `contact_address`. Use your deployment’s configured values for user-facing contact details.

---

## Appendix: Where policy text is served from

The backend has a public endpoint `GET /api/v1/public/privacy-policy` that returns HTML stored in `AppSetting` under key `privacy_policy`. If you publish this app, ensure that stored policy content matches your deployed configuration and actual data flows.

