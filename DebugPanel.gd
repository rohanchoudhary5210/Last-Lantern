class_name DebugPanel
extends CanvasLayer

@export var debug_config: DebugConfigData

@onready var panel_container: PanelContainer = $Overlay/PanelContainer
@onready var stats_label: Label = $Overlay/PanelContainer/MarginContainer/VBox/StatsBox/StatsLabel
@onready var close_btn: Button = $Overlay/PanelContainer/MarginContainer/VBox/Header/CloseButton
@onready var god_mode_btn: Button = $Overlay/PanelContainer/MarginContainer/VBox/Scroll/Content/GeneralBox/GodModeButton
@onready var time_btn: Button = $Overlay/PanelContainer/MarginContainer/VBox/Scroll/Content/GeneralBox/TimeButton
@onready var souls_btn: Button = $Overlay/PanelContainer/MarginContainer/VBox/Scroll/Content/GeneralBox/SoulsButton
@onready var weapon_lvl_btn: Button = $Overlay/PanelContainer/MarginContainer/VBox/Scroll/Content/GeneralBox/WeaponLevelButton
@onready var crate_btn: Button = $Overlay/PanelContainer/MarginContainer/VBox/Scroll/Content/GeneralBox/CrateButton
@onready var boss_btn: Button = $Overlay/PanelContainer/MarginContainer/VBox/Scroll/Content/SpawningBox/BossButton
@onready var enemy_buttons_grid: GridContainer = $Overlay/PanelContainer/MarginContainer/VBox/Scroll/Content/SpawningBox/EnemyButtonsGrid
@onready var quick_toggle_btn: Button = $QuickToggleBtn

var main_node: Node2D = null
var is_god_mode_active: bool = false
var enemy_buttons_built: bool = false

func _ready() -> void:
	if not OS.is_debug_build():
		hide()
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false)
		queue_free()
		return
	
	if debug_config == null:
		debug_config = load("res://data/debug_config.tres")
	
	panel_container.visible = false
	_apply_button_labels()
	_connect_controls()

func _get_main() -> Node2D:
	if main_node != null and is_instance_valid(main_node):
		return main_node
	var p = get_parent()
	if p != null and p.name == "Main":
		main_node = p
		return main_node
	var cur = get_tree().current_scene
	if cur != null and cur.name == "Main":
		main_node = cur
		return main_node
	return null

func _apply_button_labels() -> void:
	if debug_config != null:
		time_btn.text = "+ %ds Game Time" % int(debug_config.add_time_amount)
		souls_btn.text = "+ %d Souls" % debug_config.add_souls_amount
		weapon_lvl_btn.text = "Set Weapon Lv. %d" % debug_config.target_weapon_level
	else:
		time_btn.text = "+ 60s Game Time"
		souls_btn.text = "+ 1000 Souls"
		weapon_lvl_btn.text = "Set Weapon Lv. 5"

func _connect_controls() -> void:
	close_btn.pressed.connect(toggle_overlay)
	quick_toggle_btn.pressed.connect(toggle_overlay)
	
	god_mode_btn.pressed.connect(_on_god_mode_pressed)
	time_btn.pressed.connect(_on_time_pressed)
	souls_btn.pressed.connect(_on_souls_pressed)
	weapon_lvl_btn.pressed.connect(_on_weapon_level_pressed)
	crate_btn.pressed.connect(_on_crate_pressed)
	boss_btn.pressed.connect(_on_boss_pressed)
	
	# Prevent buttons from trapping keyboard focus
	close_btn.focus_mode = Control.FOCUS_NONE
	quick_toggle_btn.focus_mode = Control.FOCUS_NONE
	god_mode_btn.focus_mode = Control.FOCUS_NONE
	time_btn.focus_mode = Control.FOCUS_NONE
	souls_btn.focus_mode = Control.FOCUS_NONE
	weapon_lvl_btn.focus_mode = Control.FOCUS_NONE
	crate_btn.focus_mode = Control.FOCUS_NONE
	boss_btn.focus_mode = Control.FOCUS_NONE

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			toggle_overlay()
			get_viewport().set_input_as_handled()

func toggle_overlay() -> void:
	panel_container.visible = not panel_container.visible
	if panel_container.visible:
		_build_enemy_buttons_if_needed()
		_update_god_mode_ui()

func _process(_delta: float) -> void:
	if not panel_container.visible:
		return
	
	var main = _get_main()
	var live_count = main.get_live_enemy_count() if (main != null and main.has_method("get_live_enemy_count")) else 0
	var fps = Engine.get_frames_per_second()
	stats_label.text = "FPS: %d   |   Live Enemies: %d" % [fps, live_count]

func _build_enemy_buttons_if_needed() -> void:
	if enemy_buttons_built:
		return
	var main = _get_main()
	if main == null or not ("enemies" in main) or main.enemies.is_empty():
		return
	
	for child in enemy_buttons_grid.get_children():
		child.queue_free()
	
	for enemy in main.enemies:
		if enemy == null or enemy.is_boss:
			continue # Boss has dedicated prominent button
		
		var btn = Button.new()
		btn.text = "+ " + enemy.name
		btn.custom_minimum_size = Vector2(140, 36)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
		btn.pressed.connect(func():
			var m = _get_main()
			if m != null and m.has_method("debug_spawn_enemy"):
				m.debug_spawn_enemy(enemy)
		)
		enemy_buttons_grid.add_child(btn)
	
	enemy_buttons_built = true

func _update_god_mode_ui() -> void:
	var main = _get_main()
	if main != null and "player" in main and main.player != null and "is_god_mode" in main.player:
		is_god_mode_active = main.player.is_god_mode
	
	if is_god_mode_active:
		god_mode_btn.text = "God Mode: [ ON ]"
		god_mode_btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		god_mode_btn.text = "God Mode: [ OFF ]"
		god_mode_btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

func _on_god_mode_pressed() -> void:
	var main = _get_main()
	if main != null and main.has_method("debug_toggle_god_mode"):
		is_god_mode_active = main.debug_toggle_god_mode()
	_update_god_mode_ui()

func _on_time_pressed() -> void:
	var main = _get_main()
	if main != null and main.has_method("debug_add_time"):
		var amt = debug_config.add_time_amount if debug_config != null else 60.0
		main.debug_add_time(amt)

func _on_souls_pressed() -> void:
	var main = _get_main()
	if main != null and main.has_method("debug_add_souls"):
		var amt = debug_config.add_souls_amount if debug_config != null else 1000
		main.debug_add_souls(amt)

func _on_weapon_level_pressed() -> void:
	var main = _get_main()
	if main != null and main.has_method("debug_set_weapon_level"):
		var lvl = debug_config.target_weapon_level if debug_config != null else 5
		main.debug_set_weapon_level(lvl)

func _on_crate_pressed() -> void:
	var main = _get_main()
	if main != null and main.has_method("debug_give_crate"):
		var offset = debug_config.crate_spawn_offset if debug_config != null else Vector2(70.0, 0.0)
		main.debug_give_crate(offset)

func _on_boss_pressed() -> void:
	var main = _get_main()
	if main != null and main.has_method("debug_spawn_boss"):
		var dist = debug_config.boss_spawn_distance if debug_config != null else 280.0
		main.debug_spawn_boss(dist)
