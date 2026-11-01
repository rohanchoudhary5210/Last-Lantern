extends Control

@export var game_feel: GameFeelData

@onready var play_btn: Button = $CenterContainer/MainVBox/ButtonBox/PlayButton
@onready var shop_btn: Button = $CenterContainer/MainVBox/ButtonBox/ShopButton
@onready var card_shop_btn: Button = $CenterContainer/MainVBox/ButtonBox/CardShopButton
@onready var settings_btn: Button = $CenterContainer/MainVBox/ButtonBox/SettingsButton
@onready var stats_btn: Button = $CenterContainer/MainVBox/ButtonBox/StatsButton
@onready var quit_btn: Button = $CenterContainer/MainVBox/ButtonBox/QuitButton

@onready var stats_modal: Control = $StatsModal
@onready var stats_best_time_val: Label = $StatsModal/CenterContainer/StatsVBox/CardPanel/Margin/Grid/BestTimeRow/Value
@onready var stats_total_runs_val: Label = $StatsModal/CenterContainer/StatsVBox/CardPanel/Margin/Grid/TotalRunsRow/Value
@onready var stats_avg_length_val: Label = $StatsModal/CenterContainer/StatsVBox/CardPanel/Margin/Grid/AvgLengthRow/Value
@onready var stats_fav_upgrade_val: Label = $StatsModal/CenterContainer/StatsVBox/CardPanel/Margin/Grid/FavoriteUpgRow/Value
@onready var stats_back_btn: Button = $StatsModal/CenterContainer/StatsVBox/StatsBackBtn

@onready var best_time_val: Label = $CenterContainer/MainVBox/RecordsCard/Margin/RecordsHBox/BestTimeBox/BestTimeVal
@onready var best_kills_val: Label = $CenterContainer/MainVBox/RecordsCard/Margin/RecordsHBox/BestKillsBox/BestKillsVal
@onready var total_souls_val: Label = $CenterContainer/MainVBox/RecordsCard/Margin/RecordsHBox/TotalSoulsBox/TotalSoulsVal

@onready var curse_tag_label: Label = $CenterContainer/MainVBox/DailyCurseCard/Margin/VBox/CurseTagLabel
@onready var curse_desc_label: Label = $CenterContainer/MainVBox/DailyCurseCard/Margin/VBox/CurseDescLabel

@onready var settings_modal: Control = $SettingsModal
@onready var music_label: Label = $SettingsModal/CenterContainer/VBox/MusicBox/MusicLabel
@onready var music_slider: HSlider = $SettingsModal/CenterContainer/VBox/MusicBox/MusicSlider
@onready var sfx_label: Label = $SettingsModal/CenterContainer/VBox/SFXBox/SFXLabel
@onready var sfx_slider: HSlider = $SettingsModal/CenterContainer/VBox/SFXBox/SFXSlider
@onready var settings_back_btn: Button = $SettingsModal/CenterContainer/VBox/SettingsBackBtn

@onready var shop_modal: Control = $ShopModal
@onready var balance_label: Label = $ShopModal/CenterContainer/ShopVBox/BalanceLabel
@onready var upgrades_container: VBoxContainer = $ShopModal/CenterContainer/ShopVBox/ScrollContainer/UpgradesContainer
@onready var shop_back_btn: Button = $ShopModal/CenterContainer/ShopVBox/ShopBackBtn

@onready var card_shop_modal: Control = $CardShopModal
@onready var card_balance_label: Label = $CardShopModal/CenterContainer/CardShopVBox/BalanceLabel
@onready var buy_pack_btn: Button = $CardShopModal/CenterContainer/CardShopVBox/PackBox/BuyPackBtn
@onready var cards_container: VBoxContainer = $CardShopModal/CenterContainer/CardShopVBox/ScrollContainer/CardsContainer
@onready var card_shop_back_btn: Button = $CardShopModal/CenterContainer/CardShopVBox/CardShopBackBtn

@onready var reveal_modal: Control = $CardShopModal/RevealModal
@onready var reveal_cards_hbox: HBoxContainer = $CardShopModal/RevealModal/CenterContainer/RevealVBox/RevealCardsHBox
@onready var reveal_done_btn: Button = $CardShopModal/RevealModal/CenterContainer/RevealVBox/RevealDoneBtn

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer

var meta_upgrades: Array = []
var banner_tex: Texture2D = preload("res://assets/ui/card_banner_bg.png")

var card_pack_data: CardPackData
var card_level_data: CardLevelData
var rarity_data: RarityData
var all_cards: Array[CardData] = []
var curses: Array[CurseData] = []
var daily_curse: CurseData = null
var _audio_started: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_start_audio_if_needed()
	elif event is InputEventScreenTouch and event.is_pressed():
		_start_audio_if_needed()
	elif event is InputEventKey and event.is_pressed():
		_start_audio_if_needed()

func _start_audio_if_needed() -> void:
	if _audio_started:
		return
	_audio_started = true
	if music_player != null and not music_player.playing:
		music_player.play()

func _ready() -> void:
	if game_feel == null:
		game_feel = load("res://data/game_feel.tres")
	
	_load_meta_resources()
	_load_card_resources()
	_load_curse_resources()
	_load_records_ui()
	_load_settings_ui()
	
	play_btn.pressed.connect(_on_play_pressed)
	shop_btn.pressed.connect(_on_shop_pressed)
	card_shop_btn.pressed.connect(_on_card_shop_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	stats_btn.pressed.connect(_on_stats_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	settings_back_btn.pressed.connect(_on_settings_back_pressed)
	stats_back_btn.pressed.connect(_on_stats_back_pressed)
	shop_back_btn.pressed.connect(_on_shop_back_pressed)
	card_shop_back_btn.pressed.connect(_on_card_shop_back_pressed)
	
	buy_pack_btn.pressed.connect(_on_buy_pack_pressed)
	reveal_done_btn.pressed.connect(_on_reveal_done_pressed)
	
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	if music_player != null:
		music_player.finished.connect(func(): music_player.play())
	
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)

func _apply_safe_area() -> void:
	SafeArea.apply_centers(self, SafeArea.insets(get_viewport()))

func _load_meta_resources() -> void:
	meta_upgrades = [
		load("res://data/meta/meta_max_hp.tres"),
		load("res://data/meta/meta_move_speed.tres"),
		load("res://data/meta/meta_torch_radius.tres"),
		load("res://data/meta/meta_damage.tres"),
		load("res://data/meta/meta_soul_magnet.tres")
	]

func _load_card_resources() -> void:
	card_pack_data = load("res://data/card_packs.tres")
	card_level_data = load("res://data/card_levels.tres")
	rarity_data = load("res://data/rarities.tres")
	
	all_cards = [
		load("res://data/cards/card_damage.tres"),
		load("res://data/cards/card_fire_rate.tres"),
		load("res://data/cards/card_max_hp.tres"),
		load("res://data/cards/card_move_speed.tres"),
		load("res://data/cards/card_torch_radius.tres"),
		load("res://data/cards/card_soul_gain.tres"),
		load("res://data/cards/card_magnet_radius.tres"),
		load("res://data/cards/card_crate_drop_chance.tres"),
		load("res://data/cards/card_first_hit_shield.tres"),
		load("res://data/cards/card_boss_damage.tres"),
		load("res://data/cards/card_revive_once.tres"),
		load("res://data/cards/card_lifesteal.tres")
	]

func _load_curse_resources() -> void:
	curses = [
		load("res://data/curses/curse_eclipse.tres"),
		load("res://data/curses/curse_bloodmoon.tres"),
		load("res://data/curses/curse_ironclad.tres"),
		load("res://data/curses/curse_withering.tres"),
		load("res://data/curses/curse_frenzy.tres")
	]
	daily_curse = CurseData.get_daily_curse(curses)
	if daily_curse != null:
		curse_tag_label.text = "⚡ TODAY'S CURSE: " + daily_curse.name.to_upper()
		curse_desc_label.text = daily_curse.description

func _load_records_ui() -> void:
	var records = SaveManager.load_records()
	var secs = int(records.get("best_time", 0.0))
	var mins = secs / 60
	var rem_secs = secs % 60
	best_time_val.text = "%02d:%02d" % [mins, rem_secs]
	best_kills_val.text = str(records.get("best_kills", 0))
	
	var souls = SaveManager.get_total_souls()
	total_souls_val.text = "✦ %d" % souls

func _load_settings_ui() -> void:
	var settings = SaveManager.load_settings(game_feel)
	var m_val = settings.get("music_linear", 0.5)
	var s_val = settings.get("sfx_linear", 1.0)
	
	music_slider.value = m_val
	sfx_slider.value = s_val
	_update_labels(m_val, s_val)

func _update_labels(m_val: float, s_val: float) -> void:
	music_label.text = "MUSIC VOLUME: %d%%" % int(round(m_val * 100.0))
	sfx_label.text = "SFX VOLUME: %d%%" % int(round(s_val * 100.0))

func _on_music_slider_changed(val: float) -> void:
	_update_labels(val, sfx_slider.value)
	SaveManager.save_settings(val, sfx_slider.value)

func _on_sfx_slider_changed(val: float) -> void:
	_update_labels(music_slider.value, val)
	SaveManager.save_settings(music_slider.value, val)

func _on_play_pressed() -> void:
	_start_audio_if_needed()
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_settings_pressed() -> void:
	_start_audio_if_needed()
	settings_modal.visible = true

func _on_settings_back_pressed() -> void:
	settings_modal.visible = false

func _on_stats_pressed() -> void:
	_start_audio_if_needed()
	_refresh_stats_ui()
	stats_modal.visible = true

func _on_stats_back_pressed() -> void:
	stats_modal.visible = false

func _refresh_stats_ui() -> void:
	var summary = SaveManager.get_stats_summary()
	var b_secs = int(summary.get("best_time", 0.0))
	stats_best_time_val.text = "%02d:%02d" % [b_secs / 60, b_secs % 60]
	stats_total_runs_val.text = str(summary.get("total_runs", 0))
	
	var a_secs = int(summary.get("avg_duration", 0.0))
	stats_avg_length_val.text = "%02d:%02d" % [a_secs / 60, a_secs % 60]
	stats_fav_upgrade_val.text = str(summary.get("most_picked_upgrade", "None"))

func _on_quit_pressed() -> void:
	_start_audio_if_needed()
	get_tree().quit()

# -------------------------------------------------------------
# META SHOP LOGIC
# -------------------------------------------------------------
func _on_shop_pressed() -> void:
	_start_audio_if_needed()
	shop_modal.visible = true
	_refresh_shop()

func _on_shop_back_pressed() -> void:
	shop_modal.visible = false
	_load_records_ui()

func _refresh_shop() -> void:
	var souls = SaveManager.get_total_souls()
	balance_label.text = "AVAILABLE SOULS: ✦ %d" % souls
	
	for child in upgrades_container.get_children():
		child.queue_free()
	
	for meta in meta_upgrades:
		if meta == null:
			continue
		var card = _create_shop_card(meta, souls)
		upgrades_container.add_child(card)

func _create_shop_card(meta: MetaUpgradeData, current_souls: int) -> Control:
	var card = TextureRect.new()
	card.texture = banner_tex
	card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card.custom_minimum_size = Vector2(580, 84)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	margin.add_child(hbox)
	
	var icon_rect = TextureRect.new()
	icon_rect.texture = meta.icon
	icon_rect.custom_minimum_size = Vector2(46, 46)
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hbox.add_child(icon_rect)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(vbox)
	
	var lvl: int = SaveManager.get_meta_upgrade_level(meta.id)
	
	var title_lbl = Label.new()
	title_lbl.text = "%s [RANK %d/%d]" % [meta.name.to_upper(), lvl, meta.max_level]
	title_lbl.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
	title_lbl.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = meta.description
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.9))
	desc_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc_lbl)
	
	var pips_lbl = Label.new()
	var pips_str = ""
	for i in range(meta.max_level):
		pips_str += "■ " if i < lvl else "□ "
	pips_lbl.text = pips_str
	pips_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	pips_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(pips_lbl)
	
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(130, 48)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 14)
	
	if lvl >= meta.max_level:
		btn.text = "MAX RANK"
		btn.disabled = true
		btn.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	else:
		var price = meta.get_price(lvl)
		btn.text = "UPGRADE\n✦ %d" % price
		if current_souls >= price:
			btn.disabled = false
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
			btn.pressed.connect(func(): _buy_meta_upgrade(meta, price))
		else:
			btn.disabled = true
			btn.add_theme_color_override("font_color", Color(0.65, 0.45, 0.45))
	
	hbox.add_child(btn)
	return card

func _buy_meta_upgrade(meta: MetaUpgradeData, price: int) -> void:
	if SaveManager.spend_souls(price):
		var current_lvl = SaveManager.get_meta_upgrade_level(meta.id)
		SaveManager.set_meta_upgrade_level(meta.id, current_lvl + 1)
		_refresh_shop()
		_load_records_ui()

# -------------------------------------------------------------
# CARD SHOP & VAULT LOGIC (PHASE 8)
# -------------------------------------------------------------
func _on_card_shop_pressed() -> void:
	_start_audio_if_needed()
	card_shop_modal.visible = true
	_refresh_card_shop()

func _on_card_shop_back_pressed() -> void:
	card_shop_modal.visible = false
	_load_records_ui()

func _refresh_card_shop() -> void:
	var souls = SaveManager.get_total_souls()
	card_balance_label.text = "AVAILABLE SOULS: ✦ %d" % souls
	
	var pack_price = card_pack_data.pack_price if card_pack_data != null else 150
	buy_pack_btn.text = "OPEN CARD PACK (✦ %d)" % pack_price
	buy_pack_btn.disabled = (souls < pack_price)
	
	for child in cards_container.get_children():
		child.queue_free()
	
	var collection = SaveManager.get_card_collection()
	for card in all_cards:
		if card == null:
			continue
		var card_widget = _create_card_collection_row(card, collection)
		cards_container.add_child(card_widget)

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

func _create_card_collection_row(card: CardData, collection: Dictionary) -> Control:
	var is_owned = collection.has(card.id)
	var lvl = 1
	var dupes = 0
	if is_owned:
		var entry = collection[card.id]
		if typeof(entry) == TYPE_DICTIONARY:
			lvl = maxi(1, int(entry.get("level", 1)))
			dupes = maxi(0, int(entry.get("duplicates", 0)))
		elif typeof(entry) == TYPE_INT:
			lvl = maxi(1, entry)
	
	var card_row = TextureRect.new()
	card_row.texture = banner_tex
	card_row.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_row.custom_minimum_size = Vector2(600, 84)
	card_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 8)
	card_row.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	margin.add_child(hbox)
	
	# Icon with rarity outline
	var icon_panel = PanelContainer.new()
	icon_panel.custom_minimum_size = Vector2(52, 52)
	icon_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.9)
	style.border_color = _get_rarity_color(card.rarity) if is_owned else Color(0.3, 0.3, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	icon_panel.add_theme_stylebox_override("panel", style)
	
	var icon_rect = TextureRect.new()
	icon_rect.texture = card.icon
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.modulate = Color.WHITE if is_owned else Color(0.35, 0.35, 0.4)
	icon_panel.add_child(icon_rect)
	hbox.add_child(icon_panel)
	
	# Middle info
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(vbox)
	
	var r_col = _get_rarity_color(card.rarity)
	var title_lbl = Label.new()
	if is_owned:
		title_lbl.text = "%s [LV. %d/%d]" % [card.name.to_upper(), lvl, card.max_level]
		title_lbl.add_theme_color_override("font_color", r_col)
	else:
		title_lbl.text = "%s [LOCKED]" % card.name.to_upper()
		title_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
	title_lbl.add_theme_font_size_override("font_size", 15)
	vbox.add_child(title_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = card.description
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95) if is_owned else Color(0.5, 0.5, 0.55))
	desc_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc_lbl)
	
	var req_cost = card_level_data.get_duplicate_cost(lvl) if card_level_data != null else 1
	var meter_lbl = Label.new()
	if not is_owned:
		meter_lbl.text = "Rarity: %s — Find in Card Packs or Boss Drops" % card.rarity
		meter_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	elif lvl >= card.max_level:
		meter_lbl.text = "MAX LEVEL REACHED"
		meter_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		meter_lbl.text = "Duplicates: %d / %d required" % [dupes, req_cost]
		meter_lbl.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0) if dupes >= req_cost else Color(0.7, 0.7, 0.75))
	meter_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(meter_lbl)
	
	# Action button
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(130, 46)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 14)
	
	if not is_owned:
		btn.text = "LOCKED"
		btn.disabled = true
		btn.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	elif lvl >= card.max_level:
		btn.text = "MAXED"
		btn.disabled = true
		btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		if dupes >= req_cost:
			btn.text = "UPGRADE\n(%d Dupes)" % req_cost
			btn.disabled = false
			btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
			btn.pressed.connect(func(): _upgrade_card(card.id, req_cost, card.max_level))
		else:
			btn.text = "%d / %d" % [dupes, req_cost]
			btn.disabled = true
			btn.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	
	hbox.add_child(btn)
	return card_row

func _upgrade_card(card_id: String, cost: int, max_level: int) -> void:
	if SaveManager.upgrade_card(card_id, cost, max_level):
		if sfx_player != null and card_pack_data != null and card_pack_data.reveal_sound != null:
			sfx_player.stream = card_pack_data.reveal_sound
			sfx_player.play()
		_refresh_card_shop()

func _on_buy_pack_pressed() -> void:
	var pack_price = card_pack_data.pack_price if card_pack_data != null else 150
	if not SaveManager.spend_souls(pack_price):
		return
	
	if sfx_player != null and card_pack_data != null and card_pack_data.pack_sound != null:
		sfx_player.stream = card_pack_data.pack_sound
		sfx_player.play()
	
	var pulled_results: Array[Dictionary] = []
	var count = card_pack_data.cards_per_pack if card_pack_data != null else 3
	for i in range(count):
		var rolled_rarity = card_pack_data.roll_rarity() if card_pack_data != null else "Common"
		var candidates: Array[CardData] = []
		for c in all_cards:
			if c.rarity == rolled_rarity:
				candidates.append(c)
		if candidates.is_empty():
			candidates = all_cards
		var pulled_card: CardData = candidates[randi() % candidates.size()]
		var res = SaveManager.add_card_to_collection(pulled_card.id)
		res["card"] = pulled_card
		pulled_results.append(res)
	
	_show_reveal_modal(pulled_results)

func _show_reveal_modal(pulled_cards: Array[Dictionary]) -> void:
	for child in reveal_cards_hbox.get_children():
		child.queue_free()
	
	reveal_modal.visible = true
	
	if sfx_player != null and card_pack_data != null and card_pack_data.reveal_sound != null:
		sfx_player.stream = card_pack_data.reveal_sound
		sfx_player.play()
	
	for res in pulled_cards:
		var card: CardData = res["card"]
		var is_new: bool = res.get("is_new", false)
		var lvl: int = res.get("level", 1)
		var dupes: int = res.get("duplicates", 0)
		
		var card_panel = PanelContainer.new()
		card_panel.custom_minimum_size = Vector2(180, 260)
		var pstyle = StyleBoxFlat.new()
		pstyle.bg_color = Color(0.06, 0.08, 0.12, 0.98)
		pstyle.border_color = _get_rarity_color(card.rarity)
		pstyle.set_border_width_all(3)
		pstyle.set_corner_radius_all(10)
		card_panel.add_theme_stylebox_override("panel", pstyle)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.theme_override_constants.separation = 8
		card_panel.add_child(vbox)
		
		var tag_lbl = Label.new()
		tag_lbl.text = "★ NEW CARD! ★" if is_new else "+1 DUPLICATE"
		tag_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4) if is_new else Color(0.2, 0.85, 1.0))
		tag_lbl.add_theme_font_size_override("font_size", 14)
		vbox.add_child(tag_lbl)
		
		var r_lbl = Label.new()
		r_lbl.text = "[ %s ]" % card.rarity.to_upper()
		r_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		r_lbl.add_theme_color_override("font_color", _get_rarity_color(card.rarity))
		r_lbl.add_theme_font_size_override("font_size", 14)
		vbox.add_child(r_lbl)
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = card.icon
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vbox.add_child(icon_rect)
		
		var name_lbl = Label.new()
		name_lbl.text = card.name
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = card.description
		desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		desc_lbl.add_theme_font_size_override("font_size", 14)
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(desc_lbl)
		
		var status_lbl = Label.new()
		status_lbl.text = "Lv. %d (Dupes: %d)" % [lvl, dupes]
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		status_lbl.add_theme_font_size_override("font_size", 14)
		vbox.add_child(status_lbl)
		
		reveal_cards_hbox.add_child(card_panel)
		
		# Simple reveal scale animation
		card_panel.scale = Vector2(0.5, 0.5)
		var tw = create_tween()
		tw.tween_property(card_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_reveal_done_pressed() -> void:
	reveal_modal.visible = false
	_refresh_card_shop()
	_load_records_ui()
