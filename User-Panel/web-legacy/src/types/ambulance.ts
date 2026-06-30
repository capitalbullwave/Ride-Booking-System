export interface Hospital {
  id: string;
  name: string;
  distance: string;
  rating: number;
  emergencyAvailable: boolean;
  icuAvailable: boolean;
  type: "Government" | "Private";
  address: string;
  lat: number;
  lng: number;
}

export interface AmbulanceType {
  id: string;
  name: string;
  description: string;
  eta: string;
  price: string;
  icon: string;
}

export interface PatientDetails {
  patientName: string;
  patientAge: string;
  mobileNumber: string;
  emergencyContact: string;
  pickupAddress: string;
  emergencyType: string;
  notes: string;
}

export interface AssignedDriver {
  name: string;
  rating: number;
  vehicleNumber: string;
  phone: string;
  eta: string;
}

export interface EmergencyHistoryItem {
  id: string;
  date: string;
  patientName: string;
  ambulanceType: string;
  hospital: string;
  status: string;
  invoice: string;
}
