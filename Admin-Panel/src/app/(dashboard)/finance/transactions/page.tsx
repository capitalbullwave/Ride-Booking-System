"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { ExportButton } from "@/components/shared/export-button";
import { DataTable, Column } from "@/components/shared/data-table";
import { StatusBadge } from "@/components/shared/status-badge";
import { formatCurrency, formatDateTime, capitalize } from "@/lib/format";
import { fetchFinanceTransactions, FinanceTransaction } from "@/lib/finance-api";
import { toast } from "sonner";
import { useAutoRefresh } from "@/hooks/use-auto-refresh";
import { useAuth } from "@/components/providers/auth-provider";

export default function TransactionsPage() {
  const { isAuthenticated, isLoading: authLoading } = useAuth();
  const [items, setItems] = useState<FinanceTransaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const load = useCallback(async (options?: { silent?: boolean }) => {
    if (!options?.silent) setIsLoading(true);
    try {
      const res = await fetchFinanceTransactions({ limit: 200 });
      setItems(res.items);
    } catch (e) {
      if (!options?.silent) {
        toast.error(e instanceof Error ? e.message : "Failed to load transactions");
        setItems([]);
      }
    } finally {
      if (!options?.silent) setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (authLoading) return;
    if (!isAuthenticated) {
      setItems([]);
      setIsLoading(false);
      return;
    }
    void load();
  }, [authLoading, isAuthenticated, load]);

  useAutoRefresh(() => load({ silent: true }), { enabled: isAuthenticated && !authLoading });

  const columns: Column<FinanceTransaction>[] = [
    { key: "id", header: "Transaction ID", cell: (t) => <span className="font-mono text-xs">{t.id}</span> },
    { key: "type", header: "Type", cell: (t) => capitalize(t.type) },
    { key: "description", header: "Description", cell: (t) => t.description },
    { key: "amount", header: "Amount", cell: (t) => formatCurrency(t.amount), sortable: true },
    { key: "paymentMethod", header: "Method", cell: (t) => t.paymentMethod ?? "—" },
    { key: "status", header: "Status", cell: (t) => <StatusBadge status={t.status} /> },
    { key: "date", header: "Date", cell: (t) => formatDateTime(t.date), sortable: true },
  ];

  const exportPath = useMemo(() => `/api/v1/admin/finance/transactions`, []);

  return (
    <div className="space-y-6">
      <PageHeader title="Transaction History" description="All payment and financial transactions">
        <ExportButton filename="transactions" exportPath={exportPath} />
      </PageHeader>
      <DataTable
        data={items}
        columns={columns}
        emptyTitle={isLoading ? "Loading transactions..." : "No transactions found"}
        emptyDescription={isLoading ? "Fetching data from the server." : "No records yet."}
      />
    </div>
  );
}
