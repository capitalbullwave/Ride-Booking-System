declare global {
  interface Window {
    Razorpay?: new (options: Record<string, unknown>) => {
      open: () => void;
      on: (event: string, handler: (response: Record<string, string>) => void) => void;
    };
  }
}

let razorpayScriptPromise: Promise<void> | null = null;

function loadRazorpayScript(): Promise<void> {
  if (typeof window === "undefined") {
    return Promise.reject(new Error("Razorpay is only available in the browser"));
  }
  if (window.Razorpay) return Promise.resolve();
  if (razorpayScriptPromise) return razorpayScriptPromise;

  razorpayScriptPromise = new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = "https://checkout.razorpay.com/v1/checkout.js";
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error("Unable to load Razorpay checkout"));
    document.body.appendChild(script);
  });

  return razorpayScriptPromise;
}

export async function openSubscriptionCheckout(checkout: {
  key_id: string;
  razorpay_key_id?: string;
  order_id: string;
  amount: number;
  currency: string;
  plan: { slug: string; name: string };
  prefill?: { name?: string; email?: string; contact?: string };
}): Promise<{
  razorpay_order_id: string;
  razorpay_payment_id: string;
  razorpay_signature: string;
}> {
  await loadRazorpayScript();

  if (!window.Razorpay) {
    throw new Error("Razorpay checkout is unavailable");
  }

  const key = checkout.key_id || checkout.razorpay_key_id;
  if (!key) {
    throw new Error("Razorpay key is missing. Please restart the backend server.");
  }

  return new Promise((resolve, reject) => {
    const rzp = new window.Razorpay!({
      key,
      amount: checkout.amount,
      currency: checkout.currency,
      order_id: checkout.order_id,
      name: "Bull Wave rides",
      description: checkout.plan.name,
      prefill: checkout.prefill,
      handler(response: Record<string, string>) {
        resolve({
          razorpay_order_id: response.razorpay_order_id,
          razorpay_payment_id: response.razorpay_payment_id,
          razorpay_signature: response.razorpay_signature,
        });
      },
      modal: {
        ondismiss() {
          reject(new Error("Payment cancelled"));
        },
      },
    });

    rzp.on("payment.failed", () => {
      reject(new Error("Payment failed"));
    });

    rzp.open();
  });
}
