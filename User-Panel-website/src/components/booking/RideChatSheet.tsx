"use client";

import { useEffect, useRef, useState } from "react";
import { Loader2, Send, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  listRideMessages,
  sendRideMessage,
  type RideChatMessage,
} from "@/lib/ride-api";
import { getRideRealtimeClient } from "@/lib/ride-realtime";
import { cn } from "@/lib/utils";

interface RideChatSheetProps {
  open: boolean;
  rideId: string;
  onClose: () => void;
}

export function RideChatSheet({ open, rideId, onClose }: RideChatSheetProps) {
  const [messages, setMessages] = useState<RideChatMessage[]>([]);
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    let cancelled = false;

    async function load() {
      setLoading(true);
      try {
        const rows = await listRideMessages(rideId);
        if (!cancelled) setMessages(rows);
      } catch {
        if (!cancelled) setMessages([]);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    void load();
    const client = getRideRealtimeClient();
    client.connect();
    client.subscribeRide(rideId);
    const unsub = client.onMessage((msg) => {
      const event = String(msg.event ?? "");
      if (event !== "ride_message" && event !== "chat_message") return;
      if (String(msg.ride_id ?? "") !== rideId) return;
      const incoming = msg as unknown as RideChatMessage;
      if (!incoming.id || !incoming.message) return;
      setMessages((prev) =>
        prev.some((m) => m.id === incoming.id) ? prev : [...prev, incoming]
      );
    });

    return () => {
      cancelled = true;
      unsub();
    };
  }, [open, rideId]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, open]);

  if (!open) return null;

  const handleSend = async () => {
    const trimmed = text.trim();
    if (!trimmed || sending) return;
    setSending(true);
    try {
      const sent = await sendRideMessage(rideId, trimmed);
      setMessages((prev) =>
        prev.some((m) => m.id === sent.id) ? prev : [...prev, sent]
      );
      setText("");
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 p-0 sm:items-center sm:p-4">
      <div className="flex h-[70vh] w-full max-w-lg flex-col rounded-t-[24px] bg-card shadow-xl sm:h-[560px] sm:rounded-[24px]">
        <div className="flex items-center justify-between border-b border-border px-4 py-3">
          <h2 className="font-heading text-lg font-bold">Chat with captain</h2>
          <button
            type="button"
            onClick={onClose}
            className="flex h-9 w-9 items-center justify-center rounded-full hover:bg-muted"
            aria-label="Close chat"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="min-h-0 flex-1 space-y-2 overflow-y-auto px-4 py-3">
          {loading ? (
            <div className="flex justify-center py-10">
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
            </div>
          ) : messages.length === 0 ? (
            <p className="py-10 text-center text-sm text-muted-foreground">
              No messages yet.
              <br />
              Say hi to your captain!
            </p>
          ) : (
            messages.map((msg) => {
              const mine = (msg.sender_type ?? "").toLowerCase() === "user";
              return (
                <div
                  key={msg.id}
                  className={cn("flex", mine ? "justify-end" : "justify-start")}
                >
                  <div
                    className={cn(
                      "max-w-[80%] rounded-2xl px-3 py-2 text-sm",
                      mine
                        ? "bg-primary text-primary-foreground"
                        : "bg-muted text-foreground"
                    )}
                  >
                    {msg.message}
                  </div>
                </div>
              );
            })
          )}
          <div ref={bottomRef} />
        </div>

        <div className="flex items-center gap-2 border-t border-border p-3">
          <input
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") void handleSend();
            }}
            placeholder="Type a message"
            className="h-11 flex-1 rounded-full border border-border bg-background px-4 text-sm outline-none focus:border-primary"
          />
          <Button
            type="button"
            size="icon"
            className="h-11 w-11 rounded-full"
            disabled={sending || !text.trim()}
            onClick={() => void handleSend()}
          >
            {sending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
          </Button>
        </div>
      </div>
    </div>
  );
}
