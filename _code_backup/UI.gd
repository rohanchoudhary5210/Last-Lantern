extends CanvasLayer

signal hero_selected(hero: HeroData)
signal upgrade_selected(upgrade: UpgradeData)
signal retry_pressed
signal win_continue_pressed
signal win_menu_pressed

@export var card_bg_texture: Texture2D
@export var game_feel: GameFeelData

@onready var hp_progress_bar: ProgressBar = $HUD/MarginContainer/TopBox/Row2/HPContainer/HPProgressBar
@onready var hp_label: Label = $HUD/MarginContainer/TopBox/Row2/HPContainer/HPLabel
@onready var weapon_label: Label = $HUD/MarginContainer/TopBox/Row2/WeaponBox/WeaponLabel
@onready var evo_progress_label: Label = $HUD/MarginContainer/TopBox/Row2/WeaponBox/EvoProgressLabel
@onready var time_label: Label = $HUD/MarginContainer/TopBox/Row1/TimeLabel
@onready var kills_label: Label = $HUD/MarginContainer/TopBox/Row1/KillsLabel
@onready var souls_label: Label = $HUD/MarginContainer/TopBox/Row1/SoulsLabel
@onready var airdrop_label: Label = $HUD/MarginContainer/TopBox/Row1/AirdropLabel
@onready var pause_button: Button = $HUD/MarginContainer/TopBox/Row1/PauseButton
@onready var passives_row: HBoxContainer = $HUD/MarginContainer/TopBox/PassivesRow
@onready var deck_row: HBoxContainer = $HUD/MarginContainer/TopBox/DeckRow

@onready var card_reward_banner: PanelContainer = $HUD/CardRewardBanner
@onready var reward_icon: TextureRect = $HUD/CardRewardBanner/Margin/HBox/RewardIcon
@onready var reward_name: Label = $HUD/CardRewardBanner/Margin/HBox/VBox/RewardName
@onready var reward_desc: Label = $HUD/CardRewardBanner/Margin/HBox/VBox/RewardDesc

@onready var boss_bar_container: VBoxContainer = $HUD/MarginContainer/TopBox/BossBarContainer
@onready var boss_name_label: Label = $HUD/MarginContainer/TopBox/BossBarContainer/BossNameLabel
@onready var boss_progress_bar: ProgressBar = $HUD/MarginContainer/TopBox/BossBarContainer/BossProgressBar

@onready var joystick_zone: Control = $HUD/JoystickZone
@onready var joystick_base: TextureRect = $HUD/JoystickZone/JoystickBase
@onready var joystick_knob: TextureRect = $HUD/JoystickZone/JoystickBase/JoystickKnob

@onready var hero_select_modal: Control = $HeroSelectModal
@onready var hero_cards_container: VBoxContainer = $HeroSelectModal/CenterContainer/VBox/HeroCardsContainer
@onready var deck_label: Label = $HeroSelectModal/CenterContainer/VBox/DeckBar/Margin/HBox/DeckLabel
@onready var deck_slots_row: HBoxContainer = $HeroSelectModal/CenterContainer/VBox/DeckBar/Margin/HBox/DeckSlotsRow
@onready var configure_deck_btn: Button = $HeroSelectModal/CenterContainer/VBox/DeckBar/Margin/HBox/ConfigureDeckBtn

@onready var deck_modal: Control = $HeroSelectModal/DeckModal
@onready var deck_active_count: Label = $HeroSelectModal/DeckModal/CenterContainer/DeckVBox/DeckActiveCount
@onready var deck_cards_container: VBoxContainer = $HeroSelectModal/DeckModal/CenterContainer/DeckVBox/ScrollContainer/CardsContainer
@onready var deck_done_btn: Button = $HeroSelectModal/DeckModal/CenterContainer/DeckVBox/DeckDoneBtn

@onready var upgrade_modal: Control = $UpgradeModal
@onready var weapon_upgrade_notice: Label = $UpgradeModal/CenterContainer/VBox/WeaponUpgradeNotice
@onready var cards_container: VBoxContainer = $UpgradeModal/CenterContainer/VBox/CardsContainer

@onready var pause_modal: Control = $PauseModal
@onready var resume_btn: Button = $PauseModal/CenterContainer/VBox/ResumeButton
@onready var pause_settings_btn: Button = $PauseModal/CenterContainer/VBox/PauseSettingsButton
@onready var restart_btn: Button = $PauseModal/CenterContainer/VBox/RestartButton
@onready var pause_main_menu_btn: Button = $PauseModal/CenterContainer/VBox/MainMenuButton

@onready var settings_modal: Control = $SettingsModal
@onready var music_label: Label = $SettingsModal/CenterContainer/VBox/MusicBox/MusicLabel
@onready var music_slider: HSlider = $SettingsModal/CenterContainer/VBox/MusicBox/MusicSlider
@onready var sfx_label: Label = $SettingsModal/CenterContainer/VBox/SFXBox/SFXLabel
@onready var sfx_slider: HSlider = $SettingsModal/CenterContainer/VBox/SFXBox/SFXSlider
@onready var settings_close_btn: Button = $SettingsModal/CenterContainer/VBox/SettingsCloseBtn

@onready var game_over_modal: Control = $GameOverModal
@onready var game_over_title: Label = $GameOverModal/CenterContainer/VBox/Title
@onready var new_best_time_lbl: Label = $GameOverModal/CenterContainer/VBox/NewBestTimeLabel
@onready var new_best_kills_lbl: Label = $GameOverModal/CenterContainer/VBox/NewBestKillsLabel
@onready var game_over_stats: Label = $GameOverModal/CenterContainer/VBox/StatsLabel
@onready var retry_button: Button = $GameOverModal/CenterContainer/VBox/ButtonRow/RetryButton
@onready var game_over_menu_btn: Button = $GameOverModal/CenterContainer/VBox/ButtonRow/GameOverMenuButton

@onready var curse_banner: PanelContainer = $HUD/CurseBanner
@onready var curse_title: Label = $HUD/CurseBanner/Margin/VBox/CurseTitle
@onready var curse_desc: Label = $HUD/CurseBanner/Margin/VBox/CurseDesc

@onready var hint_banner: PanelContainer = $HUD/HintBanner
@onready var hint_label: Label = $HUD/HintBanner/Margin/HintLabel

@onready var pause_curse_label: Label = $PauseModal/CenterContainer/VBox/PauseCurseLabel

@onready var win_modal: Control = $WinModal
@onready var win_title: Label = $WinModal/CenterContainer/VBox/Title
@onready var win_subtitle: Label = $WinModal/CenterContainer/VBox/Subtitle
@onready var win_stats_label: Label = $WinModal/CenterContainer/VBox/StatsLabel
@onready var win_continue_btn: Button = $WinModal/CenterContainer/VBox/ButtonRow/ContinueButton
@onready var win_menu_btn: Button = $WinModal/CenterContainer/VBox/ButtonRow/WinMenuButton

var player_ref: Node2D = null
var is_dragging: bool = false
var touch_origin: Vector2 = Vector2.ZERO
var max_radius: float = 50.0

func _ready() -> void:
	if card_bg_texture == null:
		card_bg_texture = load("res://assets/ui/card_banner_bg.png")
	if game_feel == null:
		game_feel = load("res://data/game_feel.tres")
	
	_init_settings()
	
	# Connect UI buttons
	pause_button.pressed.connect(_on_pause_pressed)
	resume_btn.pressed.connect(_on_resume_pressed)
	pause_settings_btn.pressed.connect(_on_settings_open_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	pause_main_menu_btn.pressed.connect(_on_main_menu_pressed)
	
	settings_close_btn.pressed.connect(_on_settings_close_pressed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	retry_button.pressed.connect(_on_retry_pressed)
	game_over_menu_btn.pressed.connect(_on_main_menu_pressed)
	
	win_continue_btn.pressed.connect(_on_win_continue_pressed)
	win_menu_btn.pressed.connect(_on_win_menu_pressed)
	
	configure_deck_btn.pressed.connect(_on_configure_deck_pressed)
	deck_done_btn.pressed.connect(_on_deck_done_pressed)
	
	upgrade_modal.visible = false
	pause_modal.visible = false
	settings_modal.visible = false
	game_over_modal.visible = false
	win_modal.visible = false
	boss_bar_container.visible = false
	joystick_base.visible = false
	card_reward_banner.visible = false
	deck_modal.visible = false
	curse_banner.visible = false
	hint_banner.visible = false
	
	joystick_zone.gui_input.connect(_on_joystick_gui_input)

func _init_settings() -> void:
	var settings = SaveManager.load_settings(game_feel)
	var m_val = settings.get("music_linear", 0.5)
	var s_val = settings.get("sfx_linear", 1.0)
	
	music_slider.value = m_val
	sfx_slider.value = s_val
	_update_settings_labels(m_val, s_val)

func _update_settings_labels(m_val: float, s_val: float) -> void:
	music_label.text = "MUSIC VOLUME: %d%%" % int(round(m_val * 100.0))
	sfx_label.text = "SFX VOLUME: %d%%" % int(round(s_val * 100.0))

func _on_music_slider_changed(val: float) -> void:
	_update_settings_labels(val, sfx_slider.value)
	SaveManager.save_settings(val, sfx_slider.value)

func _on_sfx_slider_changed(val: float) -> void:
	_update_settings_labels(music_slider.value, val)
	SaveManager.save_settings(music_slider.value, val)

func _on_pause_pressed() -> void:
	_stop_joystick()
	pause_modal.visible = true
	get_tree().paused = true

func _on_resume_pressed() -> void:
	pause_modal.visible = false
	get_tree().paused = false

func _on_settings_open_pressed() -> void:
	settings_modal.visible = true

func _on_settings_close_pressed() -> void:
	settings_modal.visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _get_player() -> Node2D:
	if player_ref == null or not is_instance_valid(player_ref):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player_ref = players[0]
	return player_ref

func update_hp(current: float, max_val: float) -> void:
	hp_progress_bar.max_value = max_val
	hp_progress_bar.value = current
	hp_label.text = "%d / %d" % [int(current), int(max_val)]

func update_weapon_status(weapon_name: String, rarity_name: String, rarity_color: Color, base_color: Color, level: int = 1, max_level: int = 5, is_evolved: bool = false, evo_status: Dictionary = {}) -> void:
	if is_evolved:
		weapon_label.text = "★ %s (EVOLVED) ★" % weapon_name.to_upper()
		weapon_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
		weapon_label.add_theme_color_override("font_outline_color", Color(0.9, 0.4, 0.0))
		weapon_label.add_theme_constant_override("outline_size", 4)
		if evo_progress_label != null:
			evo_progress_label.text = "★ ULTIMATE ARSENAL ★"
			evo_progress_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		weapon_label.text = "[%s] %s [LV %d/%d]" % [rarity_name.to_upper(), weapon_name.to_upper(), level, max_level]
		weapon_label.add_theme_color_override("font_color", base_color)
		weapon_label.add_theme_color_override("font_outline_color", rarity_color)
		weapon_label.add_theme_constant_override("outline_size", 4)
		
		if evo_progress_label != null:
			if evo_status.get("has_evo", false):
				if evo_status.get("is_ready", false):
					evo_progress_label.text = "✦ EVOLUTION READY! (OPEN CRATE) ✦"
					evo_progress_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5))
				else:
					var lvl_icon = "✔" if evo_status.get("lvl_met", false) else "✖"
					var upg_icon = "✔" if evo_status.get("upg_met", false) else "✖"
					var req_upg = evo_status.get("req_upg_name", "Upgrade")
					evo_progress_label.text = "EVO: Lv.%d/5 %s | %s %s" % [level, lvl_icon, req_upg, upg_icon]
					evo_progress_label.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
			else:
				evo_progress_label.text = "LEVEL %d / %d" % [level, max_level]
				evo_progress_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))

func update_weapon_with_rarity(weapon_name: String, rarity_name: String, rarity_color: Color, base_color: Color) -> void:
	update_weapon_status(weapon_name, rarity_name, rarity_color, base_color)

func update_weapon(weapon_name: String, weapon_color: Color) -> void:
	update_weapon_with_rarity(weapon_name, "Common", Color(0.8, 0.8, 0.8), weapon_color)

func update_time(seconds: float) -> void:
	var total_secs = int(seconds)
	var mins = total_secs / 60
	var secs = total_secs % 60
	time_label.text = "%02d:%02d" % [mins, secs]

func update_kills(kills: int) -> void:
	kills_label.text = "KILLS: %d" % kills

func update_souls(count: int) -> void:
	if souls_label != null:
		souls_label.text = "✦ %d" % count

func update_airdrop_timer(seconds_left: float) -> void:
	airdrop_label.text = "CRATE: %ds" % max(0, int(seconds_left))

func update_passives(passive_levels: Dictionary, passive_resources: Dictionary, revives_left: int = 0) -> void:
	if passives_row == null:
		return
	
	for c in passives_row.get_children():
		c.queue_free()
	
	for id in passive_levels:
		var lvl = passive_levels[id]
		var res: UpgradeData = passive_resources.get(id, null)
		if res == null:
			continue
		
		var badge = PanelContainer.new()
		badge.custom_minimum_size = Vector2(34, 34)
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.12, 0.18, 0.92)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(0.2, 0.8, 1.0, 0.85)
		sb.corner_radius_top_left = 4
		sb.corner_radius_top_right = 4
		sb.corner_radius_bottom_right = 4
		sb.corner_radius_bottom_left = 4
		badge.add_theme_stylebox_override("panel", sb)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 3)
		margin.add_theme_constant_override("margin_top", 3)
		margin.add_theme_constant_override("margin_right", 3)
		margin.add_theme_constant_override("margin_bottom", 3)
		badge.add_child(margin)
		
		var tex_rect = TextureRect.new()
		tex_rect.texture = res.sprite
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		margin.add_child(tex_rect)
		
		var lvl_lbl = Label.new()
		if id == "revive":
			lvl_lbl.text = "x%d" % revives_left
			lvl_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
		else:
			lvl_lbl.text = "L%d" % lvl
			lvl_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5))
		
		lvl_lbl.add_theme_font_size_override("font_size", 10)
		lvl_lbl.add_theme_constant_override("outline_size", 2)
		lvl_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lvl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lvl_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		margin.add_child(lvl_lbl)
		
		passives_row.add_child(badge)

func update_boss_hp(current: float, max_val: float, boss_name: String = "ABOMINATION (BOSS)") -> void:
	boss_bar_container.visible = true
	boss_name_label.text = boss_name.to_upper()
	boss_progress_bar.max_value = max_val
	boss_progress_bar.value = current

func hide_boss_hp() -> void:
	boss_bar_container.visible = false

# -------------------------------------------------------------
# HERO SELECT MODAL & DECK MANAGEMENT (PHASE 8)
# -------------------------------------------------------------
var cards_catalog: Dictionary = {}
var rarity_data: RarityData = null

func _init_cards_catalog() -> void:
	if not cards_catalog.is_empty():
		return
	rarity_data = load("res://data/rarities.tres")
	var card_paths = [
		"res://data/cards/card_damage.tres",
		"res://data/cards/card_fire_rate.tres",
		"res://data/cards/card_max_hp.tres",
		"res://data/cards/card_move_speed.tres",
		"res://data/cards/card_torch_radius.tres",
		"res://data/cards/card_soul_gain.tres",
		"res://data/cards/card_magnet_radius.tres",
		"res://data/cards/card_crate_drop_chance.tres",
		"res://data/cards/card_first_hit_shield.tres",
		"res://data/cards/card_boss_damage.tres",
		"res://data/cards/card_revive_once.tres",
		"res://data/cards/card_lifesteal.tres"
	]
	for p in card_paths:
		var c = load(p)
		if c != null and "id" in c:
			cards_catalog[c.id] = c

func _get_rarity_color(rarity: String) -> Color:
	if rarity_data != null:
		match rarity:
			"Rare": return rarity_data.rare_color
			"Epic": return rarity_data.epic_color
			_: return rarity_data.common_color
	match rarity:
		"Rare": return Color(0.2, 0.75, 1.0)
		"Epic": return Color(0.85, 0.3, 1.0)
		_: return Color(0.8, 0.8, 0.8)

func show_hero_select(heroes: Array[HeroData]) -> void:
	_stop_joystick()
	_init_cards_catalog()
	_refresh_hero_deck_bar()
	
	for child in hero_cards_container.get_children():
		child.queue_free()
	
	for hero in heroes:
		var card = _create_hero_card(hero)
		hero_cards_container.add_child(card)
	
	hero_select_modal.visible = true
	get_tree().paused = true

func _refresh_hero_deck_bar() -> void:
	_init_cards_catalog()
	var equipped_ids = SaveManager.get_equipped_cards()
	var collection = SaveManager.get_card_collection()
	deck_label.text = "EQUIPPED DECK (%d/3):" % equipped_ids.size()
	
	for child in deck_slots_row.get_children():
		child.queue_free()
	
	for i in range(3):
		if i < equipped_ids.size():
			var cid = equipped_ids[i]
			var card: CardData = cards_catalog.get(cid, null)
			if card != null:
				var lvl = 1
				if collection.has(cid):
					var entry = collection[cid]
					lvl = maxi(1, int(entry.get("level", 1))) if typeof(entry) == TYPE_DICTIONARY else maxi(1, int(entry))
				
				var badge = PanelContainer.new()
				badge.custom_minimum_size = Vector2(100, 36)
				var st = StyleBoxFlat.new()
				st.bg_color = Color(0.1, 0.12, 0.18, 0.95)
				st.border_color = _get_rarity_color(card.rarity)
				st.set_border_width_all(2)
				st.set_corner_radius_all(5)
				badge.add_theme_stylebox_override("panel", st)
				
				var hb = HBoxContainer.new()
				hb.alignment = BoxContainer.ALIGNMENT_CENTER
				hb.add_theme_constant_override("separation", 6)
				badge.add_child(hb)
				
				var ic = TextureRect.new()
				ic.texture = card.icon
				ic.custom_minimum_size = Vector2(24, 24)
				ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				hb.add_child(ic)
				
				var lb = Label.new()
				lb.text = "%s L%d" % [card.name.substr(0, 6), lvl]
				lb.add_theme_font_size_override("font_size", 11)
				lb.add_theme_color_override("font_color", _get_rarity_color(card.rarity))
				hb.add_child(lb)
				
				deck_slots_row.add_child(badge)
		else:
			var empty_panel = PanelContainer.new()
			empty_panel.custom_minimum_size = Vector2(90, 36)
			var est = StyleBoxFlat.new()
			est.bg_color = Color(0.06, 0.07, 0.1, 0.6)
			est.border_color = Color(0.25, 0.28, 0.35, 0.8)
			est.set_border_width_all(1)
			est.set_corner_radius_all(5)
			empty_panel.add_theme_stylebox_override("panel", est)
			
			var elbl = Label.new()
			elbl.text = "[ Empty ]"
			elbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			elbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			elbl.add_theme_font_size_override("font_size", 11)
			elbl.add_theme_color_override("font_color", Color(0.45, 0.48, 0.55))
			empty_panel.add_child(elbl)
			deck_slots_row.add_child(empty_panel)

func _on_configure_deck_pressed() -> void:
	deck_modal.visible = true
	_refresh_deck_modal()

func _on_deck_done_pressed() -> void:
	deck_modal.visible = false
	_refresh_hero_deck_bar()

func _refresh_deck_modal() -> void:
	_init_cards_catalog()
	var equipped_ids = SaveManager.get_equipped_cards()
	var collection = SaveManager.get_card_collection()
	
	deck_active_count.text = "Equipped Cards: %d / 3" % equipped_ids.size()
	
	for child in deck_cards_container.get_children():
		child.queue_free()
	
	if collection.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No cards collected yet!\nOpen card packs in the Card Shop or defeat bosses to unlock cards."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
		empty_lbl.add_theme_font_size_override("font_size", 15)
		deck_cards_container.add_child(empty_lbl)
		return
	
	for card_id in cards_catalog:
		var card: CardData = cards_catalog[card_id]
		if not collection.has(card_id):
			continue
		
		var entry = collection[card_id]
		var lvl = maxi(1, int(entry.get("level", 1))) if typeof(entry) == TYPE_DICTIONARY else maxi(1, int(entry))
		var is_equipped = equipped_ids.has(card_id)
		
		var row = TextureRect.new()
		row.texture = card_bg_texture
		row.custom_minimum_size = Vector2(580, 80)
		row.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		row.stretch_mode = TextureRect.STRETCH_SCALE
		
		var margin = MarginContainer.new()
		margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 8)
		row.add_child(margin)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		margin.add_child(hbox)
		
		var icon_panel = PanelContainer.new()
		icon_panel.custom_minimum_size = Vector2(48, 48)
		icon_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.08, 0.08, 0.12, 0.9)
		st.border_color = _get_rarity_color(card.rarity)
		st.set_border_width_all(2)
		st.set_corner_radius_all(6)
		icon_panel.add_theme_stylebox_override("panel", st)
		
		var ic = TextureRect.new()
		ic.texture = card.icon
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_panel.add_child(ic)
		hbox.add_child(icon_panel)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = "%s [LV. %d/%d]" % [card.name.to_upper(), lvl, card.max_level]
		name_lbl.add_theme_color_override("font_color", _get_rarity_color(card.rarity))
		name_lbl.add_theme_font_size_override("font_size", 15)
		vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = card.description
		desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
		desc_lbl.add_theme_font_size_override("font_size", 12)
		vbox.add_child(desc_lbl)
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(110, 42)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.add_theme_font_size_override("font_size", 14)
		
		if is_equipped:
			btn.text = "UNEQUIP"
			btn.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
			btn.pressed.connect(func():
				var cur = SaveManager.get_equipped_cards()
				cur.erase(card_id)
				SaveManager.set_equipped_cards(cur)
				_refresh_deck_modal()
			)
		else:
			btn.text = "EQUIP"
			if equipped_ids.size() >= 3:
				btn.disabled = true
				btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			else:
				btn.disabled = false
				btn.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
				btn.pressed.connect(func():
					var cur = SaveManager.get_equipped_cards()
					if cur.size() < 3 and not cur.has(card_id):
						cur.append(card_id)
						SaveManager.set_equipped_cards(cur)
					_refresh_deck_modal()
				)
		
		hbox.add_child(btn)
		deck_cards_container.add_child(row)

func update_deck(cards: Array, collection: Dictionary) -> void:
	_init_cards_catalog()
	for child in deck_row.get_children():
		child.queue_free()
	
	for card in cards:
		if card == null:
			continue
		var lvl = 1
		if collection.has(card.id):
			var entry = collection[card.id]
			lvl = maxi(1, int(entry.get("level", 1))) if typeof(entry) == TYPE_DICTIONARY else maxi(1, int(entry))
		
		var badge = PanelContainer.new()
		badge.custom_minimum_size = Vector2(36, 36)
		badge.mouse_filter = Control.MOUSE_FILTER_PASS
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.08, 0.1, 0.15, 0.85)
		st.border_color = _get_rarity_color(card.rarity)
		st.set_border_width_all(2)
		st.set_corner_radius_all(6)
		badge.add_theme_stylebox_override("panel", st)
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = card.icon
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		badge.add_child(icon_rect)
		
		var lvl_lbl = Label.new()
		lvl_lbl.text = "L%d" % lvl
		lvl_lbl.add_theme_font_size_override("font_size", 10)
		lvl_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
		lvl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lvl_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		badge.add_child(lvl_lbl)
		
		badge.tooltip_text = "%s (Lv.%d)\n%s" % [card.name, lvl, card.description]
		deck_row.add_child(badge)

func show_card_reward_banner(card: CardData) -> void:
	if card == null:
		return
	_init_cards_catalog()
	reward_icon.texture = card.icon
	reward_name.text = "%s [%s]" % [card.name, card.rarity]
	reward_name.add_theme_color_override("font_color", _get_rarity_color(card.rarity))
	reward_desc.text = card.description
	
	card_reward_banner.visible = true
	card_reward_banner.modulate.a = 0.0
	card_reward_banner.scale = Vector2(0.85, 0.85)
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(card_reward_banner, "modulate:a", 1.0, 0.3)
	tw.tween_property(card_reward_banner, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	get_tree().create_timer(3.5).timeout.connect(func():
		if is_instance_valid(card_reward_banner) and card_reward_banner.visible:
			var tw_out = create_tween()
			tw_out.tween_property(card_reward_banner, "modulate:a", 0.0, 0.4)
			tw_out.tween_callback(func(): card_reward_banner.visible = false)
	)

func show_curse_banner(curse: CurseData) -> void:
	if curse == null:
		return
	curse_title.text = "⚡ DAILY CURSE ACTIVE: " + curse.name.to_upper()
	curse_desc.text = curse.description
	pause_curse_label.text = "⚡ ACTIVE CURSE: %s\n%s" % [curse.name, curse.description]
	
	curse_banner.visible = true
	curse_banner.modulate.a = 0.0
	curse_banner.scale = Vector2(0.9, 0.9)
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(curse_banner, "modulate:a", 1.0, 0.3)
	tw.tween_property(curse_banner, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	get_tree().create_timer(4.5).timeout.connect(func():
		if is_instance_valid(curse_banner) and curse_banner.visible:
			var tw_out = create_tween()
			tw_out.tween_property(curse_banner, "modulate:a", 0.0, 0.5)
			tw_out.tween_callback(func(): curse_banner.visible = false)
	)

func show_hint(text: String, duration: float = 5.0) -> void:
	hint_label.text = text
	hint_banner.visible = true
	hint_banner.modulate.a = 0.0
	
	var tw = create_tween()
	tw.tween_property(hint_banner, "modulate:a", 1.0, 0.3)
	
	get_tree().create_timer(duration).timeout.connect(func():
		if is_instance_valid(hint_banner) and hint_banner.visible:
			var tw_out = create_tween()
			tw_out.tween_property(hint_banner, "modulate:a", 0.0, 0.4)
			tw_out.tween_callback(func(): hint_banner.visible = false)
	)

func show_win_screen(time_sec: float, kills_count: int, total_souls: int, bonus_souls: int, p_title: String, p_subtitle: String) -> void:
	_stop_joystick()
	win_title.text = "✦ %s ✦" % p_title.to_upper()
	win_subtitle.text = p_subtitle
	
	var mins = int(time_sec) / 60
	var secs = int(time_sec) % 60
	win_stats_label.text = "SURVIVED TIME: %02d:%02d\nZOMBIES SLAIN: %d\nSOULS HARVESTED: ✦ %d (+%d DAWN BONUS!)" % [
		mins, secs, kills_count, total_souls, bonus_souls
	]
	
	win_modal.visible = true
	get_tree().paused = true

func _on_win_continue_pressed() -> void:
	win_modal.visible = false
	get_tree().paused = false
	win_continue_pressed.emit()

func _on_win_menu_pressed() -> void:
	win_modal.visible = false
	get_tree().paused = false
	win_menu_pressed.emit()

func _create_hero_card(hero: HeroData) -> Control:
	var card_panel = TextureRect.new()
	card_panel.texture = card_bg_texture
	card_panel.custom_minimum_size = Vector2(580, 120)
	card_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_panel.stretch_mode = TextureRect.STRETCH_SCALE
	card_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 10)
	card_panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)
	
	var icon_rect = TextureRect.new()
	icon_rect.texture = hero.sprite
	icon_rect.custom_minimum_size = Vector2(56, 56)
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hbox.add_child(icon_rect)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(vbox)
	
	var name_lbl = Label.new()
	name_lbl.text = "%s - %s" % [hero.name, hero.title]
	name_lbl.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
	name_lbl.add_theme_font_size_override("font_size", 17)
	vbox.add_child(name_lbl)
	
	var stats_lbl = Label.new()
	var starting_wep_name = hero.starting_weapon.name if hero.starting_weapon != null else "Pistol"
	stats_lbl.text = "HP: %d | Speed: %d | Gun: %s" % [int(hero.hp), int(hero.speed), starting_wep_name]
	stats_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	stats_lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(stats_lbl)
	
	var passive_lbl = Label.new()
	passive_lbl.text = "Passive: " + hero.passive_description
	passive_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 0.8))
	passive_lbl.add_theme_font_size_override("font_size", 13)
	passive_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(passive_lbl)
	
	var is_unlocked = SaveManager.is_hero_unlocked(hero)
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(110, 44)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 15)
	
	if not is_unlocked:
		card_panel.modulate = Color(0.75, 0.75, 0.8, 0.9)
		icon_rect.modulate = Color(0.4, 0.4, 0.45)
		
		var lock_lbl = Label.new()
		var progress_str = ""
		if hero.unlock_type == "runs":
			progress_str = " (%d/%d Runs)" % [SaveManager.get_runs_completed(), hero.unlock_requirement]
		elif hero.unlock_type == "boss_kills":
			progress_str = " (%d/%d Boss Kills)" % [SaveManager.get_boss_kills(), hero.unlock_requirement]
		lock_lbl.text = "🔒 LOCKED: %s%s" % [hero.unlock_description, progress_str]
		lock_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.35))
		lock_lbl.add_theme_font_size_override("font_size", 12)
		vbox.add_child(lock_lbl)
		
		btn.text = "LOCKED"
		btn.disabled = true
		btn.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
	else:
		btn.text = "SELECT"
		btn.disabled = false
		btn.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
		btn.pressed.connect(func(): _on_hero_card_selected(hero))
	
	hbox.add_child(btn)
	
	return card_panel

func _on_hero_card_selected(hero: HeroData) -> void:
	hero_select_modal.visible = false
	get_tree().paused = false
	hero_selected.emit(hero)

# -------------------------------------------------------------
# VIRTUAL TOUCH JOYSTICK FOR MOBILE / PORTRAIT
# -------------------------------------------------------------
func _on_joystick_gui_input(event: InputEvent) -> void:
	if hero_select_modal.visible or deck_modal.visible or upgrade_modal.visible or game_over_modal.visible or win_modal.visible or pause_modal.visible or settings_modal.visible:
		return
	
	var p = _get_player()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_joystick(event.position)
			else:
				_stop_joystick()
	elif event is InputEventMouseMotion and is_dragging:
		_update_joystick(event.position)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_start_joystick(event.position)
		else:
			_stop_joystick()
	elif event is InputEventScreenDrag and is_dragging:
		_update_joystick(event.position)

func _start_joystick(local_pos: Vector2) -> void:
	is_dragging = true
	touch_origin = local_pos
	joystick_base.position = local_pos - Vector2(64, 64)
	joystick_knob.position = Vector2(32, 32)
	joystick_base.visible = true

func _update_joystick(local_pos: Vector2) -> void:
	var offset = local_pos - touch_origin
	var dist = minf(offset.length(), max_radius)
	var dir = offset.normalized() if offset.length() > 0.0 else Vector2.ZERO
	
	joystick_knob.position = Vector2(32, 32) + (dir * dist)
	
	var vec = dir * (dist / max_radius)
	var p = _get_player()
	if p != null and "joystick_vector" in p:
		p.joystick_vector = vec

func _stop_joystick() -> void:
	is_dragging = false
	joystick_base.visible = false
	joystick_knob.position = Vector2(32, 32)
	var p = _get_player()
	if p != null and "joystick_vector" in p:
		p.joystick_vector = Vector2.ZERO

# -------------------------------------------------------------
# UPGRADE CARDS (PORTRAIT BANNER CARDS)
# -------------------------------------------------------------
func show_upgrade_choices(upgrades: Array[UpgradeData], weapon_notice: String) -> void:
	_stop_joystick()
	weapon_upgrade_notice.text = weapon_notice
	
	for child in cards_container.get_children():
		child.queue_free()
	
	for upgrade in upgrades:
		var card = _create_banner_card(upgrade)
		cards_container.add_child(card)
	
	upgrade_modal.visible = true
	get_tree().paused = true

func _create_banner_card(upgrade: UpgradeData) -> Control:
	var card_panel = TextureRect.new()
	card_panel.texture = card_bg_texture
	card_panel.custom_minimum_size = Vector2(580, 110)
	card_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_panel.stretch_mode = TextureRect.STRETCH_SCALE
	card_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	card_panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)
	
	var icon_rect = TextureRect.new()
	icon_rect.texture = upgrade.sprite
	icon_rect.custom_minimum_size = Vector2(56, 56)
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hbox.add_child(icon_rect)
	
	var text_vbox = VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(text_vbox)
	
	var title_lbl = Label.new()
	title_lbl.text = upgrade.name
	title_lbl.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
	title_lbl.add_theme_font_size_override("font_size", 18)
	text_vbox.add_child(title_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = upgrade.description
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	desc_lbl.add_theme_font_size_override("font_size", 14)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_vbox.add_child(desc_lbl)
	
	var btn = Button.new()
	btn.text = "SELECT"
	btn.custom_minimum_size = Vector2(110, 44)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 16)
	btn.pressed.connect(func(): _on_card_selected(upgrade))
	hbox.add_child(btn)
	
	return card_panel

func _on_card_selected(upgrade: UpgradeData) -> void:
	upgrade_modal.visible = false
	get_tree().paused = false
	upgrade_selected.emit(upgrade)

func show_game_over(survived_seconds: float, kills: int, final_weapon: String, souls_collected: int = 0, death_cause: String = "Zombie") -> void:
	_stop_joystick()
	var total_secs = int(survived_seconds)
	var mins = total_secs / 60
	var secs = total_secs % 60
	var time_str = "%02d:%02d" % [mins, secs]
	
	# Process and save records and souls safely
	var res = SaveManager.save_game_result(survived_seconds, kills, souls_collected)
	var b_secs = int(res.get("best_time", survived_seconds))
	var b_mins = b_secs / 60
	var b_rem_secs = b_secs % 60
	var best_time_str = "%02d:%02d" % [b_mins, b_rem_secs]
	var best_kills_val = res.get("best_kills", kills)
	var total_souls_val = res.get("total_souls", souls_collected)
	
	# Toggle "NEW BEST" labels
	new_best_time_lbl.visible = res.get("is_new_best_time", false)
	new_best_kills_lbl.visible = res.get("is_new_best_kills", false)
	
	game_over_stats.text = "TIME SURVIVED: %s (BEST: %s)\nZOMBIES SLAIN: %d (BEST: %d)\nSOULS EARNED: +%d (TOTAL: %d ✦)\nKILLED BY: %s\nFINAL ARSENAL: %s" % [
		time_str, best_time_str, kills, best_kills_val, souls_collected, total_souls_val, death_cause.to_upper(), final_weapon.to_upper()
	]
	game_over_modal.visible = true

func _on_retry_pressed() -> void:
	get_tree().paused = false
	retry_pressed.emit()
