#!/usr/bin/env python3
# Animated wallpaper picker — mirrors ~/walls/wallpaper-picker.py, but the
# thumbnails are extracted from videos with ffmpeg and the wallpaper is applied
# (and the previous one stopped) with mpvpaper.
import gi, os, subprocess, sys, signal, cairo, hashlib
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GdkPixbuf, Gdk, GLib

# Predictable Wayland app_id / WM_CLASS so Hyprland windowrules match.
GLib.set_prgname("anim-wallpaper-picker.py")

# ---------------- Toggle setup ----------------
LOCK_FILE = "/tmp/anim_wallpaper_picker.lock"

if os.path.exists(LOCK_FILE):
    try:
        with open(LOCK_FILE) as f:
            os.kill(int(f.read()), signal.SIGTERM)
    except (ProcessLookupError, ValueError):
        pass
    try:
        os.remove(LOCK_FILE)
    except FileNotFoundError:
        pass
    sys.exit(0)

with open(LOCK_FILE, "w") as f:
    f.write(str(os.getpid()))

# ---------------- Configuration ----------------
# Animated wallpapers live next to this script (mirrors the ~/walls layout).
WALL_DIR   = os.path.dirname(os.path.realpath(__file__))
THUMB_DIR  = os.path.expanduser("~/.cache/anim-wallpaper-thumbs")
STATE_FILE = os.path.expanduser("~/.cache/anim-wallpaper-current")
VIDEO_EXTS = (".mp4", ".webm", ".mkv", ".mov", ".gif", ".m4v", ".avi")

THUMB_SIZE     = 200                # Diameter of circular thumbnail
SCROLL_STEP    = THUMB_SIZE + 20    # Scroll by one thumbnail width
BUTTON_PADDING = 20                 # Padding inside buttons
BOX_MARGIN     = 40                 # Padding around the full row

# mpv options for the wallpaper: muted, looping forever, hw decode, fill screen.
MPV_OPTS = "no-audio --loop-file=inf --hwdec=auto --panscan=1.0"

os.makedirs(THUMB_DIR, exist_ok=True)

# ---------------- Helpers ----------------
def thumb_path(filepath):
    # Cache key = absolute path + mtime, so it refreshes when the file changes.
    key = f"{filepath}:{os.path.getmtime(filepath)}"
    return os.path.join(THUMB_DIR, hashlib.md5(key.encode()).hexdigest() + ".png")

def make_thumb(filepath):
    out = thumb_path(filepath)
    if os.path.exists(out) and os.path.getsize(out) > 0:
        return out
    # Grab a frame ~1s in; fall back to the very first frame for short clips.
    for seek in ("1", "0"):
        subprocess.run(
            ["ffmpeg", "-y", "-ss", seek, "-i", filepath,
             "-frames:v", "1", "-vf", "scale=400:-1", out],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        if os.path.exists(out) and os.path.getsize(out) > 0:
            return out
    return None

def apply_wallpaper(filepath):
    # Stop whatever is currently drawing the background, then start the new clip.
    subprocess.run(["pkill", "-x", "mpvpaper"])
    subprocess.run(["pkill", "-x", "swaybg"])
    subprocess.Popen(
        ["mpvpaper", "-o", MPV_OPTS, "*", filepath],
        start_new_session=True,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    try:
        with open(STATE_FILE, "w") as f:
            f.write(filepath)
    except OSError:
        pass

def smooth_scroll_to(scrolled, target_x):
    adj = scrolled.get_hadjustment()
    current_x = adj.get_value()
    step_size = (target_x - current_x) / 10

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
    ctx.arc(THUMB_SIZE/2, THUMB_SIZE/2, THUMB_SIZE/2, 0, 2*3.1416)
    ctx.close_path()
    ctx.clip()
    Gdk.cairo_set_source_pixbuf(ctx, scaled, 0, 0)
    ctx.paint()
    return Gdk.pixbuf_get_from_surface(surface, 0, 0, THUMB_SIZE, THUMB_SIZE)

# ---------------- GTK GUI ----------------
win = Gtk.Window(title="Animated Wallpapers")
win.set_default_size(1400, 450)
win.set_decorated(False)
win.set_type_hint(Gdk.WindowTypeHint.DOCK)

def cleanup(*args):
    try:
        os.remove(LOCK_FILE)
    except FileNotFoundError:
        pass
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
window {{ background: transparent; }}
scrolledwindow {{ background: transparent; }}
button {{
    border: 0;
    background: transparent;
    padding-left: {BUTTON_PADDING}px;
    padding-right: {BUTTON_PADDING}px;
    border-radius: {THUMB_SIZE}px;      /* make hover circular */
}}
button:hover {{
    background-color: rgba(255, 255, 255, 0.3);
    border-radius: {THUMB_SIZE}px;
}}
button:focus {{
    background-color: rgba(255, 255, 255, 0.3);
    outline: none;
    box-shadow: none;
    border-radius: {THUMB_SIZE}px;
}}
label {{ color: #ffffff; font-size: 16px; }}
"""
style_provider = Gtk.CssProvider()
style_provider.load_from_data(css.encode())
Gtk.StyleContext.add_provider_for_screen(
    Gdk.Screen.get_default(), style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
)

# ---------------- Load animated wallpapers ----------------
videos = sorted(f for f in os.listdir(WALL_DIR) if f.lower().endswith(VIDEO_EXTS))

if not videos:
    hbox.pack_start(
        Gtk.Label(label=f"Nenhum wallpaper animado em {WALL_DIR}\n"
                        f"Coloque arquivos .mp4 / .webm / .gif nessa pasta."),
        True, True, 0)
else:
    for wp in videos:
        filepath = os.path.join(WALL_DIR, wp)
        thumb = make_thumb(filepath)
        if not thumb:
            continue
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file(thumb)
        except Exception:
            continue
        image = Gtk.Image.new_from_pixbuf(circle_pixbuf(pixbuf))
        button = Gtk.Button()
        button.add(image)
        button.set_can_focus(True)
        button.connect("clicked", lambda w, f=filepath: apply_wallpaper(f))
        hbox.pack_start(button, False, False, 0)

# ---------------- Scroll ----------------
def on_scroll(widget, event):
    adj = scrolled.get_hadjustment()
    target = adj.get_value()
    if event.direction == Gdk.ScrollDirection.UP:
        target -= SCROLL_STEP
    elif event.direction == Gdk.ScrollDirection.DOWN:
        target += SCROLL_STEP
    else:
        return False
    target = max(0, min(target, adj.get_upper() - adj.get_page_size()))
    smooth_scroll_to(scrolled, target)
    return True

scrolled.connect("scroll-event", on_scroll)

win.show_all()
Gtk.main()
