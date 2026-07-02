"use client";

import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { DriverStatus } from "@/types";

export type DriverFormData = {
  name: string;
  phone: string;
  email: string;
  city: string;
  joinedDate: string;
  status: DriverStatus;
};

export function createDriverFormData(driver: {
  name: string;
  phone: string;
  email: string;
  city: string;
  joinedDate: string;
  status: DriverStatus;
}): DriverFormData {
  return {
    name: driver.name,
    phone: driver.phone,
    email: driver.email,
    city: driver.city,
    joinedDate: driver.joinedDate,
    status: driver.status,
  };
}

export function DriverEditFormFields({
  form,
  onChange,
  idPrefix = "edit",
}: {
  form: DriverFormData;
  onChange: (updates: Partial<DriverFormData>) => void;
  idPrefix?: string;
}) {
  return (
    <div className="grid gap-4 py-2 sm:grid-cols-2">
      <div className="space-y-2 sm:col-span-2">
        <Label htmlFor={`${idPrefix}-name`}>Full Name</Label>
        <Input
          id={`${idPrefix}-name`}
          value={form.name}
          onChange={(e) => onChange({ name: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-email`}>Email</Label>
        <Input
          id={`${idPrefix}-email`}
          type="email"
          value={form.email}
          onChange={(e) => onChange({ email: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-phone`}>Phone</Label>
        <Input
          id={`${idPrefix}-phone`}
          value={form.phone}
          onChange={(e) => onChange({ phone: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-city`}>City</Label>
        <Input
          id={`${idPrefix}-city`}
          value={form.city}
          onChange={(e) => onChange({ city: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-joined-date`}>Joined Date</Label>
        <Input
          id={`${idPrefix}-joined-date`}
          type="date"
          value={form.joinedDate}
          onChange={(e) => onChange({ joinedDate: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label>Status</Label>
        <Select
          value={form.status}
          onValueChange={(value) => value && onChange({ status: value as DriverStatus })}
        >
          <SelectTrigger>
            <SelectValue placeholder="Select status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="online">Online</SelectItem>
            <SelectItem value="offline">Offline</SelectItem>
            <SelectItem value="busy">Busy</SelectItem>
            <SelectItem value="pending">Pending</SelectItem>
            <SelectItem value="suspended">Suspended</SelectItem>
            <SelectItem value="rejected">Rejected</SelectItem>
          </SelectContent>
        </Select>
      </div>
    </div>
  );
}
