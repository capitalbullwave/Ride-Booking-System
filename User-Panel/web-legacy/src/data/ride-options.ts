export type RideVehicleId =
  | "bike"
  | "auto"
  | "cab"
  | "parcel"
  | "travel"
  | "ambulance";

export interface RideVehicleOption {
  id: RideVehicleId;
  name: string;
  eta: string;
  price: number;
  tagline: string;
  image: string;
}

export const RIDE_VEHICLE_OPTIONS: RideVehicleOption[] = [
  {
    id: "bike",
    name: "Bike-Taxi",
    eta: "6 mins",
    price: 256,
    tagline: "Beat the traffic, save money",
    image: "/images/services/bike.png",
  },
  {
    id: "auto",
    name: "Electric Auto",
    eta: "6 mins",
    price: 433,
    tagline: "No haggling, just easy rides",
    image: "/images/services/auto.png",
  },
  {
    id: "cab",
    name: "Cab",
    eta: "8 mins",
    price: 520,
    tagline: "Comfortable rides for you",
    image: "/images/services/car.png",
  },
  {
    id: "parcel",
    name: "Parcel",
    eta: "15 mins",
    price: 189,
    tagline: "Quick, secure & insured deliveries",
    image: "/images/services/parcel.png",
  },
  {
    id: "travel",
    name: "Travel and Stay",
    eta: "30 mins",
    price: 1200,
    tagline: "One app, all solutions",
    image: "/images/services/travel.png",
  },
  {
    id: "ambulance",
    name: "Ambulance",
    eta: "10 mins",
    price: 800,
    tagline: "Emergency medical transport",
    image: "/images/services/ambulance.png",
  },
];

export const PAYMENT_METHODS = [
  { id: "cash", label: "Payment via cash" },
  { id: "wallet", label: "Payment via Bull Wave Rides Wallet" },
] as const;

export const RIDE_VEHICLE_IDS: RideVehicleId[] = RIDE_VEHICLE_OPTIONS.map((v) => v.id);
