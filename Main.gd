extends Node2D

@export var zombie_scene: PackedScene = preload("res://Zombie.tscn")
@export var bullet_scene: PackedScene = preload("res://Bullet.tscn")
@export var crate_scene: PackedScene = preload("res://Crate.tscn")
@export var soul_scene: PackedScene = preload("res://Soul.tscn")
@export var game_feel: GameFeelData
@export var debug_config: DebugConfigData

var weapons: Array[WeaponData] = []
var enemies: Array[EnemyData] = []
var upgrades: Array[UpgradeData] = []
var heroes: Array[HeroData] = []
var meta_upgrades: Array = []
var evolutions: Array = []
var acquired_upgrade_ids: Dictionary = {}

var wave_data: WaveData = null
var rarity_data: RarityData = null
var elite_data: EliteData = null

var cards_catalog: Dictionary = {}
var card_pack_data: CardPackData = null

var run_data: RunData = null
var curses: Array[CurseData] = []
var daily_curse: CurseData = null
var has_reached_dawn: bool = false
var has_recorded_run_completion: bool = false
var has_logged_run: bool = false
var chosen_upgrade_names: Array[String] = []
var current_hero: HeroData = null

var current_weapon_idx: int = 0
var game_time: float = 0.0
var kills: int = 0
var run_souls: int = 0
var is_game_over: bool = false
var next_boss_time: float = 120.0
var active_boss: Node2D = null

@onready var player: CharacterBody2D = $Entities/Player
@onready var crates_node: Node2D = $Entities/Crates
@onready var bullets_node: Node2D = $Entities/Bullets
@onready var zombies_node: Node2D = $Entities/Zombies
@onready var souls_node: Node2D = $Entities/Souls
@onready var zombie_spawn_timer: Timer = $ZombieSpawnTimer
@onready var airdrop_timer: Timer = $AirdropTimer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	if not OS.is_debug_build():
		if has_node("DebugPanel"):
			get_node("DebugPanel").queue_free()
	
	if game_feel == null:
		game_feel = load("res://data/game_feel.tres")
	
	SaveManager.load_settings(game_feel)
	
	if music_player != null:
		music_player.finished.connect(func(): music_player.play())
	
	_load_resources()
	_apply_meta_upgrades()
	_connect_signals()
	
	ui.update_hp(player.current_hp, player.max_hp)
	ui.update_kills(kills)
	ui.update_souls(run_souls)
	ui.update_time(0.0)
	ui.update_airdrop_timer(airdrop_timer.time_left)
	_update_weapon_hud()
	
	# First session flow:
	# "Play" on the main menu starts a run immediately with the default hero.
	# Hero select is shown only after the player has finished at least one run.
	var runs_done = SaveManager.get_runs_completed()
	if runs_done == 0:
		_start_default_hero()
		_start_first_run_hints()
	else:
		if not heroes.is_empty():
			ui.show_hero_select(heroes)
		else:
			_start_default_hero()

func _load_resources() -> void:
	# Weapons pool: Pistol, SMG, Shotgun, Rifle, Flamethrower, Crossbow, Grenade Launcher
	weapons = [
		load("res://data/weapons/pistol.tres"),
		load("res://data/weapons/smg.tres"),
		load("res://data/weapons/shotgun.tres"),
		load("res://data/weapons/rifle.tres"),
		load("res://data/weapons/flamethrower.tres"),
		load("res://data/weapons/crossbow.tres"),
		load("res://data/weapons/grenade_launcher.tres")
	]
	
	# Enemies pool
	enemies = [
		load("res://data/enemies/zombie_walker.tres"),
		load("res://data/enemies/zombie_spitter.tres"),
		load("res://data/enemies/zombie_fast.tres"),
		load("res://data/enemies/zombie_exploder.tres"),
		load("res://data/enemies/zombie_charger.tres"),
		load("res://data/enemies/zombie_summoner.tres"),
		load("res://data/enemies/zombie_ghost.tres"),
		load("res://data/enemies/zombie_tank.tres"),
		load("res://data/enemies/zombie_boss.tres")
	]
	
	elite_data = load("res://data/elite.tres")
	
	# Upgrades & Passives pool
	upgrades = [
		load("res://data/upgrades/upgrade_fire_rate.tres"),
		load("res://data/upgrades/upgrade_damage.tres"),
		load("res://data/upgrades/upgrade_move_speed.tres"),
		load("res://data/upgrades/upgrade_torch_radius.tres"),
		load("res://data/upgrades/upgrade_max_hp.tres"),
		load("res://data/upgrades/upgrade_magnet.tres"),
		load("res://data/upgrades/upgrade_lifesteal.tres"),
		load("res://data/upgrades/upgrade_armor.tres"),
		load("res://data/upgrades/upgrade_revive.tres")
	]
	
	# Heroes
	heroes = [
		load("res://data/heroes/hero_luka.tres"),
		load("res://data/heroes/hero_jax.tres"),
		load("res://data/heroes/hero_kora.tres")
	]
	
	# Meta Upgrades pool
	meta_upgrades = [
		load("res://data/meta/meta_max_hp.tres"),
		load("res://data/meta/meta_move_speed.tres"),
		load("res://data/meta/meta_torch_radius.tres"),
		load("res://data/meta/meta_damage.tres"),
		load("res://data/meta/meta_soul_magnet.tres")
	]
	
	# Evolutions pool (Phase 5b & Phase 7)
	evolutions = [
		load("res://data/evolutions/evo_pistol_torch.tres"),
		load("res://data/evolutions/evo_smg_fire_rate.tres"),
		load("res://data/evolutions/evo_shotgun_damage.tres"),
		load("res://data/evolutions/evo_rifle_armor.tres"),
		load("res://data/evolutions/evo_flamethrower_lifesteal.tres")
	]
	
	# Waves & Rarities
	wave_data = load("res://data/waves.tres")
	rarity_data = load("res://data/rarities.tres")
	
	# Cards Catalog & Packs (Phase 8)
	cards_catalog = {
		"damage": load("res://data/cards/card_damage.tres"),
		"fire_rate": load("res://data/cards/card_fire_rate.tres"),
		"max_hp": load("res://data/cards/card_max_hp.tres"),
		"move_speed": load("res://data/cards/card_move_speed.tres"),
		"torch_radius": load("res://data/cards/card_torch_radius.tres"),
		"soul_gain": load("res://data/cards/card_soul_gain.tres"),
		"magnet_radius": load("res://data/cards/card_magnet_radius.tres"),
		"crate_drop_chance": load("res://data/cards/card_crate_drop_chance.tres"),
		"first_hit_shield": load("res://data/cards/card_first_hit_shield.tres"),
		"boss_damage": load("res://data/cards/card_boss_damage.tres"),
		"revive_once": load("res://data/cards/card_revive_once.tres"),
		"lifesteal": load("res://data/cards/card_lifesteal.tres")
	}
	card_pack_data = load("res://data/card_packs.tres")
	
	# Run data & Daily curses (Playable Demo Part A)
	run_data = load("res://data/run.tres")
	curses = [
		load("res://data/curses/curse_eclipse.tres"),
		load("res://data/curses/curse_bloodmoon.tres"),
		load("res://data/curses/curse_ironclad.tres"),
		load("res://data/curses/curse_withering.tres"),
		load("res://data/curses/curse_frenzy.tres")
	]
	daily_curse = CurseData.get_daily_curse(curses)
	
	if debug_config == null:
		debug_config = load("res://data/debug_config.tres")
	
	if wave_data != null:
		next_boss_time = wave_data.boss_start_second

func _apply_meta_upgrades() -> void:
	var meta_lvls = SaveManager.get_all_meta_upgrade_levels()
	player.apply_meta_upgrades(meta_lvls, meta_upgrades)

func _apply_equipped_deck() -> void:
	var equipped_ids = SaveManager.get_equipped_cards()
	var collection = SaveManager.get_card_collection()
	var active_cards: Array = []
	for cid in equipped_ids:
		if cards_catalog.has(cid) and cards_catalog[cid] != null:
			active_cards.append(cards_catalog[cid])
	player.apply_deck(active_cards, collection)
	ui.update_deck(active_cards, collection)

func _connect_signals() -> void:
	player.hp_changed.connect(_on_player_hp_changed)
	player.died.connect(_on_player_died)
	player.shoot_bullet.connect(_on_player_shoot_bullet)
	player.souls_collected.connect(_on_player_souls_collected)
	player.weapon_leveled_up.connect(func(_lvl, _wep): _update_weapon_hud())
	player.weapon_evolved.connect(func(_wep): _update_weapon_hud())
	player.passives_updated.connect(func(lvls, res, rev_left): ui.update_passives(lvls, res, rev_left))
	
	zombie_spawn_timer.timeout.connect(_on_zombie_spawn_timer_timeout)
	airdrop_timer.timeout.connect(_on_airdrop_timer_timeout)
	
	ui.hero_selected.connect(_on_hero_selected)
	ui.upgrade_selected.connect(_on_upgrade_selected)
	ui.retry_pressed.connect(_on_retry_pressed)
	ui.win_continue_pressed.connect(_on_win_continue_pressed)
	ui.win_menu_pressed.connect(_on_win_menu_pressed)

func _update_weapon_hud() -> void:
	if player == null or player.current_weapon == null:
		return
	var evo_status = get_evolution_status_for_current_weapon()
	ui.update_weapon_status(
		player.current_weapon.name,
		player.weapon_rarity_name,
		player.weapon_rarity_color,
		player.current_weapon.bullet_color,
		player.weapon_level,
		player.current_weapon.max_level,
		player.is_weapon_evolved,
		evo_status
	)

func get_available_evolution() -> EvolutionData:
	if player == null or player.current_weapon == null or player.is_weapon_evolved:
		return null
	for evo in evolutions:
		if evo == null or evo.evolved_weapon == null:
			continue
		if player.current_weapon.id == evo.base_weapon_id:
			if player.weapon_level >= evo.required_weapon_level:
				if acquired_upgrade_ids.has(evo.required_upgrade_id):
					return evo
	return null

func get_evolution_status_for_current_weapon() -> Dictionary:
	if player == null or player.current_weapon == null:
		return {"has_evo": false}
	if player.is_weapon_evolved:
		return {"has_evo": true, "is_evolved": true}
	for evo in evolutions:
		if evo != null and evo.base_weapon_id == player.current_weapon.id:
			var lvl_met = player.weapon_level >= evo.required_weapon_level
			var upg_met = acquired_upgrade_ids.has(evo.required_upgrade_id)
			return {
				"has_evo": true,
				"name": evo.name,
				"req_lvl": evo.required_weapon_level,
				"curr_lvl": player.weapon_level,
				"lvl_met": lvl_met,
				"req_upg_id": evo.required_upgrade_id,
				"req_upg_name": _get_upgrade_name(evo.required_upgrade_id),
				"upg_met": upg_met,
				"is_ready": (lvl_met and upg_met)
			}
	return {"has_evo": false}

func _get_upgrade_name(upg_id: String) -> String:
	match upg_id:
		"torch_radius": return "Torch"
		"fire_rate": return "Rapid Fire"
		"damage": return "Damage"
		"move_speed": return "Speed"
		"max_hp": return "Max HP"
		"magnet": return "Magnet"
		"lifesteal": return "Lifesteal"
		"armor": return "Armor"
		"revive": return "Revive"
		_: return upg_id.capitalize()

func _start_default_hero() -> void:
	if not heroes.is_empty():
		current_hero = heroes[0]
		player.apply_hero(heroes[0])
	_apply_meta_upgrades()
	_apply_equipped_deck()
	_apply_daily_curse()
	if weapons.size() > 0:
		var init_rarity = {"name": "Common", "color": Color(0.8, 0.8, 0.8), "multiplier": 1.0}
		if rarity_data != null:
			init_rarity = {"name": rarity_data.common_name, "color": rarity_data.common_color, "multiplier": rarity_data.common_multiplier}
		player.set_weapon(player.current_weapon if player.current_weapon != null else weapons[0], init_rarity)
		_update_weapon_hud()
	ui.update_hp(player.current_hp, player.max_hp)

func _on_hero_selected(hero: HeroData) -> void:
	current_hero = hero
	player.apply_hero(hero)
	_apply_meta_upgrades()
	_apply_equipped_deck()
	_apply_daily_curse()
	
	# Match current weapon index to hero starting weapon
	for i in range(weapons.size()):
		if hero.starting_weapon != null and weapons[i].id == hero.starting_weapon.id:
			current_weapon_idx = i
			break
	
	var init_rarity = {"name": "Common", "color": Color(0.8, 0.8, 0.8), "multiplier": 1.0}
	if rarity_data != null:
		init_rarity = {"name": rarity_data.common_name, "color": rarity_data.common_color, "multiplier": rarity_data.common_multiplier}
	
	player.set_weapon(player.current_weapon, init_rarity)
	_update_weapon_hud()
	ui.update_hp(player.current_hp, player.max_hp)

func _apply_daily_curse() -> void:
	if daily_curse != null:
		player.apply_curse(daily_curse)
		ui.show_curse_banner(daily_curse)
		if daily_curse.airdrop_interval_mult > 0.0:
			airdrop_timer.wait_time = maxf(5.0, 30.0 * daily_curse.airdrop_interval_mult)

func _start_first_run_hints() -> void:
	get_tree().create_timer(0.5).timeout.connect(func():
		if not is_game_over and is_instance_valid(ui):
			ui.show_hint("🕹 MOVE: Use WASD / Arrow Keys or drag on screen", 5.0)
	)
	get_tree().create_timer(6.0).timeout.connect(func():
		if not is_game_over and is_instance_valid(ui):
			ui.show_hint("🎯 AUTO-FIRE: Weapon automatically aims and fires at nearest zombies", 5.0)
	)
	get_tree().create_timer(12.5).timeout.connect(func():
		if not is_game_over and is_instance_valid(ui):
			ui.show_hint("📦 AIRDROPS: Walk close to glowing supply crates to open & upgrade", 6.5)
	)

func _on_player_souls_collected(amount: int) -> void:
	run_souls += amount
	ui.update_souls(run_souls)

func _process(delta: float) -> void:
	if is_game_over:
		return
	
	game_time += delta
	ui.update_time(game_time)
	ui.update_airdrop_timer(airdrop_timer.time_left)
	
	# Win condition check (Dawn at 300s)
	if not has_reached_dawn and run_data != null and game_time >= run_data.dawn_time:
		_trigger_dawn()
	
	# Boss spawn check
	if wave_data != null and active_boss == null and game_time >= next_boss_time:
		_spawn_boss()
		next_boss_time = game_time + wave_data.boss_interval

func _trigger_dawn() -> void:
	has_reached_dawn = true
	if not has_recorded_run_completion:
		has_recorded_run_completion = true
		SaveManager.increment_runs_completed()
	
	var bonus = run_data.dawn_souls_bonus if run_data != null else 50
	run_souls += bonus
	ui.update_souls(run_souls)
	SaveManager.add_souls(bonus)
	
	# Sunrise lighting burst
	if player != null and player.light != null:
		var tw = create_tween()
		tw.tween_property(player.light, "energy", 2.6, 1.2)
	
	var title_text = run_data.dawn_title if run_data != null else "DAWN BREAKS"
	var subtitle_text = run_data.dawn_subtitle if run_data != null else "You survived 5 minutes until sunrise!"
	ui.show_win_screen(game_time, kills, run_souls, bonus, title_text, subtitle_text)

func _on_win_continue_pressed() -> void:
	# Unpause and continue in endless survival mode
	pass

func _on_win_menu_pressed() -> void:
	if not has_logged_run:
		has_logged_run = true
		var final_wep = weapons[current_weapon_idx].name if current_weapon_idx < weapons.size() else "Pistol"
		if player != null and player.current_weapon != null:
			final_wep = "%s (Lv. %d)" % [player.current_weapon.name, player.weapon_level]
		var hero_name = current_hero.name if current_hero != null else "Luka"
		SaveManager.log_run(game_time, "Dawn (Survived)", hero_name, final_wep, chosen_upgrade_names, run_souls)
	SaveManager.save_game_result(game_time, kills, 0, false)
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_player_hp_changed(curr: float, max_v: float) -> void:
	ui.update_hp(curr, max_v)

func _on_player_died() -> void:
	is_game_over = true
	zombie_spawn_timer.stop()
	airdrop_timer.stop()
	if not has_recorded_run_completion:
		has_recorded_run_completion = true
		SaveManager.increment_runs_completed()
	
	var final_wep = weapons[current_weapon_idx].name if current_weapon_idx < weapons.size() else "Pistol"
	if player != null and player.current_weapon != null:
		final_wep = "%s (Lv. %d)" % [player.current_weapon.name, player.weapon_level]
	
	var hero_name = current_hero.name if current_hero != null else "Luka"
	var death_cause = player.last_damage_source if player != null and not player.last_damage_source.is_empty() else "Zombie"
	
	if not has_logged_run:
		has_logged_run = true
		SaveManager.log_run(game_time, death_cause, hero_name, final_wep, chosen_upgrade_names, run_souls)
	
	ui.show_game_over(game_time, kills, final_wep, run_souls, death_cause)

func _on_player_shoot_bullet(weapon: WeaponData, spawn_pos: Vector2, base_dir: Vector2, target_pos: Vector2 = Vector2.ZERO) -> void:
	var pellets = player.get_effective_pellets()
	var spread_deg = weapon.spread_angle
	var base_angle = base_dir.angle()
	
	for i in range(pellets):
		var angle_offset = 0.0
		if pellets > 1:
			var step = deg_to_rad(spread_deg) / float(pellets - 1)
			angle_offset = -deg_to_rad(spread_deg) / 2.0 + (step * i)
		elif spread_deg > 0.0:
			angle_offset = randf_range(-deg_to_rad(spread_deg) / 2.0, deg_to_rad(spread_deg) / 2.0)
		
		var bullet_dir = Vector2.RIGHT.rotated(base_angle + angle_offset)
		var bullet_inst = bullet_scene.instantiate()
		bullets_node.add_child(bullet_inst)
		
		var effective_damage = player.get_effective_damage()
		var effective_pierce = player.get_effective_pierce()
		bullet_inst.setup_from_weapon(weapon, spawn_pos, bullet_dir, effective_damage, effective_pierce, target_pos)

func _on_zombie_shoot_projectile(pos: Vector2, dir: Vector2, speed: float, damage: float, color: Color, shooter_name: String = "Enemy Projectile") -> void:
	var bullet_inst = bullet_scene.instantiate()
	bullet_inst.global_position = pos
	bullets_node.add_child(bullet_inst)
	bullet_inst.setup(dir, speed, damage, 0, color, true, null, 1.6, shooter_name)

func _on_zombie_spawn_timer_timeout() -> void:
	if is_game_over or not is_instance_valid(player):
		return
	
	var max_cap = run_data.max_enemies if run_data != null else 150
	var room = max_cap - get_live_enemy_count()
	if room <= 0:
		return
	
	# Cadence follows time only (it used to jump around with whichever enemy was rolled)
	zombie_spawn_timer.wait_time = maxf(0.6, 1.6 * (1.0 - minf(0.5, game_time * 0.0015)))
	
	# Spawn a pack from one direction so it reads as a horde coming in
	var pack = mini(4 + int(game_time / 40.0), room)
	var pack_angle = randf_range(0.0, TAU)
	for _i in pack:
		_spawn_zombie(_pick_wave_enemy(), _offscreen_spawn_pos(pack_angle + randf_range(-0.35, 0.35)))

func _pick_wave_enemy() -> EnemyData:
	if wave_data == null or wave_data.rules.is_empty():
		return enemies[0]
	var active_rules: Array[WaveRule] = []
	var total_weight: float = 0.0
	for rule in wave_data.rules:
		if game_time >= rule.start_second:
			active_rules.append(rule)
			total_weight += rule.weight
	var roll = randf() * total_weight
	var cumulative: float = 0.0
	for rule in active_rules:
		cumulative += rule.weight
		if roll <= cumulative:
			return rule.enemy_data
	return enemies[0]

# Just outside the visible screen edge in that direction (portrait screen is narrow, so a fixed radius left side-spawns far away)
func _offscreen_spawn_pos(angle: float) -> Vector2:
	var half = get_viewport().get_visible_rect().size * 0.5
	var dir = Vector2.RIGHT.rotated(angle)
	var to_edge = minf(half.x / maxf(absf(dir.x), 0.001), half.y / maxf(absf(dir.y), 0.001))
	return player.global_position + dir * (to_edge + randf_range(60.0, 140.0))

func _spawn_zombie(chosen_data: EnemyData, spawn_pos: Vector2) -> void:
	var speed_mult = (1.0 + (game_time * 0.002)) * (daily_curse.zombie_speed_mult if daily_curse != null else 1.0)
	var hp_mult = (1.0 + (game_time * 0.0025)) * (daily_curse.zombie_hp_mult if daily_curse != null else 1.0)
	var dmg_mult = daily_curse.zombie_damage_mult if daily_curse != null else 1.0
	
	var zombie_inst = zombie_scene.instantiate()
	zombie_inst.global_position = spawn_pos
	zombies_node.add_child(zombie_inst)
	zombie_inst.apply_enemy_data(chosen_data, speed_mult, hp_mult, dmg_mult)
	
	zombie_inst.died.connect(_on_zombie_died)
	zombie_inst.shoot_projectile.connect(_on_zombie_shoot_projectile)
	zombie_inst.drop_crate_requested.connect(_on_drop_crate_requested)
	zombie_inst.drop_souls_requested.connect(_on_drop_souls_requested)
	zombie_inst.summon_requested.connect(_on_zombie_summon_requested)
	
	# Roll Elite Zombie
	if elite_data != null and not chosen_data.is_boss:
		if randf() <= elite_data.elite_chance:
			zombie_inst.apply_elite(elite_data)

func _on_zombie_summon_requested(summoner: Node2D, enemy_to_summon: EnemyData, count: int) -> void:
	if is_game_over or summoner == null or not is_instance_valid(summoner):
		return
	var max_cap = run_data.max_enemies if run_data != null else 150
	if get_live_enemy_count() >= max_cap:
		return
	var data = enemy_to_summon if enemy_to_summon != null else enemies[0]
	for i in range(count):
		var offset = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(35.0, 75.0)
		var minion = zombie_scene.instantiate()
		minion.global_position = summoner.global_position + offset
		zombies_node.add_child(minion)
		minion.apply_enemy_data(data, 1.0, 1.0)
		
		minion.died.connect(_on_zombie_died)
		minion.shoot_projectile.connect(_on_zombie_shoot_projectile)
		minion.drop_crate_requested.connect(_on_drop_crate_requested)
		minion.drop_souls_requested.connect(_on_drop_souls_requested)
		
		if "active_minions" in summoner:
			summoner.active_minions.append(minion)

func _spawn_boss() -> void:
	if is_game_over or not is_instance_valid(player) or wave_data == null or wave_data.boss_data == null:
		return
	
	var spawn_dist = randf_range(850.0, 950.0)
	var spawn_angle = randf_range(0.0, TAU)
	var spawn_pos = player.global_position + Vector2.RIGHT.rotated(spawn_angle) * spawn_dist
	
	var boss_inst = zombie_scene.instantiate()
	boss_inst.global_position = spawn_pos
	zombies_node.add_child(boss_inst)
	boss_inst.apply_enemy_data(wave_data.boss_data, 1.0, 1.0)
	active_boss = boss_inst
	
	boss_inst.boss_hp_changed.connect(func(curr, max_hp): ui.update_boss_hp(curr, max_hp, wave_data.boss_data.name))
	boss_inst.boss_died.connect(_on_boss_died)
	boss_inst.died.connect(_on_zombie_died)
	boss_inst.shoot_projectile.connect(_on_zombie_shoot_projectile)
	boss_inst.drop_crate_requested.connect(_on_drop_crate_requested)
	boss_inst.drop_souls_requested.connect(_on_drop_souls_requested)
	
	ui.update_boss_hp(wave_data.boss_data.hp, wave_data.boss_data.hp, wave_data.boss_data.name)

func _on_boss_died(_boss: Node2D, _death_pos: Vector2) -> void:
	active_boss = null
	ui.hide_boss_hp()
	SaveManager.increment_boss_kills()
	
	# Boss reward: chance to drop 1 free card (Phase 8)
	if card_pack_data != null and not cards_catalog.is_empty():
		if randf() <= card_pack_data.boss_card_drop_chance:
			var rolled_rarity = card_pack_data.roll_rarity()
			var candidates: Array[CardData] = []
			for c in cards_catalog.values():
				if c != null and c.rarity == rolled_rarity:
					candidates.append(c)
			if candidates.is_empty():
				for c in cards_catalog.values():
					if c != null:
						candidates.append(c)
			if not candidates.is_empty():
				var awarded_card: CardData = candidates[randi() % candidates.size()]
				SaveManager.add_card_to_collection(awarded_card.id)
				ui.show_card_reward_banner(awarded_card)

func _on_drop_crate_requested(drop_pos: Vector2) -> void:
	_spawn_crate.call_deferred(drop_pos)

func _spawn_crate(drop_pos: Vector2) -> void:
	var crate_inst = crate_scene.instantiate()
	crate_inst.global_position = drop_pos
	crates_node.add_child(crate_inst)
	crate_inst.crate_opened.connect(_on_crate_opened)

func _on_drop_souls_requested(drop_pos: Vector2, soul_val: int) -> void:
	# Deferred: kills happen inside physics callbacks, where adding Area2D nodes is not allowed.
	_spawn_souls.call_deferred(drop_pos, soul_val)

func _spawn_souls(drop_pos: Vector2, soul_val: int) -> void:
	if soul_scene == null:
		return
	var target_parent = souls_node if souls_node != null else crates_node.get_parent()
	if target_parent == null:
		return
	
	if soul_val <= 3:
		for i in range(soul_val):
			var s = soul_scene.instantiate()
			var impulse = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(40.0, 110.0)
			s.global_position = drop_pos
			target_parent.add_child(s)
			s.setup(1, impulse)
	elif soul_val <= 10:
		var remaining = soul_val
		while remaining > 0:
			var chunk = mini(remaining, 2)
			remaining -= chunk
			var s = soul_scene.instantiate()
			var impulse = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(50.0, 130.0)
			s.global_position = drop_pos
			target_parent.add_child(s)
			s.setup(chunk, impulse)
	else:
		# High-value drop (Boss: 25 souls) -> 5 high-value orbs of 5
		for i in range(5):
			var s = soul_scene.instantiate()
			var impulse = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(80.0, 180.0)
			s.global_position = drop_pos
			target_parent.add_child(s)
			s.setup(5, impulse)

func _on_zombie_died(_zombie: Node2D) -> void:
	kills += 1
	ui.update_kills(kills)
	if player != null and is_instance_valid(player) and player.has_method("on_enemy_killed"):
		player.on_enemy_killed()
	
	# Bonus crate drop chance from equipped card
	if is_instance_valid(player) and player.bonus_crate_chance > 0.0 and is_instance_valid(_zombie):
		if randf() <= player.bonus_crate_chance:
			_on_drop_crate_requested(_zombie.global_position)

func _on_airdrop_timer_timeout() -> void:
	if is_game_over or not is_instance_valid(player):
		return
	
	var drop_dist = randf_range(220.0, 420.0)
	var drop_angle = randf_range(0.0, TAU)
	var drop_pos = player.global_position + Vector2.RIGHT.rotated(drop_angle) * drop_dist
	
	_on_drop_crate_requested(drop_pos)

func _on_crate_opened(_crate: Node2D) -> void:
	var weapon_notice = ""
	var ready_evo = get_available_evolution()
	var chosen_cards: Array[UpgradeData] = []
	
	# 1. Guaranteed Evolution Card if conditions met
	if ready_evo != null:
		var evo_card = UpgradeData.new()
		evo_card.id = ready_evo.id
		evo_card.name = "✦ EVOLVE: %s ✦" % ready_evo.name.to_upper()
		evo_card.description = ready_evo.description
		evo_card.stat_type = "evolution"
		evo_card.sprite = ready_evo.icon
		chosen_cards.append(evo_card)
		weapon_notice = "✦ EVOLUTION UNLOCKED! CLAIM %s ✦" % ready_evo.name.to_upper()
	elif not player.is_weapon_evolved and player.weapon_level < player.current_weapon.max_level:
		# 2. Weapon Level-Up Card if not max level
		var wep_card = UpgradeData.new()
		wep_card.id = "weapon_level"
		wep_card.name = "TUNE: %s [LV %d -> %d]" % [
			player.current_weapon.name.to_upper(),
			player.weapon_level,
			player.weapon_level + 1
		]
		var desc = "+%.1f DMG, +%.1f ROF" % [
			player.current_weapon.damage_per_level,
			player.current_weapon.fire_rate_per_level
		]
		if player.current_weapon.pellets_per_level > 0:
			desc += ", +%d PELLETS" % player.current_weapon.pellets_per_level
		if player.current_weapon.pierce_per_level > 0:
			desc += ", +%d PIERCE" % player.current_weapon.pierce_per_level
		wep_card.description = desc
		wep_card.stat_type = "weapon_level"
		wep_card.sprite = player.current_weapon.card_icon if player.current_weapon.card_icon != null else player.current_weapon.sprite
		chosen_cards.append(wep_card)
		weapon_notice = "[SUPPLY CRATE] WEAPON TUNING AVAILABLE"
	elif player.is_weapon_evolved:
		weapon_notice = "★ ULTIMATE ARSENAL ENGAGED ★"
	else:
		var evo_st = get_evolution_status_for_current_weapon()
		if evo_st.get("has_evo", false) and not evo_st.get("upg_met", false):
			weapon_notice = "WEAPON MAXED (LV 5)! NEED %s UPGRADE TO EVOLVE" % evo_st.get("req_upg_name", "UPGRADE").to_upper()
		else:
			weapon_notice = "[SUPPLY CRATE] ARSENAL MAXIMIZED - ADVANCED UPGRADES"
	
	# Small field heal from opening crate
	player.current_hp = minf(player.max_hp, player.current_hp + 15.0)
	ui.update_hp(player.current_hp, player.max_hp)
	
	# Build pool of eligible upgrades and alternate weapon drops
	var candidates: Array[UpgradeData] = []
	
	# A. Weapon drop candidate with rolled rarity (chance to offer weapon swap)
	if not player.is_weapon_evolved and weapons.size() > 1:
		var alt_weapons: Array[WeaponData] = []
		for w in weapons:
			if w != null and w.id != player.current_weapon.id:
				alt_weapons.append(w)
		if not alt_weapons.is_empty():
			var rolled_wep = alt_weapons.pick_random()
			var rolled_rarity = rarity_data.roll_rarity() if rarity_data != null else {"name": "Common", "color": Color.WHITE, "multiplier": 1.0}
			var wep_drop_card = UpgradeData.new()
			wep_drop_card.id = "weapon_drop_" + rolled_wep.id
			wep_drop_card.name = "WEAPON: %s [%s]" % [rolled_wep.name.to_upper(), rolled_rarity.name.to_upper()]
			wep_drop_card.description = "Equip: %.0f DMG (x%.2f), %.1f/s ROF" % [
				rolled_wep.damage * rolled_rarity.multiplier,
				rolled_rarity.multiplier,
				rolled_wep.fire_rate
			]
			wep_drop_card.stat_type = "weapon_drop"
			wep_drop_card.sprite = rolled_wep.card_icon if rolled_wep.card_icon != null else rolled_wep.sprite
			wep_drop_card.weapon_drop_ref = rolled_wep
			wep_drop_card.weapon_drop_rarity = rolled_rarity
			candidates.append(wep_drop_card)
	
	# B. Eligible passives & general upgrades
	for upg in upgrades:
		if upg == null:
			continue
		if upg.is_passive:
			var curr_lvl = player.passive_levels.get(upg.id, 0)
			if curr_lvl < upg.max_level:
				var p_card = UpgradeData.new()
				p_card.id = upg.id
				p_card.name = "%s [LV %d -> %d]" % [upg.name.to_upper(), curr_lvl, curr_lvl + 1]
				p_card.stat_type = upg.stat_type
				p_card.sprite = upg.sprite
				p_card.flat_bonus = upg.flat_bonus
				p_card.multiplier_bonus = upg.multiplier_bonus
				p_card.per_level_bonus = upg.per_level_bonus
				p_card.is_passive = true
				
				match upg.stat_type:
					"magnet":
						p_card.description = "+%.0fpx Magnet Range (Total: +%.0fpx)" % [
							upg.flat_bonus if curr_lvl == 0 else upg.per_level_bonus,
							upg.flat_bonus + curr_lvl * upg.per_level_bonus
						]
					"lifesteal":
						p_card.description = "+%.1f HP per Kill (Total: %.1f HP)" % [
							upg.flat_bonus if curr_lvl == 0 else upg.per_level_bonus,
							upg.flat_bonus + curr_lvl * upg.per_level_bonus
						]
					"armor":
						p_card.description = "+%.0f%% Damage Reduction (Total: %.0f%%)" % [
							(upg.multiplier_bonus if curr_lvl == 0 else upg.per_level_bonus) * 100.0,
							(upg.multiplier_bonus + curr_lvl * upg.per_level_bonus) * 100.0
						]
					"revive":
						p_card.description = "+1 Second Chance Revive Charge"
					_:
						p_card.description = upg.description
				candidates.append(p_card)
		else:
			candidates.append(upg)
	
	candidates.shuffle()
	for c in candidates:
		if chosen_cards.size() >= 3:
			break
		var already_has = false
		for existing in chosen_cards:
			if existing.id == c.id:
				already_has = true
				break
		if not already_has:
			chosen_cards.append(c)
	
	ui.show_upgrade_choices(chosen_cards, weapon_notice)

func _on_upgrade_selected(upgrade: UpgradeData) -> void:
	if upgrade != null and not upgrade.name.is_empty():
		chosen_upgrade_names.append(upgrade.name)
	
	if upgrade.stat_type == "weapon_drop":
		if upgrade.weapon_drop_ref != null:
			player.set_weapon(upgrade.weapon_drop_ref, upgrade.weapon_drop_rarity)
	elif upgrade.stat_type == "evolution":
		var ready_evo = get_available_evolution()
		if ready_evo != null and ready_evo.evolved_weapon != null:
			player.evolve_weapon(ready_evo.evolved_weapon)
	elif upgrade.stat_type == "weapon_level":
		player.level_up_weapon()
	else:
		player.apply_upgrade(upgrade)
		acquired_upgrade_ids[upgrade.id] = true
	
	_update_weapon_hud()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# ==========================================
# DEBUG METHODS (Active only in debug builds)
# ==========================================

func debug_add_time(amount: float = -1.0) -> void:
	var delta_time = amount if amount > 0.0 else (debug_config.add_time_amount if debug_config != null else 60.0)
	game_time += delta_time
	ui.update_time(game_time)

func debug_spawn_boss(offset_dist: float = -1.0) -> Node2D:
	if is_game_over or not is_instance_valid(player) or wave_data == null or wave_data.boss_data == null:
		return null
	var dist = offset_dist if offset_dist > 0.0 else (debug_config.boss_spawn_distance if debug_config != null else 280.0)
	var spawn_pos = player.global_position + Vector2.RIGHT.rotated(randf() * TAU) * dist
	
	var boss_inst = zombie_scene.instantiate()
	boss_inst.global_position = spawn_pos
	zombies_node.add_child(boss_inst)
	boss_inst.apply_enemy_data(wave_data.boss_data, 1.0, 1.0)
	active_boss = boss_inst
	
	boss_inst.boss_hp_changed.connect(func(curr, max_hp): ui.update_boss_hp(curr, max_hp, wave_data.boss_data.name))
	boss_inst.boss_died.connect(_on_boss_died)
	boss_inst.died.connect(_on_zombie_died)
	boss_inst.shoot_projectile.connect(_on_zombie_shoot_projectile)
	boss_inst.drop_crate_requested.connect(_on_drop_crate_requested)
	boss_inst.drop_souls_requested.connect(_on_drop_souls_requested)
	
	ui.update_boss_hp(wave_data.boss_data.hp, wave_data.boss_data.hp, wave_data.boss_data.name)
	return boss_inst

func debug_spawn_enemy(enemy_res: EnemyData, offset_dist: float = -1.0) -> Node2D:
	if is_game_over or not is_instance_valid(player) or enemy_res == null:
		return null
	var max_cap = run_data.max_enemies if run_data != null else 150
	if get_live_enemy_count() >= max_cap:
		return null
	var dist = offset_dist if offset_dist > 0.0 else (debug_config.enemy_spawn_distance if debug_config != null else 240.0)
	var spawn_pos = player.global_position + Vector2.RIGHT.rotated(randf() * TAU) * dist
	
	var zombie_inst = zombie_scene.instantiate()
	zombie_inst.global_position = spawn_pos
	zombies_node.add_child(zombie_inst)
	zombie_inst.apply_enemy_data(enemy_res, 1.0, 1.0)
	
	zombie_inst.died.connect(_on_zombie_died)
	zombie_inst.shoot_projectile.connect(_on_zombie_shoot_projectile)
	zombie_inst.drop_crate_requested.connect(_on_drop_crate_requested)
	zombie_inst.drop_souls_requested.connect(_on_drop_souls_requested)
	zombie_inst.summon_requested.connect(_on_zombie_summon_requested)
	return zombie_inst

func debug_give_crate(offset: Vector2 = Vector2.ZERO) -> void:
	if is_game_over or not is_instance_valid(player):
		return
	var actual_offset = offset if offset != Vector2.ZERO else (debug_config.crate_spawn_offset if debug_config != null else Vector2(70.0, 0.0))
	_on_drop_crate_requested(player.global_position + actual_offset)

func debug_set_weapon_level(level: int = -1) -> void:
	if player == null or not is_instance_valid(player):
		return
	var target_lvl = level if level > 0 else (debug_config.target_weapon_level if debug_config != null else 5)
	player.set_weapon_level(target_lvl)
	_update_weapon_hud()

func debug_add_souls(amount: int = -1) -> void:
	var souls_to_add = amount if amount > 0 else (debug_config.add_souls_amount if debug_config != null else 1000)
	run_souls += souls_to_add
	ui.update_souls(run_souls)

func debug_toggle_god_mode() -> bool:
	if player == null or not is_instance_valid(player):
		return false
	player.set_god_mode(not player.is_god_mode)
	return player.is_god_mode

func get_live_enemy_count() -> int:
	if zombies_node == null:
		return 0
	var count = 0
	for child in zombies_node.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			if not ("is_dead" in child and child.is_dead):
				count += 1
	return count
