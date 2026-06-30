def normalize_phone(phone: str) -> str:
    cleaned = "".join(c for c in phone if c.isdigit() or c == "+")
    if cleaned.startswith("+91"):
        return cleaned
    if cleaned.startswith("91") and len(cleaned) == 12:
        return f"+{cleaned}"
    if len(cleaned) == 10:
        return f"+91{cleaned}"
    return cleaned


def format_phone_display(phone: str, dial_code: str = "+91") -> str:
    digits = "".join(c for c in phone if c.isdigit())
    if len(digits) >= 10:
        local = digits[-10:]
        return f"{dial_code} {local[:5]} {local[5:]}"
    return f"{dial_code} {phone}"
