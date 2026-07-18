/** Offline / API-failure answers for Bullwave guest assistant (English defaults). */

function prefersHinglish(message: string): boolean {
  const text = message.toLowerCase();
  return /[अ-ह]|\b(kya|kaise|kitna|kaun|hai|hain|me|mein|aur|batao|lagega|poochh|karo|hoon|aap)\b/.test(
    text
  );
}

export function getAiFeatureFallback(message: string): string {
  const text = message.toLowerCase();
  const hinglish = prefersHinglish(message);

  if (/women|woman|mahila|female|lady|ladies/.test(text)) {
    return hinglish
      ? "Women Safety Bull Wave pe 2 tareeke se kaam karti hai:\n\n1) Prefer Women Captains — female riders women captains request kar sakti hain.\n2) Women Safety Mode — book par auto-enable, emergency contact alert, Share Ride + SOS.\n\nProfile me emergency contact add karein."
      : "Women Safety on Bull Wave works in two ways:\n\n1) Prefer Women Captains — female riders can request women captains; if none are nearby, they can continue with all captains.\n2) Women Safety Mode — auto-enabled for female riders on booking: emergency-contact alert, Share Ride + SOS on the trip.\n\nAdd an emergency contact in your profile.";
  }

  if (/safe|sos|safety|emergency|suraksha|monitor/.test(text)) {
    return hinglish
      ? "Safety features:\n• Live tracking + verified captain\n• Share Ride\n• SOS on active ride\n• Women Safety Mode + Prefer Women Captains\n• Ambulance / Emergency\n\nFull SOS ke liye login + active ride chahiye."
      : "Safety features:\n• Live tracking and verified captain details\n• Share Ride (driver, plate, destination, Maps link)\n• SOS on an active ride → support ticket, alerts, and emergency-contact SMS\n• Women Safety Mode and Prefer Women Captains\n• Ambulance / Emergency medical transport\n\nFull SOS needs login and an active ride.";
  }

  if (/fare|price|cheap|kitna|kiraya|cost|km|किमी|estimate/.test(text)) {
    return hinglish
      ? "Fare aise banta hai:\n• base fare + (distance − included km) × per-km rate\n• night surcharge apply ho sakta hai\n\nExact estimate: “10 km ka fare” ya “X se Y kitna lagega?”"
      : "Here’s how fare works:\n• base fare + (distance − included km) × per-km rate\n• a night surcharge may apply\n\nFor an exact estimate, ask: “What’s the fare for 10 km?” or “Fare from X to Y?”";
  }

  if (
    /feature|service|kya kya|what can|bike|parcel|ambulance|wallet|route|optim|predictor/.test(
      text
    )
  ) {
    return hinglish
      ? "Bull Wave Rides features:\n• Bike, Electric Auto, Cab\n• Parcel, Ambulance / Emergency\n• Rentals, Wallet, coupons, subscriptions, student pass, refer & earn\n• Live tracking, SOS, women safety\n• AI Fare Predictor, Route Optimizer, Safety Monitor\n\nFare ke liye 2 jagah ya km batao."
      : "Bull Wave Rides features:\n• Bike, Electric Auto, Cab\n• Parcel delivery\n• Ambulance / Emergency\n• Rentals, Wallet, coupons, subscriptions, student pass, refer & earn\n• Live tracking, SOS, women safety\n• AI Fare Predictor, Route Optimizer, Safety Monitor\n\nFor fares, share 2 places or distance in km.";
  }

  return hinglish
    ? "Main Bullwave Assistant hoon. Features, safety, women safety, ya fare poochh sakte ho."
    : "I’m Bullwave Assistant. I can help with features, safety, women safety, and fare estimates.";
}
