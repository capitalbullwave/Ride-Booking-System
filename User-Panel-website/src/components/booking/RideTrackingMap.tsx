"use client";

interface RideTrackingMapProps {
  pickupLat?: number | null;
  pickupLng?: number | null;
  dropoffLat?: number | null;
  dropoffLng?: number | null;
  driverLat?: number | null;
  driverLng?: number | null;
  vehicleImage?: string;
  vehicleName?: string;
}

function buildMapSrc(props: RideTrackingMapProps): string {
  const {
    pickupLat,
    pickupLng,
    dropoffLat,
    dropoffLng,
    driverLat,
    driverLng,
  } = props;

  if (
    pickupLat != null &&
    pickupLng != null &&
    dropoffLat != null &&
    dropoffLng != null
  ) {
    const originLat = driverLat ?? pickupLat;
    const originLng = driverLng ?? pickupLng;
    return `https://maps.google.com/maps?saddr=${originLat},${originLng}&daddr=${dropoffLat},${dropoffLng}&output=embed`;
  }

  if (pickupLat != null && pickupLng != null) {
    return `https://maps.google.com/maps?q=${pickupLat},${pickupLng}&z=14&output=embed`;
  }

  return "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d14008.114827184203!2d77.216721!3d28.6328!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x390cfd37b741d057%3A0xc46ce4427b231eb5!2sConnaught%20Place%2C%20New%20Delhi%2C%20Delhi%20110001!5e0!3m2!1sen!2sin!4v1700000000000!5m2!1sen!2sin";
}

export function RideTrackingMap(props: RideTrackingMapProps) {
  return (
    <div className="relative h-64 w-full overflow-hidden bg-muted sm:h-72">
      <iframe
        src={buildMapSrc(props)}
        title={props.vehicleName ? `${props.vehicleName} live map` : "Live ride map"}
        className="h-full w-full border-0"
        loading="lazy"
        referrerPolicy="no-referrer-when-downgrade"
        allowFullScreen={false}
      />
    </div>
  );
}
