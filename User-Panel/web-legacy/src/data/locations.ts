export interface LocationSuggestion {
  id: string;
  name: string;
  address: string;
}

export const LOCATION_SUGGESTIONS: LocationSuggestion[] = [
  {
    id: "cp",
    name: "Connaught Place",
    address: "Connaught Place, New Delhi, Delhi 110001",
  },
  {
    id: "igi",
    name: "Indira Gandhi International Airport",
    address: "New Delhi, Delhi 110037",
  },
  {
    id: "cyber",
    name: "Cyber City",
    address: "DLF Cyber City, Gurugram, Haryana 122002",
  },
  {
    id: "bandra",
    name: "Bandra Kurla Complex",
    address: "Bandra East, Mumbai, Maharashtra 400051",
  },
  {
    id: "mg",
    name: "MG Road",
    address: "MG Road, Bengaluru, Karnataka 560001",
  },
  {
    id: "hitech",
    name: "HITEC City",
    address: "HITEC City, Hyderabad, Telangana 500081",
  },
  {
    id: "salt",
    name: "Salt Lake Sector V",
    address: "Sector V, Salt Lake, Kolkata, West Bengal 700091",
  },
  {
    id: "anna",
    name: "Anna Nagar",
    address: "Anna Nagar, Chennai, Tamil Nadu 600040",
  },
  {
    id: "koregaon",
    name: "Koregaon Park",
    address: "Koregaon Park, Pune, Maharashtra 411001",
  },
  {
    id: "maninagar",
    name: "Maninagar",
    address: "Maninagar, Ahmedabad, Gujarat 380008",
  },
];

export const CURRENT_LOCATION_SUGGESTION: LocationSuggestion = {
  id: "current",
  name: "Use current location",
  address: "Current Location, New Delhi, Delhi",
};

export const RECENT_LOCATION_SUGGESTIONS: LocationSuggestion[] = [
  {
    id: "recent-cp",
    name: "Connaught Place",
    address: "Connaught Place, New Delhi, Delhi 110001",
  },
  {
    id: "recent-cyber",
    name: "Cyber City",
    address: "DLF Cyber City, Gurugram, Haryana 122002",
  },
  {
    id: "recent-mg",
    name: "MG Road",
    address: "MG Road, Bengaluru, Karnataka 560001",
  },
];

export const POPULAR_LOCATION_SUGGESTIONS: LocationSuggestion[] = [
  {
    id: "pop-igi",
    name: "Indira Gandhi International Airport",
    address: "New Delhi, Delhi 110037",
  },
  {
    id: "pop-bandra",
    name: "Bandra Kurla Complex",
    address: "Bandra East, Mumbai, Maharashtra 400051",
  },
  {
    id: "pop-hitech",
    name: "HITEC City",
    address: "HITEC City, Hyderabad, Telangana 500081",
  },
  {
    id: "pop-salt",
    name: "Salt Lake Sector V",
    address: "Sector V, Salt Lake, Kolkata, West Bengal 700091",
  },
  {
    id: "pop-anna",
    name: "Anna Nagar",
    address: "Anna Nagar, Chennai, Tamil Nadu 600040",
  },
];

export function filterLocationSuggestions(query: string): LocationSuggestion[] {
  const normalized = query.trim().toLowerCase();
  if (normalized.length < 4) return [];

  return LOCATION_SUGGESTIONS.filter(
    (item) =>
      item.name.toLowerCase().includes(normalized) ||
      item.address.toLowerCase().includes(normalized)
  );
}
