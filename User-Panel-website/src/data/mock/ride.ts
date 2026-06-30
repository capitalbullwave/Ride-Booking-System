import type { RideVehicleId } from "@/data/ride-options";

export interface RideCaptain {
  name: string;
  rating: number;
  vehicleNumber: string;
  phone: string;
  eta: string;
  vehicleLabel: string;
}

export const mockRideCaptains: Record<RideVehicleId, RideCaptain> = {
  bike: {
    name: "Amit Singh",
    rating: 4.9,
    vehicleNumber: "DL 5S AB 4521",
    phone: "+91 98765 43210",
    eta: "4 mins",
    vehicleLabel: "Honda Activa",
  },
  auto: {
    name: "Suresh Yadav",
    rating: 4.8,
    vehicleNumber: "DL 1R C 8892",
    phone: "+91 98112 33445",
    eta: "5 mins",
    vehicleLabel: "Bajaj RE Electric",
  },
  cab: {
    name: "Vikram Mehta",
    rating: 4.9,
    vehicleNumber: "DL 2C AB 7710",
    phone: "+91 99887 66554",
    eta: "6 mins",
    vehicleLabel: "Maruti Dzire",
  },
  parcel: {
    name: "Ravi Kumar",
    rating: 4.7,
    vehicleNumber: "DL 3P XY 2201",
    phone: "+91 98760 11223",
    eta: "12 mins",
    vehicleLabel: "Delivery Bike",
  },
  travel: {
    name: "Anil Sharma",
    rating: 4.8,
    vehicleNumber: "DL 4T ZZ 5566",
    phone: "+91 98100 44556",
    eta: "25 mins",
    vehicleLabel: "Innova Crysta",
  },
  ambulance: {
    name: "Dr. Karan Patel",
    rating: 4.9,
    vehicleNumber: "DL 9A MB 3344",
    phone: "+91 99999 00011",
    eta: "8 mins",
    vehicleLabel: "BLS Ambulance",
  },
};
