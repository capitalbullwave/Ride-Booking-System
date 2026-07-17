import { create } from "zustand";
import type { AmbulanceType, Hospital, PatientDetails } from "@/types/ambulance";

interface AmbulanceStore {
  selectedType: AmbulanceType | null;
  selectedHospital: Hospital | null;
  patientDetails: PatientDetails;

  setType: (type: AmbulanceType) => void;
  setHospital: (hospital: Hospital) => void;
  setPatientDetails: (details: Partial<PatientDetails>) => void;
  resetStore: () => void;
}

const initialPatientDetails: PatientDetails = {
  patientName: "",
  patientAge: "",
  mobileNumber: "",
  emergencyContact: "",
  pickupAddress: "Current GPS Location",
  emergencyType: "",
  notes: "",
};

export const useAmbulanceStore = create<AmbulanceStore>((set) => ({
  selectedType: null,
  selectedHospital: null,
  patientDetails: initialPatientDetails,

  setType: (type) => set({ selectedType: type }),
  setHospital: (hospital) => set({ selectedHospital: hospital }),
  setPatientDetails: (details) =>
    set((state) => ({
      patientDetails: { ...state.patientDetails, ...details },
    })),
  resetStore: () =>
    set({
      selectedType: null,
      selectedHospital: null,
      patientDetails: initialPatientDetails,
    }),
}));

export type { AmbulanceType, Hospital, PatientDetails };
