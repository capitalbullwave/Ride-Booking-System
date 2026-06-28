"use client";

import { PageHeader } from "@/components/layout/page-header";
import { ExportButton } from "@/components/shared/export-button";
import { DataTable, Column } from "@/components/shared/data-table";
import { StatusBadge } from "@/components/shared/status-badge";
import { transactions } from "@/data/mock-data";
import { Transaction } from "@/types";
import { formatCurrency, formatDateTime, capitalize } from "@/lib/format";

export default function TransactionsPage() {
  const columns: Column<Transaction>[] = [
    { key: "id", header: "Transaction ID", cell: (t) => <span className="font-mono text-xs">{t.id}</span> },
    { key: "type", header: "Type", cell: (t) => capitalize(t.type) },
    { key: "description", header: "Description", cell: (t) => t.description },
    { key: "amount", header: "Amount", cell: (t) => formatCurrency(t.amount), sortable: true },
    { key: "paymentMethod", header: "Method", cell: (t) => t.paymentMethod ?? "—" },
    { key: "status", header: "Status", cell: (t) => <StatusBadge status={t.status} /> },
    { key: "date", header: "Date", cell: (t) => formatDateTime(t.date), sortable: true },
  ];

  return (
    <div className="space-y-6">
      <PageHeader title="Transaction History" description="All payment and financial transactions">
        <ExportButton filename="transactions" />
      </PageHeader>
      <DataTable data={transactions} columns={columns} />
    </div>
  );
}
