#!/usr/bin/env python3
import gi, os, subprocess, sys, signal, cairo
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GdkPixbuf, Gdk, GLib

# ---------------- Toggle setup ----------------
LOCK_FILE = "/tmp/wallpaper_picker.lock"

if os.path.exists(LOCK_FILE):
    with open(LOCK_FILE, "r") as f:
        pid = int(f.read())
    try:
        os.kill(pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    os.remove(LOCK_FILE)
    sys.exit(0)

with open(LOCK_FILE, "w") as f:
    f.write(str(os.getpid()))

# ---------------- Configuration ----------------
WALL_DIR = os.path.expanduser("~/walls")   # Folder with wallpapers
THUMB_SIZE = 200                           # Diameter of circular thumbnail
SCROLL_STEP = THUMB_SIZE + 20              # Scroll by one thumbnail width
BUTTON_PADDING = 20                        # Padding inside buttons
BOX_MARGIN = 40                             # Padding around the full row

# ---------------- Helpers ----------------
def apply_wallpaper(filepath):
    subprocess.Popen(["swaybg", "-i", filepath, "-m", "fill"])

def smooth_scroll_to(scrolled, target_x):
    adj = scrolled.get_hadjustment()
    current_x = adj.get_value()
    steps = 10
    step_size = (target_x - current_x) / steps

    def scroll_step():
        nonlocal current_x
        current_x += step_size
        if (step_size > 0 and current_x >= target_x) or (step_size < 0 and current_x <= target_x):
            adj.set_value(target_x)
            return False
        adj.set_value(current_x)
        return True

    GLib.timeout_add(16, scroll_step)

def circle_pixbuf(pixbuf):
    # Crop to square
    size = min(pixbuf.get_width(), pixbuf.get_height())
    x_offset = (pixbuf.get_width() - size) // 2
    y_offset = (pixbuf.get_height() - size) // 2
    square = pixbuf.new_subpixbuf(x_offset, y_offset, size, size)
    scaled = square.scale_simple(THUMB_SIZE, THUMB_SIZE, GdkPixbuf.InterpType.BILINEAR)

    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, THUMB_SIZE, THUMB_SIZE)
    ctx = cairo.Context(surface)

    # Draw circle
    ctx.arc(THUMB_SIZE/2, THUMB_SIZE/2, THUMB_SIZE/2, 0, 2*3.1416)
    ctx.close_path()
    ctx.clip()

    # Paint pixbuf
    Gdk.cairo_set_source_pixbuf(ctx, scaled, 0, 0)
    ctx.paint()

    return Gdk.pixbuf_get_from_surface(surface, 0, 0, THUMB_SIZE, THUMB_SIZE)

# ---------------- GTK GUI ----------------
win = Gtk.Window(title="Wallpaper Picker")
win.set_default_size(1400, 450)
win.set_decorated(False)
win.set_type_hint(Gdk.WindowTypeHint.DOCK)

def cleanup(*args):
    if os.path.exists(LOCK_FILE):
        os.remove(LOCK_FILE)
    Gtk.main_quit()

win.connect("destroy", cleanup)

scrolled = Gtk.ScrolledWindow()
scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER)
scrolled.set_shadow_type(Gtk.ShadowType.NONE)
if hasattr(scrolled, "set_overlay_scrolling"):
    scrolled.set_overlay_scrolling(False)
win.add(scrolled)

hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
hbox.set_halign(Gtk.Align.START)
hbox.set_margin_start(BOX_MARGIN)
hbox.set_margin_end(BOX_MARGIN)
hbox.set_margin_top(BOX_MARGIN)
hbox.set_margin_bottom(BOX_MARGIN)
scrolled.add(hbox)

# ---------------- CSS ----------------
css = f"""
window {{ background: #3c3836; }}
scrolledwindow {{ background: #3c3836; }}
button {{
    border: 0;
    background: #3c3836;
    padding-left: {BUTTON_PADDING}px;
    padding-right: {BUTTON_PADDING}px;
    border-radius: {THUMB_SIZE//1}px;      /* make circular */
    box-shadow: 0 4px 8px rgba(0,0,0,0.5); /* shadow for thumbnails */
}}
button:hover {{
    background-color: #282828;
    border-radius: {THUMB_SIZE//1}px;
    box-shadow: 0 6px 12px rgba(0,0,0,0.6); /* stronger shadow on hover */
}}
button:focus {{
    background-color: rgba(255, 255, 255, 0.4);
    outline: none;
    border-radius: {THUMB_SIZE//1}px;
    box-shadow: 0 6px 12px rgba(0,0,0,0.6); /* keep shadow on focus */
}}
"""
style_provider = Gtk.CssProvider()
style_provider.load_from_data(css.encode())
Gtk.StyleContext.add_provider_for_screen(
    Gdk.Screen.get_default(), style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
)

# ---------------- Load wallpapers ----------------
wallpapers = [f for f in os.listdir(WALL_DIR) if f.lower().endswith((".jpg", ".png"))]

for wp in wallpapers:
    filepath = os.path.join(WALL_DIR, wp)
    pixbuf = GdkPixbuf.Pixbuf.new_from_file(filepath)
    circular = circle_pixbuf(pixbuf)

    image = Gtk.Image.new_from_pixbuf(circular)
    button = Gtk.Button()
    button.add(image)
    button.set_can_focus(True)
    button.connect("clicked", lambda w, f=filepath: apply_wallpaper(f))
    hbox.pack_start(button, False, False, 0)

# ---------------- Scroll ----------------
def on_scroll(widget, event):
    adj = scrolled.get_hadjustment()
    target = adj.get_value()
    if event.direction == Gdk.ScrollDirection.UP: target -= SCROLL_STEP
    elif event.direction == Gdk.ScrollDirection.DOWN: target += SCROLL_STEP
    else: return False
    target = max(0, min(target, adj.get_upper()-adj.get_page_size()))
    smooth_scroll_to(scrolled, target)
    return True

scrolled.connect("scroll-event", on_scroll)

win.show_all()
Gtk.main()

