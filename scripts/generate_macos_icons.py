import os
from PIL import Image, ImageFilter

def generate_macos_icons():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    source_icon_path = os.path.join(root_dir, 'assets', 'icons', 'app_icon.png')
    target_dir = os.path.join(root_dir, 'macos', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')

    if not os.path.exists(source_icon_path):
        raise FileNotFoundError(f"Source icon not found at {source_icon_path}")

    source_icon = Image.open(source_icon_path).convert('RGBA')

    # Apple macOS Big Sur+ HIG Standard:
    # Canvas: 1024x1024
    # Squircle body: 824x824 centered at (100, 100)
    # Padding: 100px on all 4 sides
    icon_824 = source_icon.resize((824, 824), Image.Resampling.LANCZOS)

    canvas_1024 = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))

    # Shadow 1: Primary drop shadow
    # Offset y + 12, blur 14, opacity ~ 0.22 black
    s1 = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
    s1_mask = Image.new('L', (1024, 1024), 0)
    s1_mask.paste(icon_824.split()[-1], (100, 100 + 12))
    s1_color = Image.new('RGBA', (1024, 1024), (0, 0, 0, int(255 * 0.22)))
    s1.paste(s1_color, (0, 0), s1_mask)
    s1 = s1.filter(ImageFilter.GaussianBlur(14))

    # Shadow 2: Ambient soft shadow
    # Offset y + 4, blur 6, opacity ~ 0.10 black
    s2 = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
    s2_mask = Image.new('L', (1024, 1024), 0)
    s2_mask.paste(icon_824.split()[-1], (100, 100 + 4))
    s2_color = Image.new('RGBA', (1024, 1024), (0, 0, 0, int(255 * 0.10)))
    s2.paste(s2_color, (0, 0), s2_mask)
    s2 = s2.filter(ImageFilter.GaussianBlur(6))

    # Composite shadows
    canvas_1024 = Image.alpha_composite(canvas_1024, s1)
    canvas_1024 = Image.alpha_composite(canvas_1024, s2)

    # Composite 824x824 squircle icon on top
    icon_pos = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
    icon_pos.paste(icon_824, (100, 100), icon_824)
    canvas_1024 = Image.alpha_composite(canvas_1024, icon_pos)

    sizes = {
        'app_icon_16.png': 16,
        'app_icon_32.png': 32,
        'app_icon_64.png': 64,
        'app_icon_128.png': 128,
        'app_icon_256.png': 256,
        'app_icon_512.png': 512,
        'app_icon_1024.png': 1024,
    }

    os.makedirs(target_dir, exist_ok=True)

    for filename, size in sizes.items():
        out_path = os.path.join(target_dir, filename)
        if size == 1024:
            canvas_1024.save(out_path, 'PNG')
        else:
            resized = canvas_1024.resize((size, size), Image.Resampling.LANCZOS)
            resized.save(out_path, 'PNG')
        print(f'Generated {out_path} ({size}x{size})')

if __name__ == '__main__':
    generate_macos_icons()
