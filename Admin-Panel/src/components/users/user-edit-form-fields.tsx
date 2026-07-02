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
import { UserStatus } from "@/types";

export type UserFormData = {
  name: string;
  mobile: string;
  email: string;
  city: string;
  registrationDate: string;
  status: UserStatus;
};

export function createUserFormData(user: {
  name: string;
  mobile: string;
  email: string;
  city: string;
  registrationDate: string;
  status: UserStatus;
}): UserFormData {
  return {
    name: user.name,
    mobile: user.mobile,
    email: user.email,
    city: user.city,
    registrationDate: user.registrationDate,
    status: user.status,
  };
}

export function UserEditFormFields({
  form,
  onChange,
  idPrefix = "edit",
}: {
  form: UserFormData;
  onChange: (updates: Partial<UserFormData>) => void;
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
        <Label htmlFor={`${idPrefix}-mobile`}>Mobile</Label>
        <Input
          id={`${idPrefix}-mobile`}
          value={form.mobile}
          onChange={(e) => onChange({ mobile: e.target.value })}
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
        <Label htmlFor={`${idPrefix}-registration-date`}>Registration Date</Label>
        <Input
          id={`${idPrefix}-registration-date`}
          type="date"
          value={form.registrationDate}
          onChange={(e) => onChange({ registrationDate: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label>Status</Label>
        <Select
          value={form.status}
          onValueChange={(value) => value && onChange({ status: value as UserStatus })}
        >
          <SelectTrigger>
            <SelectValue placeholder="Select status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="active">Active</SelectItem>
            <SelectItem value="suspended">Suspended</SelectItem>
            <SelectItem value="blocked">Blocked</SelectItem>
            <SelectItem value="inactive">Inactive</SelectItem>
          </SelectContent>
        </Select>
      </div>
    </div>
  );
}
