import type {
  User,
  Driver,
  Ride,
  VehicleCategory,
  Transaction,
  Coupon,
  SupportTicket,
  Notification,
  AdminAlert,
  DashboardStats,
  ChartDataPoint,
  ActivityItem,
  AppSettings,
  DriverDocument,
} from "@/types";

export const dashboardStats: DashboardStats = {
  totalUsers: 128450,
  totalDrivers: 18420,
  activeDrivers: 3240,
  activeRides: 892,
  completedRides: 2456780,
  cancelledRides: 89450,
  todayRevenue: 2847500,
  monthlyRevenue: 68450000,
};

export const rideBookingChartData: ChartDataPoint[] = [
  { name: "Mon", rides: 4200, value: 4200 },
  { name: "Tue", rides: 3800, value: 3800 },
  { name: "Wed", rides: 5100, value: 5100 },
  { name: "Thu", rides: 4600, value: 4600 },
  { name: "Fri", rides: 6200, value: 6200 },
  { name: "Sat", rides: 7800, value: 7800 },
  { name: "Sun", rides: 6900, value: 6900 },
];

export const revenueChartData: ChartDataPoint[] = [
  { name: "Jan", revenue: 52000000, value: 52000000 },
  { name: "Feb", revenue: 48000000, value: 48000000 },
  { name: "Mar", revenue: 61000000, value: 61000000 },
  { name: "Apr", revenue: 55000000, value: 55000000 },
  { name: "May", revenue: 68000000, value: 68000000 },
  { name: "Jun", revenue: 72000000, value: 72000000 },
];

export const userGrowthChartData: ChartDataPoint[] = [
  { name: "Jan", users: 85000, value: 85000 },
  { name: "Feb", users: 92000, value: 92000 },
  { name: "Mar", users: 98000, value: 98000 },
  { name: "Apr", users: 105000, value: 105000 },
  { name: "May", users: 115000, value: 115000 },
  { name: "Jun", users: 128450, value: 128450 },
];

export const driverGrowthChartData: ChartDataPoint[] = [
  { name: "Jan", drivers: 12000, value: 12000 },
  { name: "Feb", drivers: 13200, value: 13200 },
  { name: "Mar", drivers: 14500, value: 14500 },
  { name: "Apr", drivers: 15800, value: 15800 },
  { name: "May", drivers: 17200, value: 17200 },
  { name: "Jun", drivers: 18420, value: 18420 },
];

export const recentActivities: ActivityItem[] = [
  { id: "1", type: "ride_request", title: "New Ride Request", description: "Rajesh K. requested a ride from Koramangala to MG Road", timestamp: "2 min ago", status: "requested" },
  { id: "2", type: "registration", title: "New User Registration", description: "Priya Sharma registered with +91 98765 43210", timestamp: "5 min ago" },
  { id: "3", type: "driver_online", title: "Driver Online", description: "Amit Singh (Bike) is now online in Indiranagar", timestamp: "8 min ago", status: "online" },
  { id: "4", type: "ongoing_ride", title: "Ongoing Ride", description: "Ride #WG-2847 - Whitefield to Electronic City", timestamp: "12 min ago", status: "ride_started" },
  { id: "5", type: "ride_request", title: "New Ride Request", description: "Suresh M. requested a Sedan from Airport to City Center", timestamp: "15 min ago", status: "requested" },
  { id: "6", type: "registration", title: "New Driver Registration", description: "Vikram Patel applied as Auto driver", timestamp: "20 min ago" },
];

export const users: User[] = [
  { id: "USR-001", name: "Rajesh Kumar", mobile: "+91 98765 43210", email: "rajesh.k@email.com", registrationDate: "2024-01-15", totalRides: 156, walletBalance: 1250, status: "active", city: "Bangalore" },
  { id: "USR-002", name: "Priya Sharma", mobile: "+91 87654 32109", email: "priya.s@email.com", registrationDate: "2024-02-20", totalRides: 89, walletBalance: 500, status: "active", city: "Mumbai" },
  { id: "USR-003", name: "Amit Patel", mobile: "+91 76543 21098", email: "amit.p@email.com", registrationDate: "2024-03-10", totalRides: 234, walletBalance: 2100, status: "active", city: "Delhi" },
  { id: "USR-004", name: "Sneha Reddy", mobile: "+91 65432 10987", email: "sneha.r@email.com", registrationDate: "2024-04-05", totalRides: 45, walletBalance: 0, status: "suspended", city: "Hyderabad" },
  { id: "USR-005", name: "Vikram Singh", mobile: "+91 54321 09876", email: "vikram.s@email.com", registrationDate: "2024-05-18", totalRides: 312, walletBalance: 3500, status: "active", city: "Chennai" },
  { id: "USR-006", name: "Anita Desai", mobile: "+91 43210 98765", email: "anita.d@email.com", registrationDate: "2024-06-22", totalRides: 12, walletBalance: 200, status: "blocked", city: "Pune" },
  { id: "USR-007", name: "Rahul Mehta", mobile: "+91 32109 87654", email: "rahul.m@email.com", registrationDate: "2024-07-30", totalRides: 178, walletBalance: 890, status: "active", city: "Bangalore" },
  { id: "USR-008", name: "Kavita Nair", mobile: "+91 21098 76543", email: "kavita.n@email.com", registrationDate: "2024-08-14", totalRides: 67, walletBalance: 450, status: "inactive", city: "Kochi" },
];

export const drivers: Driver[] = [
  { id: "DRV-001", name: "Amit Singh", phone: "+91 98765 11111", email: "amit.s@driver.com", vehicleType: "bike", vehicleNumber: "KA-01-AB-1234", rating: 4.8, totalTrips: 2450, earnings: 485000, walletBalance: 12500, status: "online", city: "Bangalore", joinedDate: "2023-06-15" },
  { id: "DRV-002", name: "Ravi Kumar", phone: "+91 87654 22222", email: "ravi.k@driver.com", vehicleType: "auto", vehicleNumber: "KA-02-CD-5678", rating: 4.6, totalTrips: 1890, earnings: 620000, walletBalance: 8900, status: "busy", city: "Bangalore", joinedDate: "2023-08-20" },
  { id: "DRV-003", name: "Suresh Reddy", phone: "+91 76543 33333", email: "suresh.r@driver.com", vehicleType: "sedan", vehicleNumber: "KA-03-EF-9012", rating: 4.9, totalTrips: 3200, earnings: 1250000, walletBalance: 25000, status: "online", city: "Hyderabad", joinedDate: "2023-04-10" },
  { id: "DRV-004", name: "Mohammed Ali", phone: "+91 65432 44444", email: "mohammed.a@driver.com", vehicleType: "suv", vehicleNumber: "KA-04-GH-3456", rating: 4.7, totalTrips: 1560, earnings: 980000, walletBalance: 15000, status: "offline", city: "Mumbai", joinedDate: "2023-11-05" },
  { id: "DRV-005", name: "Vikram Patel", phone: "+91 54321 55555", email: "vikram.p@driver.com", vehicleType: "mini_cab", vehicleNumber: "KA-05-IJ-7890", rating: 4.5, totalTrips: 890, earnings: 420000, walletBalance: 5600, status: "pending", city: "Pune", joinedDate: "2024-12-01" },
  { id: "DRV-006", name: "Deepak Sharma", phone: "+91 43210 66666", email: "deepak.s@driver.com", vehicleType: "bike", vehicleNumber: "KA-06-KL-1234", rating: 4.3, totalTrips: 560, earnings: 180000, walletBalance: 3200, status: "suspended", city: "Delhi", joinedDate: "2024-02-18" },
  { id: "DRV-007", name: "Kiran Nair", phone: "+91 32109 77777", email: "kiran.n@driver.com", vehicleType: "auto", vehicleNumber: "KA-07-MN-5678", rating: 4.8, totalTrips: 2100, earnings: 710000, walletBalance: 11000, status: "online", city: "Chennai", joinedDate: "2023-09-25" },
  { id: "DRV-008", name: "Sanjay Gupta", phone: "+91 21098 88888", email: "sanjay.g@driver.com", vehicleType: "sedan", vehicleNumber: "KA-08-OP-9012", rating: 4.2, totalTrips: 340, earnings: 145000, walletBalance: 1800, status: "rejected", city: "Kolkata", joinedDate: "2024-10-10" },
];

export const rides: Ride[] = [
  { id: "WG-2847", userId: "USR-001", userName: "Rajesh Kumar", driverId: "DRV-001", driverName: "Amit Singh", vehicleType: "bike", pickupLocation: "Koramangala 5th Block", dropLocation: "MG Road Metro", distance: 8.5, fare: 145, status: "ride_started", date: "2025-06-23T10:30:00", duration: 18, paymentMethod: "Wallet" },
  { id: "WG-2846", userId: "USR-002", userName: "Priya Sharma", driverId: "DRV-003", driverName: "Suresh Reddy", vehicleType: "sedan", pickupLocation: "Bangalore Airport T1", dropLocation: "Electronic City Phase 1", distance: 42.3, fare: 890, status: "ride_completed", date: "2025-06-23T09:15:00", duration: 65, paymentMethod: "UPI" },
  { id: "WG-2845", userId: "USR-003", userName: "Amit Patel", driverId: "DRV-002", driverName: "Ravi Kumar", vehicleType: "auto", pickupLocation: "Indiranagar 100ft Road", dropLocation: "Whitefield ITPL", distance: 15.2, fare: 280, status: "driver_arrived", date: "2025-06-23T08:45:00", paymentMethod: "Cash" },
  { id: "WG-2844", userId: "USR-005", userName: "Vikram Singh", vehicleType: "suv", pickupLocation: "HSR Layout Sector 2", dropLocation: "Marathahalli Bridge", distance: 6.8, fare: 0, status: "cancelled", date: "2025-06-23T08:00:00", paymentMethod: "Card" },
  { id: "WG-2843", userId: "USR-007", userName: "Rahul Mehta", driverId: "DRV-007", driverName: "Kiran Nair", vehicleType: "auto", pickupLocation: "Jayanagar 4th Block", dropLocation: "Lalbagh Main Gate", distance: 4.2, fare: 95, status: "ride_completed", date: "2025-06-22T22:30:00", duration: 12, paymentMethod: "Wallet" },
  { id: "WG-2842", userId: "USR-001", userName: "Rajesh Kumar", driverId: "DRV-001", driverName: "Amit Singh", vehicleType: "bike", pickupLocation: "BTM Layout", dropLocation: "Silk Board", distance: 3.5, fare: 65, status: "ride_completed", date: "2025-06-22T18:00:00", duration: 10, paymentMethod: "UPI" },
  { id: "WG-2841", userId: "USR-004", userName: "Sneha Reddy", vehicleType: "mini_cab", pickupLocation: "Gachibowli", dropLocation: "Hitech City", distance: 5.0, fare: 0, status: "requested", date: "2025-06-23T11:00:00", paymentMethod: "Wallet" },
  { id: "WG-2840", userId: "USR-008", userName: "Kavita Nair", driverId: "DRV-004", driverName: "Mohammed Ali", vehicleType: "suv", pickupLocation: "Bandra West", dropLocation: "Andheri East", distance: 12.0, fare: 450, status: "driver_assigned", date: "2025-06-23T10:50:00", paymentMethod: "Card" },
];

export const vehicleCategories: VehicleCategory[] = [
  { id: "VEH-001", type: "bike", name: "Bike", baseFare: 25, perKmFare: 8, includedDistanceKm: 2, waitingCharge: 2, cancellationCharge: 20, surgeMultiplier: 1.5, isActive: true, icon: "bike" },
  { id: "VEH-002", type: "auto", name: "Auto", baseFare: 35, perKmFare: 12, includedDistanceKm: 2, waitingCharge: 3, cancellationCharge: 30, surgeMultiplier: 1.3, isActive: true, icon: "car" },
  { id: "VEH-003", type: "mini_cab", name: "Mini Cab", baseFare: 50, perKmFare: 15, includedDistanceKm: 2, waitingCharge: 4, cancellationCharge: 50, surgeMultiplier: 1.4, isActive: true, icon: "car" },
  { id: "VEH-004", type: "sedan", name: "Sedan", baseFare: 80, perKmFare: 18, includedDistanceKm: 2, waitingCharge: 5, cancellationCharge: 75, surgeMultiplier: 1.6, isActive: true, icon: "car" },
  { id: "VEH-005", type: "suv", name: "SUV", baseFare: 120, perKmFare: 22, includedDistanceKm: 2, waitingCharge: 6, cancellationCharge: 100, surgeMultiplier: 1.8, isActive: true, icon: "truck" },
];

export const transactions: Transaction[] = [
  { id: "TXN-001", type: "credit", amount: 890, description: "Ride payment - WG-2846", userId: "USR-002", rideId: "WG-2846", status: "completed", date: "2025-06-23T10:20:00", paymentMethod: "UPI" },
  { id: "TXN-002", type: "commission", amount: 89, description: "Platform commission - WG-2846", rideId: "WG-2846", status: "completed", date: "2025-06-23T10:20:00" },
  { id: "TXN-003", type: "payout", amount: 15000, description: "Weekly driver payout", driverId: "DRV-001", status: "pending", date: "2025-06-23T08:00:00", paymentMethod: "Bank Transfer" },
  { id: "TXN-004", type: "refund", amount: 280, description: "Ride cancellation refund - WG-2844", userId: "USR-005", rideId: "WG-2844", status: "completed", date: "2025-06-22T20:00:00" },
  { id: "TXN-005", type: "debit", amount: 500, description: "Wallet top-up", userId: "USR-001", status: "completed", date: "2025-06-22T15:30:00", paymentMethod: "Card" },
  { id: "TXN-006", type: "payout", amount: 25000, description: "Weekly driver payout", driverId: "DRV-003", status: "completed", date: "2025-06-21T08:00:00", paymentMethod: "Bank Transfer" },
];

export const coupons: Coupon[] = [
  { id: "CPN-001", code: "WAVE50", discountType: "percentage", discountValue: 50, maxDiscount: 100, expiryDate: "2025-12-31", usageLimit: 10000, usedCount: 4520, status: "active", createdAt: "2025-01-01" },
  { id: "CPN-002", code: "FIRST100", discountType: "flat", discountValue: 100, maxDiscount: 100, expiryDate: "2025-09-30", usageLimit: 5000, usedCount: 3200, status: "active", createdAt: "2025-03-15" },
  { id: "CPN-003", code: "SUMMER25", discountType: "percentage", discountValue: 25, maxDiscount: 75, expiryDate: "2025-06-30", usageLimit: 2000, usedCount: 2000, status: "expired", createdAt: "2025-05-01" },
  { id: "CPN-004", code: "OLDCODE", discountType: "flat", discountValue: 50, maxDiscount: 50, expiryDate: "2025-12-31", usageLimit: 1000, usedCount: 150, status: "disabled", createdAt: "2024-12-01" },
];

export const supportTickets: SupportTicket[] = [
  {
    id: "TKT-001",
    subject: "Wrong fare charged",
    description: "I was charged more than the estimated fare for my last ride.",
    userType: "user",
    userId: "USR-001",
    userName: "Rajesh Kumar",
    status: "open",
    priority: "high",
    createdAt: "2025-06-23T09:00:00",
    updatedAt: "2025-06-23T10:30:00",
    messages: [
      { id: "m1", sender: "Rajesh Kumar", senderType: "user", message: "I was charged ₹350 but the estimate was ₹280. Please help.", timestamp: "2025-06-23T09:00:00" },
      { id: "m2", sender: "Support Team", senderType: "admin", message: "We're looking into this. Can you share the ride ID?", timestamp: "2025-06-23T09:30:00" },
    ],
  },
  {
    id: "TKT-002",
    subject: "Document verification pending",
    description: "My documents were submitted 5 days ago but still pending.",
    userType: "driver",
    userId: "DRV-005",
    userName: "Vikram Patel",
    status: "in_progress",
    priority: "medium",
    createdAt: "2025-06-22T14:00:00",
    updatedAt: "2025-06-23T08:00:00",
    messages: [
      { id: "m1", sender: "Vikram Patel", senderType: "driver", message: "Please verify my documents urgently.", timestamp: "2025-06-22T14:00:00" },
    ],
  },
  {
    id: "TKT-003",
    subject: "Wallet balance not updated",
    description: "Added ₹500 to wallet but balance shows ₹0.",
    userType: "user",
    userId: "USR-003",
    userName: "Amit Patel",
    status: "resolved",
    priority: "high",
    createdAt: "2025-06-20T11:00:00",
    updatedAt: "2025-06-21T16:00:00",
    messages: [
      { id: "m1", sender: "Amit Patel", senderType: "user", message: "Wallet top-up failed but money was deducted.", timestamp: "2025-06-20T11:00:00" },
      { id: "m2", sender: "Support Team", senderType: "admin", message: "Issue resolved. ₹500 credited to your wallet.", timestamp: "2025-06-21T16:00:00" },
    ],
  },
  {
    id: "TKT-004",
    subject: "App crashing on login",
    description: "App crashes every time I try to login.",
    userType: "driver",
    userId: "DRV-002",
    userName: "Ravi Kumar",
    status: "closed",
    priority: "low",
    createdAt: "2025-06-18T08:00:00",
    updatedAt: "2025-06-19T12:00:00",
    messages: [
      { id: "m1", sender: "Ravi Kumar", senderType: "driver", message: "Updated app and now it crashes.", timestamp: "2025-06-18T08:00:00" },
    ],
  },
];

export const notifications: Notification[] = [
  { id: "NOT-001", title: "Monsoon Offer!", message: "Get 30% off on your next 3 rides. Use code MONSOON30", target: "all_users", type: "promotional", channels: ["push", "email"], sentAt: "2025-06-20T10:00:00", recipientCount: 128450 },
  { id: "NOT-002", title: "Peak Hour Surge Active", message: "Surge pricing is active in your area. Higher earnings guaranteed!", target: "all_drivers", type: "ride_alert", channels: ["push"], sentAt: "2025-06-23T08:00:00", recipientCount: 3240 },
  { id: "NOT-003", title: "Scheduled Maintenance", message: "App maintenance on June 25, 2AM-4AM IST", target: "all_users", type: "system_alert", channels: ["push", "sms", "email"], sentAt: "2025-06-22T18:00:00", recipientCount: 146870 },
];

/** Admin inbox alerts — platform events for the logged-in admin (not outbound campaigns). */
export const adminAlerts: AdminAlert[] = [
  {
    id: "ALT-001",
    title: "New driver registration",
    message: "Vikram Patel applied as an Auto driver in Pune. Documents pending verification.",
    type: "driver_registration",
    time: "2 min ago",
    createdAt: "2025-06-23T11:28:00",
    unread: true,
    href: "/drivers/DRV-005",
  },
  {
    id: "ALT-002",
    title: "Ride #WG-2847 completed",
    message: "Ride from Koramangala to MG Road completed. Fare ₹145 collected via Wallet.",
    type: "ride_update",
    time: "15 min ago",
    createdAt: "2025-06-23T11:15:00",
    unread: true,
    href: "/rides/WG-2847",
  },
  {
    id: "ALT-003",
    title: "Support ticket #TKT-001 opened",
    message: "Rajesh Kumar reported a wrong fare charge. Priority: High.",
    type: "support_ticket",
    time: "1 hour ago",
    createdAt: "2025-06-23T10:30:00",
    unread: true,
    href: "/support/TKT-001",
  },
  {
    id: "ALT-004",
    title: "Weekly report ready",
    message: "Your weekly ride and revenue report for 16–22 Jun is ready to download.",
    type: "report",
    time: "3 hours ago",
    createdAt: "2025-06-23T08:30:00",
    unread: false,
    href: "/reports",
  },
  {
    id: "ALT-005",
    title: "Payout batch pending",
    message: "156 driver payouts totalling ₹24,50,000 are awaiting approval.",
    type: "payment",
    time: "5 hours ago",
    createdAt: "2025-06-23T06:00:00",
    unread: false,
    href: "/finance/payouts",
  },
  {
    id: "ALT-006",
    title: "System health check passed",
    message: "All WaveGo services are operational. Last checked at 6:00 AM IST.",
    type: "system",
    time: "Yesterday",
    createdAt: "2025-06-22T06:00:00",
    unread: false,
  },
];

export const driverDocuments: DriverDocument[] = [
  { id: "DOC-001", type: "aadhaar", name: "Aadhaar Card", status: "approved", uploadedAt: "2024-11-28" },
  { id: "DOC-002", type: "pan", name: "PAN Card", status: "approved", uploadedAt: "2024-11-28" },
  { id: "DOC-003", type: "driving_license", name: "Driving License", status: "approved", uploadedAt: "2024-11-29" },
  { id: "DOC-004", type: "rc", name: "Registration Certificate", status: "pending", uploadedAt: "2024-12-01" },
  { id: "DOC-005", type: "insurance", name: "Vehicle Insurance", status: "pending", uploadedAt: "2024-12-01" },
  { id: "DOC-006", type: "vehicle_image", name: "Vehicle Images", status: "approved", uploadedAt: "2024-11-30" },
  { id: "DOC-007", type: "profile_photo", name: "Profile Photo", status: "approved", uploadedAt: "2024-11-28" },
];

export const appSettings: AppSettings = {
  appName: "WaveGo",
  logo: "/logo.svg",
  contactEmail: "support@wavego.com",
  contactPhone: "+91 1800-WAVE-GO",
  googleMapsApiKey: "AIza••••••••••••••••",
  firebaseConfig: `{
  "apiKey": "your-firebase-api-key",
  "authDomain": "wavego-prod.firebaseapp.com",
  "projectId": "wavego-prod",
  "storageBucket": "wavego-prod.appspot.com",
  "messagingSenderId": "123456789",
  "appId": "1:123456789:web:abcdef"
}`,
  razorpayKey: "rzp_live_••••••••",
  stripeKey: "sk_live_••••••••",
  driverCommission: 80,
  platformFee: 20,
};

export function getUserById(id: string): User | undefined {
  return users.find((u) => u.id === id);
}

export function getDriverById(id: string): Driver | undefined {
  return drivers.find((d) => d.id === id);
}

export function getRideById(id: string): Ride | undefined {
  return rides.find((r) => r.id === id);
}

export function getTicketById(id: string): SupportTicket | undefined {
  return supportTickets.find((t) => t.id === id);
}
