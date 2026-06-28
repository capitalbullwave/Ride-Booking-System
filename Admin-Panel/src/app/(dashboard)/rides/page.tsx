"use client";

import { useState, useMemo } from "react";
import { Eye } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { SearchBar } from "@/components/shared/search-bar";
import { ExportButton } from "@/components/shared/export-button";
import { DataTable, Column } from "@/components/shared/data-table";
import { StatusBadge } from "@/components/shared/status-badge";
import { ButtonLink } from "@/components/ui/button-link";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { rides } from "@/data/mock-data";
import { Ride } from "@/types";
import { formatCurrency, formatDateTime, capitalize } from "@/lib/format";

export default function RidesPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");

  const filteredRides = useMemo(() => {
    return rides.filter((ride) => {
      const matchesSearch =
        ride.id.toLowerCase().includes(search.toLowerCase()) ||
        ride.userName.toLowerCase().includes(search.toLowerCase()) ||
        (ride.driverName?.toLowerCase().includes(search.toLowerCase()) ?? false) ||
        ride.pickupLocation.toLowerCase().includes(search.toLowerCase());
      const matchesStatus = statusFilter === "all" || ride.status === statusFilter;
      return matchesSearch && matchesStatus;
    });
  }, [search, statusFilter]);

  const columns: Column<Ride>[] = [
    { key: "id", header: "Ride ID", cell: (r) => <span className="font-mono text-xs">{r.id}</span>, sortable: true },
    { key: "userName", header: "User", cell: (r) => r.userName, sortable: true },
    { key: "driverName", header: "Driver", cell: (r) => r.driverName ?? "—" },
    { key: "vehicleType", header: "Vehicle", cell: (r) => capitalize(r.vehicleType) },
    { key: "pickupLocation", header: "Pickup", cell: (r) => <span className="max-w-[150px] truncate block">{r.pickupLocation}</span> },
    { key: "dropLocation", header: "Drop", cell: (r) => <span className="max-w-[150px] truncate block">{r.dropLocation}</span> },
    { key: "distance", header: "Distance", cell: (r) => `${r.distance} km`, sortable: true },
    { key: "fare", header: "Fare", cell: (r) => formatCurrency(r.fare), sortable: true },
    { key: "status", header: "Status", cell: (r) => <StatusBadge status={r.status} /> },
    { key: "date", header: "Date", cell: (r) => formatDateTime(r.date), sortable: true },
    {
      key: "actions",
      header: "Actions",
      cell: (r) => (
        <ButtonLink variant="ghost" size="icon" className="h-8 w-8" href={`/rides/${r.id}`}>
          <Eye className="h-4 w-4" />
        </ButtonLink>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader title="Ride Management" description="Monitor and manage all ride bookings">
        <ExportButton filename="wavego-rides" />
      </PageHeader>

      <div className="flex flex-col gap-4 sm:flex-row">
        <SearchBar placeholder="Search rides..." value={search} onChange={setSearch} className="flex-1" />
        <Select value={statusFilter} onValueChange={(v) => v && setStatusFilter(v)}>
          <SelectTrigger className="w-full sm:w-48">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="requested">Requested</SelectItem>
            <SelectItem value="driver_assigned">Driver Assigned</SelectItem>
            <SelectItem value="driver_arrived">Driver Arrived</SelectItem>
            <SelectItem value="ride_started">Ride Started</SelectItem>
            <SelectItem value="ride_completed">Completed</SelectItem>
            <SelectItem value="cancelled">Cancelled</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <DataTable data={filteredRides} columns={columns} />
    </div>
  );
}
