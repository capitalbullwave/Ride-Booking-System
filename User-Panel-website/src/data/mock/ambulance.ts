import type { AmbulanceType, AssignedDriver, EmergencyHistoryItem, Hospital } from "@/types/ambulance";

export const mockAmbulanceTypes: AmbulanceType[] = [
  {
    id: "bls",
    name: "Basic Life Support (BLS)",
    description: "For non-critical patient transport. Includes oxygen, bed, and basic first aid.",
    eta: "5-10 mins",
    price: "₹800",
    icon: "Stethoscope",
  },
  {
    id: "als",
    name: "Advanced Life Support (ALS)",
    description: "For serious medical emergencies. Includes ECG, ventilator, and trained paramedic.",
    eta: "8-12 mins",
    price: "₹2500",
    icon: "HeartPulse",
  },
  {
    id: "icu",
    name: "ICU Ambulance",
    description: "Mobile intensive care support. Fully equipped with specialized doctors.",
    eta: "10-15 mins",
    price: "₹5000",
    icon: "Activity",
  },
  {
    id: "air",
    name: "Air Ambulance",
    description: "Long-distance emergency transport via helicopter or aircraft.",
    eta: "45-60 mins",
    price: "₹1,50,000",
    icon: "Plane",
  },
];

export const mockHospitals: Hospital[] = [
  {
    id: "h1",
    name: "City General Hospital",
    distance: "2.4 km",
    rating: 4.5,
    emergencyAvailable: true,
    icuAvailable: true,
    type: "Government",
    address: "142 Medical District, Downtown",
    lat: 19.0760,
    lng: 72.8777,
  },
  {
    id: "h2",
    name: "Apollo Lifeline Care",
    distance: "3.1 km",
    rating: 4.8,
    emergencyAvailable: true,
    icuAvailable: true,
    type: "Private",
    address: "Sector 4, Elite Road",
    lat: 19.0800,
    lng: 72.8800,
  },
  {
    id: "h3",
    name: "Metro Wellness Center",
    distance: "5.0 km",
    rating: 4.2,
    emergencyAvailable: true,
    icuAvailable: false,
    type: "Private",
    address: "88 Harmony Street, Westside",
    lat: 19.0850,
    lng: 72.8750,
  },
  {
    id: "h4",
    name: "State Trauma Center",
    distance: "6.2 km",
    rating: 4.6,
    emergencyAvailable: true,
    icuAvailable: true,
    type: "Government",
    address: "Highway 9, East End",
    lat: 19.0700,
    lng: 72.8850,
  },
];

export const mockAssignedDriver = {
  name: "Rajesh Kumar",
  rating: 4.9,
  vehicleNumber: "MH 04 AB 1234",
  phone: "+91 98765 43210",
  eta: "7 mins",
};

export const mockPastEmergencies = [
  {
    id: "EMG-8472",
    date: "12 May 2026, 14:30",
    patientName: "Anjali Sharma",
    ambulanceType: "Basic Life Support (BLS)",
    hospital: "City General Hospital",
    status: "Completed",
    invoice: "₹850",
  },
  {
    id: "EMG-6190",
    date: "04 Mar 2026, 02:15",
    patientName: "Rahul Verma",
    ambulanceType: "Advanced Life Support (ALS)",
    hospital: "Apollo Lifeline Care",
    status: "Completed",
    invoice: "₹2600",
  },
];
