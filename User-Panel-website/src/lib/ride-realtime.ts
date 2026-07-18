import { getApiBaseUrl } from "@/lib/api";
import { getAuthSession } from "@/lib/auth-session";

export type RideRealtimeMessage = Record<string, unknown> & {
  event?: string;
  ride_id?: string;
};

type Listener = (msg: RideRealtimeMessage) => void;

function websocketBaseUrl(): string {
  const raw = getApiBaseUrl().replace(/\/api\/v1\/?$/, "");
  const uri = new URL(raw);
  uri.protocol = uri.protocol === "https:" ? "wss:" : "ws:";
  return uri.toString().replace(/\/$/, "");
}

class RideRealtimeClient {
  private socket: WebSocket | null = null;
  private listeners = new Set<Listener>();
  private subscribedRideId: string | null = null;
  private pingTimer: number | null = null;
  private reconnectTimer: number | null = null;
  private intentionalClose = false;

  connect() {
    if (typeof window === "undefined") return;
    if (this.socket && (this.socket.readyState === WebSocket.OPEN || this.socket.readyState === WebSocket.CONNECTING)) {
      return;
    }

    const token = getAuthSession()?.accessToken;
    if (!token) return;

    this.intentionalClose = false;
    const url = `${websocketBaseUrl()}/ws/ride?token=${encodeURIComponent(token)}`;
    const socket = new WebSocket(url);
    this.socket = socket;

    socket.onopen = () => {
      if (this.subscribedRideId) {
        this.subscribeRide(this.subscribedRideId);
      }
      this.startPing();
    };

    socket.onmessage = (event) => {
      try {
        const decoded = JSON.parse(String(event.data)) as RideRealtimeMessage;
        this.listeners.forEach((listener) => listener(decoded));
      } catch {
        // Ignore malformed payloads.
      }
    };

    socket.onerror = () => {
      // Polling remains the fallback.
    };

    socket.onclose = () => {
      this.socket = null;
      this.stopPing();
      if (!this.intentionalClose) {
        this.scheduleReconnect();
      }
    };
  }

  private startPing() {
    this.stopPing();
    this.pingTimer = window.setInterval(() => {
      this.send({ event: "ping" });
    }, 20000);
  }

  private stopPing() {
    if (this.pingTimer != null) {
      window.clearInterval(this.pingTimer);
      this.pingTimer = null;
    }
  }

  private scheduleReconnect() {
    if (this.reconnectTimer != null) return;
    this.reconnectTimer = window.setTimeout(() => {
      this.reconnectTimer = null;
      this.connect();
    }, 2500);
  }

  subscribeRide(rideId: string) {
    this.subscribedRideId = rideId;
    this.send({ event: "subscribe_ride", ride_id: rideId });
  }

  unsubscribeRide(rideId: string) {
    this.send({ event: "unsubscribe_ride", ride_id: rideId });
    if (this.subscribedRideId === rideId) this.subscribedRideId = null;
  }

  send(data: Record<string, unknown>) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;
    try {
      this.socket.send(JSON.stringify(data));
    } catch {
      // ignore
    }
  }

  onMessage(listener: Listener) {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  }

  disconnect() {
    this.intentionalClose = true;
    if (this.reconnectTimer != null) {
      window.clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
    this.stopPing();
    this.socket?.close();
    this.socket = null;
    this.subscribedRideId = null;
  }
}

let sharedClient: RideRealtimeClient | null = null;

export function getRideRealtimeClient(): RideRealtimeClient {
  if (!sharedClient) sharedClient = new RideRealtimeClient();
  return sharedClient;
}
