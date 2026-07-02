"use client";

import { useState } from "react";
import { Download } from "lucide-react";
import { Button } from "@/components/ui/button";
import { downloadCsv } from "@/lib/export";
import { toast } from "sonner";

interface ExportButtonProps {
  label?: string;
  filename?: string;
  exportPath?: string;
  onExport?: () => Promise<void>;
}

export function ExportButton({
  label = "Export CSV",
  filename = "export",
  exportPath,
  onExport,
}: ExportButtonProps) {
  const [isExporting, setIsExporting] = useState(false);

  const handleExport = async () => {
    setIsExporting(true);
    try {
      if (onExport) {
        await onExport();
      } else if (exportPath) {
        await downloadCsv(exportPath, filename);
      } else {
        throw new Error("Export is not configured for this page");
      }
      toast.success(`${filename}.csv downloaded successfully`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to export CSV");
    } finally {
      setIsExporting(false);
    }
  };

  return (
    <Button variant="outline" size="sm" onClick={() => void handleExport()} disabled={isExporting}>
      <Download className="mr-2 h-4 w-4" />
      {isExporting ? "Exporting..." : label}
    </Button>
  );
}
