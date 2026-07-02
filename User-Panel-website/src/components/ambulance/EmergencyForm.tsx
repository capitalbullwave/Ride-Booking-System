"use client";

import { useForm } from "react-hook-form";
import { useAmbulanceStore } from "@/store/useAmbulanceStore";
import { useRouter } from "next/navigation";
import { MapPin, User, Phone, Activity } from "lucide-react";
import type { PatientDetails } from "@/types/ambulance";

const emergencyTypes = [
  "Accident",
  "Cardiac Emergency",
  "Pregnancy",
  "Trauma",
  "Stroke",
  "General Emergency",
  "Other",
];

export function EmergencyForm() {
  const router = useRouter();
  const { patientDetails, setPatientDetails, selectedHospital } = useAmbulanceStore();
  
  const { register, handleSubmit, formState: { errors } } = useForm<PatientDetails>({
    defaultValues: patientDetails,
  });

  const onSubmit = (data: PatientDetails) => {
    setPatientDetails(data);
    router.push("/ambulance/request");
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-6">
      {/* Patient Information */}
      <div className="flex flex-col gap-4 rounded-[20px] border border-border bg-white p-5 shadow-sm">
        <h3 className="font-heading font-bold text-foreground flex items-center gap-2">
          <User className="h-5 w-5 text-[#D66B6B]" />
          Patient Details
        </h3>
        
        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-2 space-y-1">
            <label className="text-xs font-semibold text-muted-foreground">Patient Name</label>
            <input 
              {...register("patientName", { required: "Required" })}
              className="w-full rounded-[14px] border border-border bg-muted/30 px-4 py-3 text-sm focus:border-primary focus:bg-white outline-none transition-colors"
              placeholder="Full Name"
            />
            {errors.patientName && <span className="text-[10px] text-destructive">{errors.patientName.message as string}</span>}
          </div>

          <div className="space-y-1">
            <label className="text-xs font-semibold text-muted-foreground">Age</label>
            <input 
              type="number"
              {...register("patientAge", { required: "Required" })}
              className="w-full rounded-[14px] border border-border bg-muted/30 px-4 py-3 text-sm focus:border-primary focus:bg-white outline-none transition-colors"
              placeholder="Age"
            />
          </div>

          <div className="space-y-1">
            <label className="text-xs font-semibold text-muted-foreground">Mobile</label>
            <input 
              {...register("mobileNumber", { required: "Required" })}
              className="w-full rounded-[14px] border border-border bg-muted/30 px-4 py-3 text-sm focus:border-primary focus:bg-white outline-none transition-colors"
              placeholder="+91"
            />
          </div>
          
          <div className="col-span-2 space-y-1">
            <label className="text-xs font-semibold text-muted-foreground flex items-center gap-1">
              <Phone className="h-3 w-3" /> Emergency Contact
            </label>
            <input 
              {...register("emergencyContact", { required: "Required" })}
              className="w-full rounded-[14px] border border-border bg-muted/30 px-4 py-3 text-sm focus:border-primary focus:bg-white outline-none transition-colors"
              placeholder="Relative's Phone Number"
            />
          </div>
        </div>
      </div>

      {/* Emergency Type */}
      <div className="flex flex-col gap-4 rounded-[20px] border border-border bg-white p-5 shadow-sm">
        <h3 className="font-heading font-bold text-foreground flex items-center gap-2">
          <Activity className="h-5 w-5 text-[#D66B6B]" />
          Emergency Type
        </h3>
        
        <div className="space-y-1">
          <select 
            {...register("emergencyType", { required: "Please select an emergency type" })}
            className="w-full rounded-[14px] border border-border bg-muted/30 px-4 py-3 text-sm focus:border-primary focus:bg-white outline-none transition-colors"
          >
            <option value="">Select condition...</option>
            {emergencyTypes.map(type => (
              <option key={type} value={type}>{type}</option>
            ))}
          </select>
          {errors.emergencyType && <span className="text-[10px] text-destructive">{errors.emergencyType.message as string}</span>}
        </div>
        
        <div className="space-y-1">
          <label className="text-xs font-semibold text-muted-foreground">Additional Notes (Optional)</label>
          <textarea 
            {...register("notes")}
            className="w-full rounded-[14px] border border-border bg-muted/30 px-4 py-3 text-sm focus:border-primary focus:bg-white outline-none transition-colors min-h-[80px]"
            placeholder="Any specific instructions or medical history..."
          />
        </div>
      </div>

      {/* Location Details (Readonly) */}
      <div className="flex flex-col gap-4 rounded-[20px] border border-border bg-white p-5 shadow-sm">
        <h3 className="font-heading font-bold text-foreground flex items-center gap-2">
          <MapPin className="h-5 w-5 text-[#D66B6B]" />
          Location Details
        </h3>
        
        <div className="space-y-3">
          <div>
            <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Pickup From</p>
            <p className="text-sm font-semibold">{patientDetails.pickupAddress}</p>
          </div>
          <div className="h-[1px] w-full bg-border" />
          <div>
            <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Destination Hospital</p>
            <p className="text-sm font-semibold text-primary">{selectedHospital?.name}</p>
            <p className="text-xs text-muted-foreground">{selectedHospital?.address}</p>
          </div>
        </div>
      </div>

      {/* Submit Button */}
      <button 
        type="submit"
        className="mt-4 w-full rounded-[16px] bg-primary py-4 font-bold text-white shadow-lg transition-all hover:bg-primary/90 active:scale-95"
      >
        Review & Confirm Booking
      </button>
    </form>
  );
}
