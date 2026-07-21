export type UserStatus = "active" | "suspended" | "blocked" | "inactive";
export type DriverStatus = "online" | "offline" | "busy" | "suspended" | "pending" | "rejected";
export type RideStatus =
  | "requested"
  | "driver_assigned"
  | "driver_arrived"
  | "ride_started"
  | "ride_completed"
  | "cancelled";
export type VehicleType = "bike" | "auto" | "mini_cab" | "sedan" | "suv";
export type TicketStatus = "open" | "in_progress" | "resolved" | "closed";
export type CouponStatus = "active" | "expired" | "disabled";
export type DiscountType = "percentage" | "flat";
export type TransactionType = "credit" | "debit" | "refund" | "payout" | "commission";
export type DocumentStatus = "pending" | "approved" | "rejected";
export type NotificationTarget = "all_users" | "all_drivers" | "specific_users";
export type NotificationType = "promotional" | "ride_alert" | "system_alert";
export type NotificationChannel = "push" | "sms" | "email";

export interface User {
  id: string;
  publicId?: string;
  name: string;
  mobile: string;
  email: string;
  registrationDate: string;
  totalRides: number;
  walletBalance: number;
  status: UserStatus;
  avatar?: string;
  gender?: string;
  rating: number;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
}

export interface Driver {
  id: string;
  publicId?: string;
  name: string;
  phone: string;
  email: string;
  vehicleType: VehicleType;
  vehicleNumber: string;
  vehicleBrand?: string;
  vehicleModel?: string;
  vehicleColor?: string;
  vehicleYear?: number | null;
  vehicleStatus?: string;
  rating: number;
  totalTrips: number;
  earnings: number;
  walletBalance: number;
  status: DriverStatus;
  avatar?: string;
  city: string;
  state?: string;
  country?: string;
  pinCode?: string;
  address?: string;
  licenseNumber?: string;
  dateOfBirth?: string | null;
  gender?: string;
  kycStatus?: string;
  isVerified?: boolean;
  referralCode?: string;
  joinedDate: string;
  bankDetails?: {
    accountHolder: string;
    accountNumber: string;
    ifsc: string;
    bankName: string;
    upiId?: string;
    isVerified?: boolean;
    isMasked?: boolean;
  };
}

export interface DriverDocument {
  id: string;
  type: string;
  name: string;
  status: DocumentStatus;
  uploadedAt: string;
  url?: string;
  documentNumber?: string | null;
  rejectionReason?: string | null;
  expiryDate?: string | null;
}

export interface RideStop {
  address: string;
  lat: number;
  lng: number;
  sequence?: number;
}

export interface Ride {
  id: string;
  publicId?: string;
  userId: string;
  userPublicId?: string;
  userName: string;
  driverId?: string;
  driverPublicId?: string;
  driverName?: string;
  vehicleType: VehicleType;
  pickupLocation: string;
  pickupLat?: number;
  pickupLng?: number;
  dropLocation: string;
  dropLat?: number;
  dropLng?: number;
  /** Intermediate stops between pickup and drop (max 3). */
  stops?: RideStop[];
  distance: number;
  fare: number;
  driverCommissionPercentage?: number;
  driverEarning?: number;
  companyEarning?: number;
  status: RideStatus;
  date: string;
  duration?: number;
  paymentMethod: string;
  rideType?: string;
  paymentSource?: string | null;
  companyId?: string | null;
  companyName?: string | null;
  companyCode?: string | null;
  employeeId?: string | null;
  employeeCode?: string | null;
  employeeDepartment?: string | null;
  employeeDesignation?: string | null;
}

export interface VehicleCategory {
  id: string;
  type: VehicleType;
  name: string;
  description?: string | null;
  baseFare: number;
  perKmFare: number;
  includedDistanceKm: number;
  includedHours?: number;
  perHourRate?: number;
  waitingCharge: number;
  cancellationCharge: number;
  surgeMultiplier: number;
  isActive: boolean;
  icon: string;
  imageUrl?: string | null;
  serviceGroup?: "ride" | "rental" | string;
  capacity?: number;
  displayOrder?: number;
}

export interface Transaction {
  id: string;
  type: TransactionType;
  amount: number;
  description: string;
  userId?: string;
  driverId?: string;
  rideId?: string;
  status: "completed" | "pending" | "failed";
  date: string;
  paymentMethod?: string;
}

export interface Coupon {
  id: string;
  code: string;
  discountType: DiscountType;
  discountValue: number;
  maxDiscount: number;
  expiryDate: string;
  usageLimit: number;
  usedCount: number;
  status: CouponStatus;
  createdAt: string;
}

export interface SupportTicket {
  id: string;
  subject: string;
  description: string;
  userType: "user" | "driver";
  userId: string;
  userName: string;
  status: TicketStatus;
  priority: "low" | "medium" | "high";
  createdAt: string;
  updatedAt: string;
  messages: TicketMessage[];
}

export interface TicketMessage {
  id: string;
  sender: string;
  senderType: "user" | "driver" | "admin";
  message: string;
  timestamp: string;
  attachments?: string[];
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  target: NotificationTarget;
  type: NotificationType;
  channels: NotificationChannel[];
  sentAt: string;
  recipientCount: number;
}

export type AdminAlertType =
  | "driver_registration"
  | "ride_update"
  | "support_ticket"
  | "report"
  | "payment"
  | "system";

export interface AdminAlert {
  id: string;
  title: string;
  message: string;
  type: AdminAlertType;
  time: string;
  createdAt: string;
  unread: boolean;
  href?: string;
}

export interface DashboardStats {
  totalUsers: number;
  totalDrivers: number;
  activeDrivers: number;
  activeRides: number;
  completedRides: number;
  cancelledRides: number;
  todayRevenue: number;
  monthlyRevenue: number;
  totalRevenue: number;
  driverEarningsToday: number;
  companyEarningsToday: number;
  totalCommissionPaid: number;
  driverCommissionPercentage: number;
}

export interface ChartDataPoint {
  name: string;
  value: number;
  rides?: number;
  revenue?: number;
  users?: number;
  drivers?: number;
}

export interface ActivityItem {
  id: string;
  type: "ride_request" | "registration" | "driver_online" | "ongoing_ride";
  title: string;
  description: string;
  timestamp: string;
  status?: string;
}

export interface AppSettings {
  appName: string;
  logo: string;
  contactEmail: string;
  contactPhone: string;
  googleMapsApiKey: string;
  firebaseConfig: string;
  cashfreeAppId: string;
  cashfreeSecretKey: string;
  stripeKey: string;
  driverCommission: number;
  platformFee: number;
}
