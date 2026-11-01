class_name SafeArea
extends RefCounted

# Minimum breathing room (viewport px) even on screens with no notch.
const MIN_SIDE := 14.0
const MIN_TOP := 24.0
const MIN_BOTTOM := 24.0

# Insets as Vector4(left, top, right, bottom) in viewport units.
static func insets(vp: Viewport) -> Vector4:
	var m := Vector4(MIN_SIDE, MIN_TOP, MIN_SIDE, MIN_BOTTOM)
	# shortcut: only Android/iOS report real cutouts; web/desktop get the minimums, upgrade if browser env(safe-area-inset) is needed
	var os_name := OS.get_name()
	if os_name != "Android" and os_name != "iOS":
		return m
	var win := Vector2(DisplayServer.window_get_size())
	if win.x <= 0.0 or win.y <= 0.0:
		return m
	var safe := Rect2(DisplayServer.get_display_safe_area())
	var k := vp.get_visible_rect().size / win
	m.x = maxf(m.x, safe.position.x * k.x)
	m.y = maxf(m.y, safe.position.y * k.y)
	m.z = maxf(m.z, (win.x - safe.end.x) * k.x)
	m.w = maxf(m.w, (win.y - safe.end.y) * k.y)
	return m

# Shrinks every full-rect CenterContainer under `node` to the safe area (backdrops stay full screen).
static func apply_centers(node: Node, ins: Vector4) -> void:
	for c in node.get_children():
		if c is CenterContainer:
			c.offset_left = ins.x
			c.offset_top = ins.y
			c.offset_right = -ins.z
			c.offset_bottom = -ins.w
		apply_centers(c, ins)

# Adds `ins` on top of a MarginContainer's authored margins (remembered in meta so repeated calls don't stack).
static func apply_margin(mc: MarginContainer, ins: Vector4) -> void:
	if not mc.has_meta("base_margins"):
		mc.set_meta("base_margins", Vector4(
			mc.get_theme_constant("margin_left"), mc.get_theme_constant("margin_top"),
			mc.get_theme_constant("margin_right"), mc.get_theme_constant("margin_bottom")))
	var b: Vector4 = mc.get_meta("base_margins")
	mc.add_theme_constant_override("margin_left", int(b.x + ins.x))
	mc.add_theme_constant_override("margin_top", int(b.y + ins.y))
	mc.add_theme_constant_override("margin_right", int(b.z + ins.z))
	mc.add_theme_constant_override("margin_bottom", int(b.w + ins.w))

# Moves a top/bottom anchored banner away from the edge by the inset (authored offsets remembered).
static func nudge(c: Control, dy_top: float, dy_bottom: float) -> void:
	if not c.has_meta("base_off"):
		c.set_meta("base_off", Vector2(c.offset_top, c.offset_bottom))
	var b: Vector2 = c.get_meta("base_off")
	c.offset_top = b.x + dy_top - dy_bottom
	c.offset_bottom = b.y + dy_top - dy_bottom
