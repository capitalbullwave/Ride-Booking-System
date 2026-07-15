/** Cashfree hosted checkout (popup) for subscription / wallet payments. */

declare global {
  interface Window {
    Cashfree?: (options: { mode: "sandbox" | "production" }) => {
      checkout: (options: {
        paymentSessionId: string;
        redirectTarget?: string;
      }) => Promise<{
        error?: { message?: string };
        paymentDetails?: { paymentMessage?: string };
        redirect?: boolean;
      }>;
    };
  }
}

let cashfreeScriptPromise: Promise<void> | null = null;

function loadCashfreeScript(): Promise<void> {
  if (typeof window === "undefined") {
    return Promise.reject(new Error("Cashfree is only available in the browser"));
  }
  if (window.Cashfree) return Promise.resolve();
  if (cashfreeScriptPromise) return cashfreeScriptPromise;

  cashfreeScriptPromise = new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = "https://sdk.cashfree.com/js/v3/cashfree.js";
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error("Unable to load Cashfree checkout"));
    document.body.appendChild(script);
  });

  return cashfreeScriptPromise;
}

export type CashfreeCheckoutInput = {
  order_id: string;
  payment_session_id: string;
  environment?: string;
  amount?: number;
  currency?: string;
  plan?: { slug: string; name: string };
  description?: string;
  prefill?: { name?: string; email?: string; contact?: string };
};

export async function openSubscriptionCheckout(
  checkout: CashfreeCheckoutInput
): Promise<{ order_id: string }> {
  await loadCashfreeScript();

  if (!window.Cashfree) {
    throw new Error("Cashfree checkout is unavailable");
  }
  if (!checkout.payment_session_id) {
    throw new Error("Cashfree payment session is missing. Please restart the backend server.");
  }

  const mode =
    checkout.environment === "production" || checkout.environment === "prod"
      ? "production"
      : "sandbox";

  const cashfree = window.Cashfree({ mode });
  const result = await cashfree.checkout({
    paymentSessionId: checkout.payment_session_id,
    redirectTarget: "_modal",
  });

  if (result?.error) {
    throw new Error(result.error.message || "Payment cancelled");
  }

  return { order_id: checkout.order_id };
}
