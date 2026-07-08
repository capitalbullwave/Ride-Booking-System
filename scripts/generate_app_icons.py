from pathlib import Path
from PIL import Image
import shutil

SRC = Path(
    r"C:\Users\Admin\.cursor\projects\c-Users-Admin-Desktop-Wave-Go-Ride-Booking-System"
    r"\assets\c__Users_Admin_AppData_Roaming_Cursor_User_workspaceStorage_18c69de245e5f7c25a17a44d2f34fd32_images_IMG_5289.JPG-6a4451fd-e978-4692-9290-b54f49397fc9.png"
)
ROOT = Path(r"c:\Users\Admin\Desktop\Wave Go\Ride-Booking-System")

MIPMAP_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
ADAPTIVE_SIZES = {
    "mipmap-mdpi": 108,
    "mipmap-hdpi": 162,
    "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324,
    "mipmap-xxxhdpi": 432,
}

ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""

COLORS_XML = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#000000</color>
</resources>
"""


def generate_for_app(app_dir: Path, logo: Image.Image) -> None:
    assets_dir = app_dir / "assets" / "images"
    assets_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SRC, assets_dir / "app_logo.png")

    res = app_dir / "android" / "app" / "src" / "main" / "res"
    for folder, size in MIPMAP_SIZES.items():
        out_dir = res / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        logo.resize((size, size), Image.Resampling.LANCZOS).save(out_dir / "ic_launcher.png")

    for folder, size in ADAPTIVE_SIZES.items():
        out_dir = res / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        logo.resize((size, size), Image.Resampling.LANCZOS).save(
            out_dir / "ic_launcher_foreground.png"
        )

    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(ADAPTIVE_XML, encoding="utf-8")

    values = res / "values"
    values.mkdir(parents=True, exist_ok=True)
    (values / "colors.xml").write_text(COLORS_XML, encoding="utf-8")


def main() -> None:
    logo = Image.open(SRC).convert("RGBA")
    if logo.size != (1024, 1024):
        logo = logo.resize((1024, 1024), Image.Resampling.LANCZOS)

    for app_name in ("Driver-Panel", "User-Panel"):
        generate_for_app(ROOT / app_name, logo)

    website_logo = ROOT / "User-Panel-website" / "public" / "images" / "bull-wave-rides-logo.png"
    website_logo.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SRC, website_logo)

    admin_png = ROOT / "Admin-Panel" / "public" / "logo.png"
    shutil.copy2(SRC, admin_png)

    print("Done: app logos and Android launcher icons generated.")


if __name__ == "__main__":
    main()
