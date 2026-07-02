"use client";

import Link from "next/link";
import {
  HelpCircle,
  MessageCircle,
  BookOpen,
  Mail,
  Phone,
  ChevronRight,
  FileQuestion,
} from "lucide-react";
import { PageHeader } from "@/components/layout/page-header";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ButtonLink } from "@/components/ui/button-link";
import { ROUTES } from "@/constants/routes";
import { appSettings } from "@/data/mock-data";

const faqs = [
  {
    q: "How do I verify a new driver?",
    a: "Go to Drivers → select the driver → Documents tab → Approve or Reject each document.",
  },
  {
    q: "How do I send a notification to all users?",
    a: "Open Send Notifications from the sidebar, compose your message, choose the audience, and click Send.",
  },
  {
    q: "Where can I see platform alerts?",
    a: "Click the bell icon in the header or open Alert Inbox from the sidebar.",
  },
  {
    q: "How do I process driver payouts?",
    a: "Navigate to Finance → Driver Payouts to review and approve pending settlements.",
  },
];

const quickLinks = [
  { title: "Support Tickets", description: "Manage user and driver support requests", href: ROUTES.support, icon: MessageCircle },
  { title: "Documentation", description: "WaveGo admin panel user guide", href: "#", icon: BookOpen },
  { title: "Alert Inbox", description: "View all admin platform alerts", href: ROUTES.alerts, icon: HelpCircle },
];

export default function HelpCenterPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Help Center"
        description="Find answers, guides, and ways to contact the WaveGo support team"
      >
        <ButtonLink href={ROUTES.support}>
          <MessageCircle className="mr-2 h-4 w-4" />
          Open Support
        </ButtonLink>
      </PageHeader>

      <div className="grid gap-4 sm:grid-cols-3">
        {quickLinks.map((link) => (
          <Link key={link.title} href={link.href}>
            <Card className="h-full transition-shadow hover:shadow-md">
              <CardContent className="flex items-start gap-4 p-5">
                <div className="rounded-2xl bg-primary/10 p-3 text-primary">
                  <link.icon className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <p className="font-medium">{link.title}</p>
                  <p className="mt-1 text-sm text-muted-foreground">{link.description}</p>
                </div>
                <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground" />
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileQuestion className="h-5 w-5 text-primary" />
            Frequently Asked Questions
          </CardTitle>
          <CardDescription>Common questions about using the WaveGo admin panel</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {faqs.map((faq, i) => (
            <div key={i} className="rounded-[1rem] border border-border/80 bg-muted/20 p-4">
              <p className="font-medium">{faq.q}</p>
              <p className="mt-2 text-sm text-muted-foreground">{faq.a}</p>
            </div>
          ))}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Contact Support</CardTitle>
          <CardDescription>Reach the WaveGo team directly</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 sm:grid-cols-2">
          <div className="flex items-center gap-3 rounded-[1rem] border p-4">
            <Mail className="h-5 w-5 text-primary" />
            <div>
              <p className="text-sm text-muted-foreground">Email</p>
              <p className="font-medium">{appSettings.contactEmail}</p>
            </div>
          </div>
          <div className="flex items-center gap-3 rounded-[1rem] border p-4">
            <Phone className="h-5 w-5 text-primary" />
            <div>
              <p className="text-sm text-muted-foreground">Phone</p>
              <p className="font-medium">{appSettings.contactPhone}</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
