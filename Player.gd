extends CharacterBody2D

signal hp_changed(current_hp: float, max_hp: float)
signal died
signal shoot_bullet(weapon: WeaponData, spawn_pos: Vector2, direction: Vector2, target_pos: Vector2)
signal souls_collected(amount: int)
signal weapon_leveled_up(new_level: int, weapon: WeaponData)
signal weapon_evolved(evolved_weapon: WeaponData)
signal passives_updated(passive_levels: Dictionary, passive_resources: Dictionary, revives_left: int)
signal deck_applied(equipped_cards: Array)

@export var player_data: PlayerData
@export var current_weapon: WeaponData
@export var game_feel: GameFeelData

var current_hp: float = 100.0
var max_hp: float = 100.0
var base_speed: float = 210.0
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
var speed_mult: float = 1.0
var torch_radius_mult: float = 1.0
var base_torch_scale: float = 1.6
var soul_magnet_radius: float = 120.0
var base_magnet_radius: float = 120.0

var weapon_level: int = 1
var is_weapon_evolved: bool = false

var active_meta_levels: Dictionary = {}
var meta_resources_cache: Array = []

var shoot_cooldown: float = 0.0
var target_zombie: Node2D = null
var _aim_scan_t: float = 0.0 # re-scan for nearest zombie 10x/sec instead of every physics frame
var is_dead: bool = false
var hurt_flash_timer: float = 0.0
var joystick_vector: Vector2 = Vector2.ZERO

var camera_ref: Camera2D = null
var shake_remaining: float = 0.0

var selected_hero: HeroData = null
var weapon_rarity_multiplier: float = 1.0
var weapon_rarity_name: String = "Common"
var weapon_rarity_color: Color = Color.WHITE

var is_god_mode: bool = false
var last_damage_source: String = "Zombie"

# Phase 7 Passives
var passive_levels: Dictionary = {}
var passive_resources: Dictionary = {}
var lifesteal_per_kill: float = 0.0
var armor_reduction: float = 0.0
var revives_remaining: int = 0

# Phase 8 Deck & Collectible Cards
var equipped_cards: Array = []
var bonus_crate_chance: float = 0.0
var boss_damage_mult: float = 0.0
var soul_gain_mult: float = 0.0
var has_shield: bool = false
var shield_max_cooldown: float = 0.0
var shield_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var light: PointLight2D = $PointLight2D
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_audio: AudioStreamPlayer2D = $ShootAudio
@onready var hurt_audio: AudioStreamPlayer2D = $HurtAudio

func _ready() -> void:
	if player_data == null:
		player_data = load("res://data/player_default.tres")
	if current_weapon == null:
		current_weapon = load("res://data/weapons/pistol.tres")
	if game_feel == null:
		game_feel = load("res://data/game_feel.tres")
	
	_find_camera()
	_apply_game_feel()
	_init_stats()

func _find_camera() -> void:
	for child in get_children():
		if child is Camera2D:
			camera_ref = child
			break
	if camera_ref == null:
		var parent = get_parent()
		if parent != null:
			for sibling in parent.get_children():
				if sibling is Camera2D:
					camera_ref = sibling
					break

func _apply_game_feel() -> void:
	if game_feel != null:
		if shoot_audio != null:
			shoot_audio.volume_db = game_feel.sfx_volume_db
		if hurt_audio != null:
			hurt_audio.volume_db = game_feel.sfx_volume_db

func _init_stats() -> void:
	if player_data != null:
		max_hp = player_data.hp if "hp" in player_data else 100.0
		current_hp = max_hp
		base_speed = player_data.speed if "speed" in player_data else 210.0
		damage_mult = player_data.damage if "damage" in player_data else 1.0
		fire_rate_mult = player_data.fire_rate if "fire_rate" in player_data else 1.0
		torch_radius_mult = player_data.torch_radius if "torch_radius" in player_data else 1.0
		base_magnet_radius = 120.0
		soul_magnet_radius = base_magnet_radius
		if player_data.sprite != null and sprite != null:
			sprite.texture = player_data.sprite
		if player_data.sound != null and hurt_audio != null:
			hurt_audio.stream = player_data.sound
	
	hp_changed.emit(current_hp, max_hp)
	_update_torch()

func apply_hero(hero: HeroData) -> void:
	selected_hero = hero
	max_hp = hero.hp
	current_hp = max_hp
	base_speed = hero.speed
	if hero.sprite != null and sprite != null:
		sprite.texture = hero.sprite
	
	match hero.passive_type:
		"torch_bonus":
			torch_radius_mult += hero.passive_value
			_update_torch()
		"speed_bonus":
			speed_mult += hero.passive_value
			fire_rate_mult += 0.15
		"damage_bonus":
			damage_mult += hero.passive_value
	
	if hero.starting_weapon != null:
		set_weapon(hero.starting_weapon)
	
	if not active_meta_levels.is_empty():
		_recalc_meta_bonuses()
	else:
		hp_changed.emit(current_hp, max_hp)

func apply_curse(curse: CurseData) -> void:
	if curse == null:
		return
	if curse.torch_radius_mult != 1.0:
		torch_radius_mult *= curse.torch_radius_mult
		_update_torch()
	if curse.soul_gain_mult > 0.0:
		soul_gain_mult += curse.soul_gain_mult
	if curse.player_damage_mult > 0.0:
		damage_mult += curse.player_damage_mult
	if curse.player_speed_mult > 0.0:
		speed_mult += curse.player_speed_mult
	if curse.player_hp_mult != 1.0:
		max_hp = maxf(10.0, max_hp * curse.player_hp_mult)
		current_hp = minf(current_hp, max_hp)
		hp_changed.emit(current_hp, max_hp)

func collect_souls(amount: int) -> void:
	var final_amt = int(round(float(amount) * (1.0 + soul_gain_mult)))
	souls_collected.emit(final_amt)

func apply_meta_upgrades(levels: Dictionary, meta_resources: Array = []) -> void:
	active_meta_levels = levels.duplicate()
	if not meta_resources.is_empty():
		meta_resources_cache = meta_resources
	elif meta_resources_cache.is_empty():
		meta_resources_cache = [
			load("res://data/meta/meta_max_hp.tres"),
			load("res://data/meta/meta_move_speed.tres"),
			load("res://data/meta/meta_torch_radius.tres"),
			load("res://data/meta/meta_damage.tres"),
			load("res://data/meta/meta_soul_magnet.tres")
		]
	
	_recalc_meta_bonuses()

func _recalc_meta_bonuses() -> void:
	var hp_bonus: float = 0.0
	var speed_bonus: float = 0.0
	var torch_bonus: float = 0.0
	var dmg_bonus: float = 0.0
	var magnet_bonus: float = 0.0
	
	for meta in meta_resources_cache:
		if meta == null:
			continue
		var lvl: int = active_meta_levels.get(meta.id, 0)
		if lvl <= 0:
			continue
		match meta.stat_type:
			"max_hp":
				hp_bonus += lvl * meta.bonus_per_level
			"move_speed":
				speed_bonus += lvl * meta.bonus_per_level
			"torch_radius":
				torch_bonus += lvl * meta.bonus_per_level
			"damage":
				dmg_bonus += lvl * meta.bonus_per_level
			"soul_magnet":
				magnet_bonus += lvl * meta.bonus_per_level
	
	max_hp += hp_bonus
	current_hp = max_hp
	speed_mult += speed_bonus
	torch_radius_mult += torch_bonus
	damage_mult += dmg_bonus
	soul_magnet_radius = base_magnet_radius + magnet_bonus
	
	_update_torch()

func apply_deck(cards: Array, collection: Dictionary) -> void:
	equipped_cards = cards
	for card in cards:
		if card == null:
			continue
		var lvl = 1
		if collection.has(card.id):
			var entry = collection[card.id]
			if typeof(entry) == TYPE_DICTIONARY:
				lvl = maxi(1, int(entry.get("level", 1)))
			elif typeof(entry) == TYPE_INT:
				lvl = maxi(1, entry)
		
		for stat_name in card.stat_modifiers:
			var bonus = float(card.stat_modifiers[stat_name]) * float(lvl)
			match stat_name:
				"damage":
					damage_mult += bonus
				"fire_rate":
					fire_rate_mult += bonus
				"max_hp":
					max_hp += bonus
					current_hp = max_hp
					hp_changed.emit(current_hp, max_hp)
				"move_speed":
					speed_mult += bonus
				"torch_radius":
					torch_radius_mult += bonus
					_update_torch()
				"soul_gain":
					soul_gain_mult += bonus
				"magnet_radius":
					base_magnet_radius += bonus
					soul_magnet_radius += bonus
				"first_hit_shield":
					has_shield = true
					shield_max_cooldown = maxf(12.0, 45.0 - (lvl - 1) * 6.0)
					shield_timer = 0.0
				"crate_drop_chance":
					bonus_crate_chance += bonus
				"boss_damage":
					boss_damage_mult += bonus
				"revive_once":
					revives_remaining += int(bonus)
				"lifesteal":
					lifesteal_per_kill += bonus
	
	deck_applied.emit(equipped_cards)

func set_weapon(new_weapon: WeaponData, rarity_info: Dictionary = {}, keep_level: bool = false) -> void:
	current_weapon = new_weapon
	if not keep_level:
		weapon_level = 1
	is_weapon_evolved = new_weapon.is_evolved if new_weapon != null else false
	
	if not rarity_info.is_empty():
		weapon_rarity_multiplier = rarity_info.get("multiplier", 1.0)
		weapon_rarity_name = rarity_info.get("name", "Common")
		weapon_rarity_color = rarity_info.get("color", Color.WHITE)
	else:
		weapon_rarity_multiplier = 1.0
		weapon_rarity_name = "Common"
		weapon_rarity_color = Color.WHITE
	shoot_cooldown = 0.0

func level_up_weapon() -> int:
	if current_weapon == null:
		return weapon_level
	if weapon_level < current_weapon.max_level:
		weapon_level += 1
		weapon_leveled_up.emit(weapon_level, current_weapon)
	return weapon_level

func set_weapon_level(target_level: int) -> int:
	if current_weapon == null:
		return weapon_level
	weapon_level = clampi(target_level, 1, current_weapon.max_level)
	weapon_leveled_up.emit(weapon_level, current_weapon)
	return weapon_level

func set_god_mode(enabled: bool) -> void:
	is_god_mode = enabled
	if is_god_mode:
		current_hp = max_hp
		hp_changed.emit(current_hp, max_hp)

func evolve_weapon(evolved: WeaponData) -> void:
	current_weapon = evolved
	weapon_level = 1
	is_weapon_evolved = true
	shoot_cooldown = 0.0
	weapon_evolved.emit(current_weapon)

func get_effective_damage(target_is_boss: bool = false) -> float:
	if current_weapon == null:
		var base = 20.0 * damage_mult * weapon_rarity_multiplier
		return base * (1.0 + boss_damage_mult) if target_is_boss else base
	var base_d = current_weapon.damage + (weapon_level - 1) * current_weapon.damage_per_level
	var dmg = base_d * damage_mult * weapon_rarity_multiplier
	if target_is_boss:
		dmg *= (1.0 + boss_damage_mult)
	return dmg

func get_effective_fire_rate() -> float:
	if current_weapon == null:
		return 1.0 * fire_rate_mult
	var base_fr = current_weapon.fire_rate + (weapon_level - 1) * current_weapon.fire_rate_per_level
	return base_fr * fire_rate_mult

func get_effective_pellets() -> int:
	if current_weapon == null:
		return 1
	return max(1, current_weapon.pellets + (weapon_level - 1) * current_weapon.pellets_per_level)

func get_effective_pierce() -> int:
	if current_weapon == null:
		return 0
	return max(0, current_weapon.pierce + (weapon_level - 1) * current_weapon.pierce_per_level)

func apply_upgrade(upgrade: UpgradeData) -> void:
	if upgrade.is_passive:
		var curr_lvl = passive_levels.get(upgrade.id, 0) + 1
		passive_levels[upgrade.id] = curr_lvl
		passive_resources[upgrade.id] = upgrade
		
		match upgrade.stat_type:
			"magnet":
				var extra = upgrade.flat_bonus + (curr_lvl - 1) * upgrade.per_level_bonus
				soul_magnet_radius = base_magnet_radius + extra
			"lifesteal":
				lifesteal_per_kill = upgrade.flat_bonus + (curr_lvl - 1) * upgrade.per_level_bonus
			"armor":
				armor_reduction = minf(0.85, upgrade.multiplier_bonus + (curr_lvl - 1) * upgrade.per_level_bonus)
			"revive":
				revives_remaining += int(upgrade.flat_bonus)
		
		passives_updated.emit(passive_levels, passive_resources, revives_remaining)
		return
	
	match upgrade.stat_type:
		"fire_rate":
			fire_rate_mult += upgrade.multiplier_bonus
		"damage":
			damage_mult += upgrade.multiplier_bonus
		"move_speed":
			speed_mult += upgrade.multiplier_bonus
		"torch_radius":
			torch_radius_mult += upgrade.multiplier_bonus
			_update_torch()
		"max_hp":
			max_hp += upgrade.flat_bonus
			current_hp = min(max_hp, current_hp + upgrade.flat_bonus)
			hp_changed.emit(current_hp, max_hp)

func on_enemy_killed() -> void:
	if lifesteal_per_kill > 0.0 and not is_dead and current_hp < max_hp:
		current_hp = minf(max_hp, current_hp + lifesteal_per_kill)
		hp_changed.emit(current_hp, max_hp)

func _update_torch() -> void:
	if light != null:
		light.texture_scale = base_torch_scale * torch_radius_mult

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Shield recharge
	if not has_shield and shield_max_cooldown > 0.0:
		shield_timer -= delta
		if shield_timer <= 0.0:
			has_shield = true
			# Visual shield pulse
			if sprite != null:
				sprite.modulate = Color(0.3, 0.9, 1.8, 1.0)
				var tw = create_tween()
				tw.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	
	_handle_movement(delta)
	_handle_auto_aim(delta)
	_handle_auto_shoot(delta)
	_handle_lantern_flicker()
	_handle_screen_shake(delta)

func _handle_screen_shake(delta: float) -> void:
	if camera_ref == null:
		_find_camera()
		if camera_ref == null:
			return
	
	if shake_remaining > 0.0:
		shake_remaining -= delta
		var dur = game_feel.screen_shake_duration if game_feel != null else 0.25
		var str_base = game_feel.screen_shake_strength if game_feel != null else 14.0
		var progress = clampf(shake_remaining / max(0.01, dur), 0.0, 1.0)
		var current_shake = str_base * progress
		camera_ref.offset = Vector2(randf_range(-current_shake, current_shake), randf_range(-current_shake, current_shake))
	else:
		camera_ref.offset = Vector2.ZERO

func _handle_movement(_delta: float) -> void:
	var input_vec = Vector2.ZERO
	
	if joystick_vector != Vector2.ZERO:
		input_vec = joystick_vector
	else:
		if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			input_vec.x += 1.0
		if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			input_vec.x -= 1.0
		if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			input_vec.y += 1.0
		if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			input_vec.y -= 1.0
		
		if input_vec != Vector2.ZERO:
			input_vec = input_vec.normalized()
	
	var target_speed = base_speed * speed_mult
	velocity = input_vec * target_speed
	move_and_slide()

func _handle_auto_aim(delta: float) -> void:
	_aim_scan_t -= delta
	var target_ok: bool = is_instance_valid(target_zombie) and not ("is_dead" in target_zombie and target_zombie.is_dead)
	if _aim_scan_t <= 0.0 or not target_ok:
		_aim_scan_t = 0.1
		target_zombie = _find_nearest_zombie()
	if target_zombie != null:
		var target_dir = (target_zombie.global_position - global_position).normalized()
		var target_angle = target_dir.angle()
		sprite.rotation = lerp_angle(sprite.rotation, target_angle + PI / 2.0, delta * 14.0)
		muzzle.position = target_dir * 20.0
	else:
		if velocity.length_squared() > 10.0:
			var move_angle = velocity.angle()
			sprite.rotation = lerp_angle(sprite.rotation, move_angle + PI / 2.0, delta * 8.0)

func _find_nearest_zombie() -> Node2D:
	var zombies = get_tree().get_nodes_in_group("zombies")
	var nearest: Node2D = null
	var min_dist: float = 1e8
	
	for z in zombies:
		if is_instance_valid(z) and z is Node2D:
			if "is_dead" in z and z.is_dead:
				continue
			var dist = global_position.distance_squared_to(z.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = z
	return nearest

func _handle_auto_shoot(delta: float) -> void:
	if shoot_cooldown > 0.0:
		shoot_cooldown -= delta
	
	if shoot_cooldown <= 0.0 and target_zombie != null and current_weapon != null:
		_shoot()
		var effective_rate = get_effective_fire_rate()
		shoot_cooldown = 1.0 / max(0.1, effective_rate)

func _shoot() -> void:
	if current_weapon == null or target_zombie == null:
		return
	
	var base_dir = (target_zombie.global_position - global_position).normalized()
	var spawn_pos = global_position + (base_dir * 18.0)
	var target_pos = target_zombie.global_position
	
	shoot_bullet.emit(current_weapon, spawn_pos, base_dir, target_pos)
	
	if current_weapon.sound != null:
		shoot_audio.stream = current_weapon.sound
		shoot_audio.pitch_scale = randf_range(0.95, 1.05)
		shoot_audio.play()

func _handle_lantern_flicker() -> void:
	if light == null:
		return
	var t = Time.get_ticks_msec() * 0.001
	var flicker = sin(t * 7.0) * 0.04 + sin(t * 19.0) * 0.02
	light.energy = 1.25 + flicker

func take_damage(amount: float, source_name: String = "Zombie") -> void:
	if is_dead or is_god_mode:
		return
	
	# Aegis Barrier Shield absorption
	if has_shield:
		has_shield = false
		shield_timer = shield_max_cooldown
		sprite.modulate = Color(0.2, 1.2, 2.5, 1.0)
		var s_tw = create_tween()
		s_tw.tween_property(sprite, "modulate", Color.WHITE, 0.2)
		return
	
	last_damage_source = source_name
	var effective_amount = amount * maxf(0.1, 1.0 - armor_reduction)
	current_hp = max(0.0, current_hp - effective_amount)
	hp_changed.emit(current_hp, max_hp)
	
	shake_remaining = game_feel.screen_shake_duration if game_feel != null else 0.25
	
	if not hurt_audio.playing and hurt_audio.stream != null:
		hurt_audio.pitch_scale = randf_range(0.9, 1.1)
		hurt_audio.play()
	
	sprite.modulate = Color(2.5, 0.4, 0.4, 1.0)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	
	if current_hp <= 0.0:
		if revives_remaining > 0:
			_trigger_revive()
		else:
			_die()

func _trigger_revive() -> void:
	revives_remaining -= 1
	current_hp = max_hp * 0.5
	hp_changed.emit(current_hp, max_hp)
	passives_updated.emit(passive_levels, passive_resources, revives_remaining)
	
	var revive_sfx = load("res://assets/audio/revive.wav")
	if hurt_audio != null and revive_sfx != null:
		hurt_audio.stream = revive_sfx
		hurt_audio.pitch_scale = 1.0
		hurt_audio.play()
	
	sprite.modulate = Color(3.0, 2.5, 0.5, 1.0)
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.8)

func _die() -> void:
	is_dead = true
	died.emit()
	velocity = Vector2.ZERO
	var tween = create_tween().set_parallel(true)
	tween.tween_property(light, "energy", 0.0, 1.2)
	tween.tween_property(sprite, "modulate:a", 0.2, 1.2)
