"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Bike, Car, ImagePlus, Loader2, Pencil, Plus, Trash2, Truck } from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { ButtonLink } from "@/components/ui/button-link";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { VehicleCategory } from "@/types";
import {
  createVehicleCategory,
  deleteVehicleCategory,
  listVehicleCategories,
  updateVehicleCategory,
} from "@/lib/vehicles-api";
import { resolveMediaUrl } from "@/lib/api";
import { toast } from "sonner";

function getCategoryImageUrl(category: VehicleCategory): string | null {
  if (category.imageUrl) return resolveMediaUrl(category.imageUrl);
  const icon = category.icon ?? "";
  if (icon.startsWith("/uploads") || icon.startsWith("http://") || icon.startsWith("https://")) {
    return resolveMediaUrl(icon);
  }
  return null;
}

const vehicleIcons: Record<string, typeof Bike> = {
  bike: Bike,
  auto: Car,
  mini_cab: Car,
  sedan: Car,
  suv: Truck,
  car: Car,
  truck: Truck,
};

type VehicleFormData = {
  name: string;
  description: string;
  icon: string;
  baseFare: string;
  perKmFare: string;
  includedDistanceKm: string;
  includedHours: string;
  perHourRate: string;
  waitingCharge: string;
  cancellationCharge: string;
  capacity: string;
  isActive: boolean;
  image: string | null;
  existingImageUrl: string | null;
};

const emptyForm: VehicleFormData = {
  name: "",
  description: "",
  icon: "car",
  baseFare: "25",
  perKmFare: "10",
  includedDistanceKm: "2",
  includedHours: "0",
  perHourRate: "0",
  waitingCharge: "2",
  cancellationCharge: "20",
  capacity: "4",
  isActive: true,
  image: null,
  existingImageUrl: null,
};

type ServiceTab = "ride" | "rental";

const emptyRentalForm: VehicleFormData = {
  ...emptyForm,
  icon: "bike",
  baseFare: "299",
  perKmFare: "8",
  includedDistanceKm: "40",
  includedHours: "4",
  perHourRate: "50",
  waitingCharge: "0",
  description: "Flexible daily rental packages",
};

function categoryToForm(category: VehicleCategory): VehicleFormData {
  return {
    name: category.name,
    description: category.description ?? "",
    icon: category.icon,
    baseFare: String(category.baseFare),
    perKmFare: String(category.perKmFare),
    includedDistanceKm: String(category.includedDistanceKm ?? 2),
    includedHours: String(category.includedHours ?? (category.serviceGroup === "rental" ? 4 : 0)),
    perHourRate: String(category.perHourRate ?? 0),
    waitingCharge: String(category.waitingCharge),
    cancellationCharge: String(category.cancellationCharge ?? 20),
    capacity: String(category.capacity ?? 4),
    isActive: category.isActive,
    image: null,
    existingImageUrl: category.imageUrl ?? null,
  };
}

function VehicleFormFields({
  form,
  onChange,
  imageInputRef,
  onImageChange,
  showStatus = false,
  isRental = false,
}: {
  form: VehicleFormData;
  onChange: (updates: Partial<VehicleFormData>) => void;
  imageInputRef: React.RefObject<HTMLInputElement | null>;
  onImageChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  showStatus?: boolean;
  isRental?: boolean;
}) {
  const previewImage =
    form.image ?? (form.existingImageUrl ? resolveMediaUrl(form.existingImageUrl) : null);

  return (
    <div className="grid gap-4 py-2">
      <div className="space-y-2">
        <Label>Vehicle Name</Label>
        <Input
          placeholder="e.g. Mini Cab"
          value={form.name}
          onChange={(e) => onChange({ name: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label>Description</Label>
        <Input
          placeholder="Short description for users"
          value={form.description}
          onChange={(e) => onChange({ description: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label>{isRental ? "Rental Type" : "Icon Type"}</Label>
        <Select value={form.icon} onValueChange={(v) => v && onChange({ icon: v })}>
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {isRental ? (
              <>
                <SelectItem value="bike">Bike</SelectItem>
                <SelectItem value="car">Car</SelectItem>
              </>
            ) : (
              <>
                <SelectItem value="bike">Bike</SelectItem>
                <SelectItem value="auto">Auto</SelectItem>
                <SelectItem value="car">Car / Cab</SelectItem>
                <SelectItem value="truck">SUV / XL</SelectItem>
              </>
            )}
          </SelectContent>
        </Select>
      </div>
      <div className="space-y-2">
        <Label>Passenger Capacity</Label>
        <Input
          type="number"
          min="1"
          max="20"
          value={form.capacity}
          onChange={(e) => onChange({ capacity: e.target.value })}
          placeholder="e.g. 4"
        />
        <p className="text-xs text-muted-foreground">
          Shown on user panel when choosing a ride (person icon + number)
        </p>
      </div>
      <div className="space-y-2">
        <Label>Vehicle Image (optional)</Label>
        <input
          ref={imageInputRef}
          type="file"
          accept="image/*"
          className="hidden"
          onChange={onImageChange}
        />
        <button
          type="button"
          onClick={() => imageInputRef.current?.click()}
          className="flex w-full items-center gap-4 rounded-xl border border-dashed border-border bg-muted/30 p-4 text-left transition-colors hover:bg-muted/50"
        >
          {previewImage ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={previewImage} alt="Vehicle preview" className="h-16 w-16 rounded-lg object-cover" />
          ) : (
            <div className="flex h-16 w-16 items-center justify-center rounded-lg bg-primary/10">
              <ImagePlus className="h-6 w-6 text-primary" />
            </div>
          )}
          <div>
            <p className="font-medium">Upload vehicle image</p>
            <p className="text-sm text-muted-foreground">
              Shown on user home, booking, and service tiles
            </p>
          </div>
        </button>
      </div>
      {isRental ? (
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          <div className="space-y-2">
            <Label>Base Rate (₹)</Label>
            <Input
              type="number"
              value={form.baseFare}
              onChange={(e) => onChange({ baseFare: e.target.value })}
            />
          </div>
          <div className="space-y-2">
            <Label>Minimum Hours</Label>
            <Input
              type="number"
              min="0"
              step="0.5"
              value={form.includedHours}
              onChange={(e) => onChange({ includedHours: e.target.value })}
            />
          </div>
          <div className="space-y-2">
            <Label>Extra Hour (₹)</Label>
            <Input
              type="number"
              value={form.perHourRate}
              onChange={(e) => onChange({ perHourRate: e.target.value })}
            />
          </div>
          <div className="space-y-2">
            <Label>Cancellation (₹)</Label>
            <Input
              type="number"
              value={form.cancellationCharge}
              onChange={(e) => onChange({ cancellationCharge: e.target.value })}
            />
          </div>
        </div>
      ) : (
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-5">
        <div className="space-y-2">
          <Label>Base Fare (₹)</Label>
          <Input
            type="number"
            value={form.baseFare}
            onChange={(e) => onChange({ baseFare: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>KM Included</Label>
          <Input
            type="number"
            min="0"
            step="0.1"
            value={form.includedDistanceKm}
            onChange={(e) => onChange({ includedDistanceKm: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>Per KM (₹)</Label>
          <Input
            type="number"
            value={form.perKmFare}
            onChange={(e) => onChange({ perKmFare: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>Waiting (₹/min)</Label>
          <Input
            type="number"
            value={form.waitingCharge}
            onChange={(e) => onChange({ waitingCharge: e.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label>Cancellation (₹)</Label>
          <Input
            type="number"
            value={form.cancellationCharge}
            onChange={(e) => onChange({ cancellationCharge: e.target.value })}
          />
        </div>
      </div>
      )}
      {showStatus ? (
        <div className="flex items-center justify-between rounded-lg border border-border px-4 py-3">
          <div>
            <p className="font-medium">Active on user panel</p>
            <p className="text-sm text-muted-foreground">Inactive vehicles are hidden from users</p>
          </div>
          <Switch checked={form.isActive} onCheckedChange={(checked) => onChange({ isActive: checked })} />
        </div>
      ) : null}
    </div>
  );
}

export default function VehiclesPage() {
  const [categories, setCategories] = useState<VehicleCategory[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isAdding, setIsAdding] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [addForm, setAddForm] = useState<VehicleFormData>(emptyForm);
  const [editForm, setEditForm] = useState<VehicleFormData>(emptyForm);
  const [editingCategory, setEditingCategory] = useState<VehicleCategory | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<VehicleCategory | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);
  const [togglingId, setTogglingId] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<ServiceTab>("ride");
  const addImageInputRef = useRef<HTMLInputElement>(null);
  const editImageInputRef = useRef<HTMLInputElement>(null);

  const loadCategories = useCallback(async () => {
    setIsLoading(true);
    try {
      const data = await listVehicleCategories();
      setCategories(data);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to load vehicles");
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadCategories();
  }, [loadCategories]);

  const filteredCategories = categories.filter(
    (cat) => (cat.serviceGroup ?? "ride") === activeTab,
  );

  const handleImageChange = (
    event: React.ChangeEvent<HTMLInputElement>,
    mode: "add" | "edit",
  ) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith("image/")) {
      toast.error("Please upload an image file");
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      const image = reader.result as string;
      if (mode === "add") {
        setAddForm((prev) => ({ ...prev, image }));
      } else {
        setEditForm((prev) => ({ ...prev, image }));
      }
    };
    reader.readAsDataURL(file);
    event.target.value = "";
  };

  const handleAddVehicle = async () => {
    if (!addForm.name.trim()) {
      toast.error("Vehicle name is required");
      return;
    }

    setIsAdding(true);
    try {
      const created = await createVehicleCategory({
        name: addForm.name.trim(),
        description: addForm.description.trim() || undefined,
        icon: addForm.icon,
        baseFare: Number(addForm.baseFare) || 25,
        perKmFare: activeTab === "rental" ? 0 : (Number(addForm.perKmFare) || 10),
        includedDistanceKm: activeTab === "rental" ? 0 : (Number(addForm.includedDistanceKm) || 2),
        includedHours: activeTab === "rental" ? Number(addForm.includedHours) || 4 : 0,
        perHourRate: activeTab === "rental" ? Number(addForm.perHourRate) || 50 : 0,
        waitingCharge: Number(addForm.waitingCharge) || 2,
        cancellationCharge: Number(addForm.cancellationCharge) || 20,
        capacity: Number(addForm.capacity) || 4,
        isActive: true,
        image: addForm.image ?? undefined,
        serviceGroup: activeTab,
      });
      setCategories((prev) => [...prev, created]);
      setAddForm(emptyForm);
      setAddDialogOpen(false);
      toast.success(`${created.name} added — visible on user panel`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to add vehicle");
    } finally {
      setIsAdding(false);
    }
  };

  const openEditDialog = (category: VehicleCategory) => {
    setEditingCategory(category);
    setEditForm(categoryToForm(category));
    setEditDialogOpen(true);
  };

  const handleEditVehicle = async () => {
    if (!editingCategory) return;
    if (!editForm.name.trim()) {
      toast.error("Vehicle name is required");
      return;
    }

    setIsEditing(true);
    try {
      const payload: Parameters<typeof updateVehicleCategory>[1] = {
        name: editForm.name.trim(),
        description: editForm.description.trim() || undefined,
        baseFare: Number(editForm.baseFare) || 0,
        perKmFare:
          (editingCategory?.serviceGroup ?? "ride") === "rental"
            ? 0
            : (Number(editForm.perKmFare) || 0),
        includedDistanceKm:
          (editingCategory?.serviceGroup ?? "ride") === "rental"
            ? 0
            : (Number(editForm.includedDistanceKm) || 2),
        includedHours:
          (editingCategory?.serviceGroup ?? "ride") === "rental"
            ? Number(editForm.includedHours) || 4
            : 0,
        perHourRate:
          (editingCategory?.serviceGroup ?? "ride") === "rental"
            ? Number(editForm.perHourRate) || 0
            : 0,
        waitingCharge: Number(editForm.waitingCharge) || 0,
        cancellationCharge: Number(editForm.cancellationCharge) || 20,
        capacity: Number(editForm.capacity) || 4,
        isActive: editForm.isActive,
      };
      if (editForm.image) {
        payload.image = editForm.image;
      } else if (!editForm.existingImageUrl) {
        payload.icon = editForm.icon;
      }
      const updated = await updateVehicleCategory(editingCategory.id, payload);
      setCategories((prev) => prev.map((cat) => (cat.id === updated.id ? updated : cat)));
      setEditDialogOpen(false);
      setEditingCategory(null);
      toast.success(`${updated.name} updated successfully`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to update vehicle");
    } finally {
      setIsEditing(false);
    }
  };

  const handleToggleActive = async (category: VehicleCategory, isActive: boolean) => {
    setTogglingId(category.id);
    try {
      const updated = await updateVehicleCategory(category.id, { isActive });
      setCategories((prev) => prev.map((cat) => (cat.id === updated.id ? updated : cat)));
      toast.success(`${category.name} is now ${isActive ? "active" : "inactive"}`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to update status");
    } finally {
      setTogglingId(null);
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;

    setIsDeleting(true);
    try {
      const result = await deleteVehicleCategory(deleteTarget.id);
      setCategories((prev) => prev.filter((cat) => cat.id !== deleteTarget.id));
      setDeleteTarget(null);
      toast.success(
        result.deactivated
          ? `${deleteTarget.name} deactivated (has existing rides)`
          : `${deleteTarget.name} removed from user panel`,
      );
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to remove vehicle");
    } finally {
      setIsDeleting(false);
    }
  };

  const resetAddDialog = (open: boolean) => {
    setAddDialogOpen(open);
    if (!open) setAddForm(activeTab === "rental" ? emptyRentalForm : emptyForm);
  };

  const handleTabChange = (tab: string) => {
    const value = tab as ServiceTab;
    setActiveTab(value);
    setAddForm(value === "rental" ? emptyRentalForm : emptyForm);
  };

  const resetEditDialog = (open: boolean) => {
    setEditDialogOpen(open);
    if (!open) {
      setEditingCategory(null);
      setEditForm(emptyForm);
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Vehicle Management" description="Configure vehicle categories and pricing">
        <ButtonLink variant="outline" href="/vehicles/approval">
          Vehicle Approval
        </ButtonLink>
        <Dialog open={addDialogOpen} onOpenChange={resetAddDialog}>
          <DialogTrigger render={<Button variant="outline" />}>
            <Plus className="mr-2 h-4 w-4" /> Add Vehicle
          </DialogTrigger>
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle>
                {activeTab === "rental" ? "Add Rental Vehicle" : "Add Vehicle Category"}
              </DialogTitle>
              <DialogDescription>
                {activeTab === "rental"
                  ? "Rental bikes and cars appear in the user app Rental section."
                  : "New vehicles appear on the user app immediately after saving."}
              </DialogDescription>
            </DialogHeader>
            <VehicleFormFields
              form={addForm}
              onChange={(updates) => setAddForm((prev) => ({ ...prev, ...updates }))}
              imageInputRef={addImageInputRef}
              onImageChange={(event) => handleImageChange(event, "add")}
              isRental={activeTab === "rental"}
            />
            <DialogFooter>
              <Button variant="outline" onClick={() => setAddDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleAddVehicle} disabled={isAdding}>
                {isAdding ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Plus className="mr-2 h-4 w-4" />}
                {activeTab === "rental" ? "Add Rental" : "Add Vehicle"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </PageHeader>

      <Tabs value={activeTab} onValueChange={handleTabChange}>
        <TabsList>
          <TabsTrigger value="ride">Ride Vehicles</TabsTrigger>
          <TabsTrigger value="rental">Rental (Bike & Car)</TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-6">
      {isLoading ? (
        <div className="flex items-center justify-center py-20">
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
        </div>
      ) : filteredCategories.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-16 text-center">
            <Car className="mb-4 h-12 w-12 text-muted-foreground" />
            <p className="text-lg font-medium">
              {activeTab === "rental" ? "No rental vehicles yet" : "No vehicle categories yet"}
            </p>
            <p className="mt-1 text-sm text-muted-foreground">
              {activeTab === "rental"
                ? "Add rental bikes or cars for the user panel."
                : "Add your first vehicle to show it on the user panel."}
            </p>
            <Button className="mt-4" onClick={() => setAddDialogOpen(true)}>
              <Plus className="mr-2 h-4 w-4" />
              {activeTab === "rental" ? "Add Rental" : "Add Vehicle"}
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6">
          {filteredCategories.map((category) => {
            const Icon = vehicleIcons[category.type] ?? vehicleIcons[category.icon] ?? Car;
            const imageSrc = getCategoryImageUrl(category);

            return (
              <Card key={category.id}>
                <CardHeader>
                  <div className="flex items-center justify-between gap-4">
                    <div className="flex min-w-0 items-center gap-3">
                      <div className="rounded-xl bg-primary/10 p-1">
                        {imageSrc ? (
                          // eslint-disable-next-line @next/next/no-img-element
                          <img
                            src={imageSrc}
                            alt={category.name}
                            className="h-14 w-14 rounded-lg object-cover"
                          />
                        ) : (
                          <div className="p-2">
                            <Icon className="h-6 w-6 text-primary" />
                          </div>
                        )}
                      </div>
                      <div className="min-w-0">
                        <CardTitle>{category.name}</CardTitle>
                        <CardDescription className="line-clamp-2">
                          {category.description || `Configure pricing for ${category.name.toLowerCase()}`}
                        </CardDescription>
                      </div>
                    </div>
                    <div className="flex shrink-0 items-center gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => openEditDialog(category)}
                      >
                        <Pencil className="mr-2 h-4 w-4" />
                        Edit
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon-sm"
                        className="text-destructive hover:text-destructive"
                        onClick={() => setDeleteTarget(category)}
                        aria-label={`Remove ${category.name}`}
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                      <Badge variant={category.isActive ? "default" : "secondary"}>
                        {category.isActive ? "Active" : "Inactive"}
                      </Badge>
                      <Switch
                        checked={category.isActive}
                        disabled={togglingId === category.id}
                        onCheckedChange={(checked) => void handleToggleActive(category, checked)}
                      />
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  {activeTab === "rental" ? (
                    <div className="grid gap-3 text-sm sm:grid-cols-2 lg:grid-cols-4">
                      <div className="rounded-lg bg-muted/40 px-3 py-2">
                        <p className="text-muted-foreground">Base Rate</p>
                        <p className="font-semibold">₹{category.baseFare}</p>
                      </div>
                      <div className="rounded-lg bg-muted/40 px-3 py-2">
                        <p className="text-muted-foreground">Minimum Hours</p>
                        <p className="font-semibold">{category.includedHours ?? 4} hrs</p>
                      </div>
                      <div className="rounded-lg bg-muted/40 px-3 py-2">
                        <p className="text-muted-foreground">Extra Hour</p>
                        <p className="font-semibold">₹{category.perHourRate ?? 0}/hr</p>
                      </div>
                      <div className="rounded-lg bg-muted/40 px-3 py-2">
                        <p className="text-muted-foreground">Cancellation</p>
                        <p className="font-semibold">₹{category.cancellationCharge}</p>
                      </div>
                    </div>
                  ) : (
                  <div className="grid gap-3 text-sm sm:grid-cols-2 lg:grid-cols-6">
                    <div className="rounded-lg bg-muted/40 px-3 py-2">
                      <p className="text-muted-foreground">Base Fare</p>
                      <p className="font-semibold">₹{category.baseFare}</p>
                    </div>
                    <div className="rounded-lg bg-muted/40 px-3 py-2">
                      <p className="text-muted-foreground">Capacity</p>
                      <p className="font-semibold">{category.capacity ?? 4} seats</p>
                    </div>
                    <div className="rounded-lg bg-muted/40 px-3 py-2">
                      <p className="text-muted-foreground">KM Included</p>
                      <p className="font-semibold">{category.includedDistanceKm ?? 2} km</p>
                    </div>
                    <div className="rounded-lg bg-muted/40 px-3 py-2">
                      <p className="text-muted-foreground">Per KM Fare</p>
                      <p className="font-semibold">₹{category.perKmFare}</p>
                    </div>
                    <div className="rounded-lg bg-muted/40 px-3 py-2">
                      <p className="text-muted-foreground">Waiting Charge</p>
                      <p className="font-semibold">₹{category.waitingCharge}/min</p>
                    </div>
                    <div className="rounded-lg bg-muted/40 px-3 py-2">
                      <p className="text-muted-foreground">Cancellation</p>
                      <p className="font-semibold">₹{category.cancellationCharge}</p>
                    </div>
                  </div>
                  )}
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
        </TabsContent>
      </Tabs>

      <Dialog open={editDialogOpen} onOpenChange={resetEditDialog}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Edit {editingCategory?.name}</DialogTitle>
            <DialogDescription>
              Changes are saved to the user panel immediately after updating.
            </DialogDescription>
          </DialogHeader>
          <VehicleFormFields
            form={editForm}
            onChange={(updates) => setEditForm((prev) => ({ ...prev, ...updates }))}
            imageInputRef={editImageInputRef}
            onImageChange={(event) => handleImageChange(event, "edit")}
            showStatus
            isRental={(editingCategory?.serviceGroup ?? "ride") === "rental"}
          />
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleEditVehicle} disabled={isEditing}>
              {isEditing ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Pencil className="mr-2 h-4 w-4" />}
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!deleteTarget} onOpenChange={(open) => !open && setDeleteTarget(null)}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>Remove {deleteTarget?.name}?</DialogTitle>
            <DialogDescription>
              This vehicle will no longer appear on the user panel. Existing rides are not affected.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteTarget(null)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={handleDelete} disabled={isDeleting}>
              {isDeleting ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Remove
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
