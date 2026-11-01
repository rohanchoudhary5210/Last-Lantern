extends CharacterBody2D

signal died(zombie: Node2D)
signal shoot_projectile(pos: Vector2, dir: Vector2, speed: float, damage: float, color: Color, shooter_name: String)
signal boss_hp_changed(current: float, max_hp: float)
signal boss_died(zombie: Node2D, death_pos: Vector2)
signal drop_crate_requested(drop_pos: Vector2)
signal drop_souls_requested(drop_pos: Vector2, soul_value: int)
signal summon_requested(summoner: Node2D, enemy_to_summon: EnemyData, count: int)

@export var enemy_data: EnemyData
@export var game_feel: GameFeelData

var current_hp: float = 35.0
var max_hp: float = 35.0
var move_speed: float = 85.0
var touch_damage: float = 15.0 # Damage per second
var is_dead: bool = false
var wobble_offset: float = 0.0
var player_ref: Node2D = null
var shoot_cooldown: float = 1.0

# Elite stats & appearance
var is_elite: bool = false
var elite_data: EliteData = null

# Exploder state
var is_exploding: bool = false
var explode_timer: float = 0.0

# Charger state
var is_telegraphing: bool = false
var is_charging: bool = false
var charge_timer: float = 0.0
var charge_cooldown_timer: float = 0.0
var charge_dir: Vector2 = Vector2.ZERO
var has_hit_player_this_charge: bool = false

# Summoner state
var summon_cooldown: float = 0.0
var active_minions: Array[Node2D] = []

var hit_sound: AudioStream = preload("res://assets/audio/hit.wav")

# Perf: each PointLight2D is an extra render pass, so only a handful of nearby eyes glow per frame.
const MAX_EYE_LIGHTS := 28
const EYE_LIGHT_RANGE := 520.0
const DAMAGE_NUMBER_GAP_MSEC := 40 # at most ~25 floating numbers per second
static var _lit_frame: int = -1
static var _lit_count: int = 0
static var _last_number_msec: int = 0
var _flash_tween: Tween = null

func _eyes_allowed(dist: float) -> bool:
	var f := Engine.get_physics_frames()
	if f != _lit_frame:
		_lit_frame = f
		_lit_count = 0
	if dist > EYE_LIGHT_RANGE or _lit_count >= MAX_EYE_LIGHTS:
		return false
	_lit_count += 1
	return true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var eyes_light: PointLight2D = $EyesLight
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var death_particles: CPUParticles2D = $DeathParticles

func _ready() -> void:
	if game_feel == null:
		game_feel = load("res://data/game_feel.tres")
	
	_apply_game_feel()
	wobble_offset = randf_range(0.0, 100.0)
	if enemy_data != null:
		apply_enemy_data(enemy_data)
	_find_player()

func _apply_game_feel() -> void:
	if game_feel != null and death_particles != null:
		death_particles.amount = game_feel.death_particle_count
		death_particles.lifetime = game_feel.death_particle_lifetime
		death_particles.initial_velocity_min = game_feel.death_particle_speed * 0.5
		death_particles.initial_velocity_max = game_feel.death_particle_speed
		if game_feel.death_particle_texture != null:
			death_particles.texture = game_feel.death_particle_texture
		if sfx_player != null:
			sfx_player.volume_db = game_feel.sfx_volume_db

func apply_enemy_data(data: EnemyData, speed_multiplier: float = 1.0, hp_multiplier: float = 1.0, damage_multiplier: float = 1.0) -> void:
	enemy_data = data
	max_hp = data.hp * hp_multiplier
	current_hp = max_hp
	move_speed = data.speed * speed_multiplier
	touch_damage = data.damage * damage_multiplier
	shoot_cooldown = randf_range(0.5, data.shoot_interval)
	
	if data.sprite != null:
		sprite.texture = data.sprite
	if data.sound != null:
		sfx_player.stream = data.sound
	
	if data.is_boss:
		scale = Vector2(1.8, 1.8)
		eyes_light.texture_scale = 0.5
		eyes_light.energy = 2.5
		boss_hp_changed.emit(current_hp, max_hp)
	else:
		scale = Vector2.ONE
	
	# Archetype initial setup
	if data.is_ghost:
		collision_mask = 1 # Pass through other zombies (layer 2)
		eyes_light.visible = false
		sprite.modulate.a = 0.0 # Invisible until lit by torch
	elif data.is_summoner:
		summon_cooldown = data.summon_interval * 0.5
	elif data.is_charger:
		charge_cooldown_timer = randf_range(1.0, 2.5)

func apply_elite(elite: EliteData) -> void:
	if enemy_data != null and enemy_data.is_boss:
		return # Bosses have custom stats
	is_elite = true
	elite_data = elite
	max_hp *= elite.hp_multiplier
	current_hp = max_hp
	move_speed *= elite.speed_multiplier
	scale = scale * elite.scale_multiplier
	sprite.self_modulate = elite.elite_color
	eyes_light.color = elite.elite_color
	eyes_light.energy = 2.6

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player_ref = players[0]

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if player_ref == null or not is_instance_valid(player_ref):
		_find_player()
		if player_ref == null:
			return
	
	var to_player = player_ref.global_position - global_position
	var dist = to_player.length()
	var dir = to_player.normalized()
	
	# Exploder exploding countdown
	if is_exploding:
		explode_timer -= delta
		queue_redraw()
		if int(explode_timer * 16.0) % 2 == 0:
			sprite.modulate = Color(3.0, 0.4, 0.4, 1.0)
		else:
			sprite.modulate = Color.WHITE
		velocity = Vector2.ZERO
		move_and_slide()
		if explode_timer <= 0.0:
			_explode_and_die()
		return
	
	# Check Exploder proximity trigger
	if enemy_data != null and enemy_data.is_exploder and dist <= enemy_data.explosion_radius * 0.75:
		_trigger_explosion_sequence()
		return
	
	# Charger behavior
	if enemy_data != null and enemy_data.is_charger:
		if is_telegraphing:
			charge_timer -= delta
			velocity = Vector2.ZERO
			move_and_slide()
			sprite.rotation = lerp_angle(sprite.rotation, charge_dir.angle() + PI / 2.0, delta * 12.0)
			# Warning flashing
			sprite.modulate = Color(2.5, 0.4, 0.4) if int(charge_timer * 14.0) % 2 == 0 else Color.WHITE
			if charge_timer <= 0.0:
				is_telegraphing = false
				is_charging = true
				charge_timer = enemy_data.charge_duration
				has_hit_player_this_charge = false
				sprite.modulate = Color(1.8, 1.4, 0.4)
				if sfx_player != null and enemy_data.sound != null:
					sfx_player.stream = enemy_data.sound
					sfx_player.play()
			return
		elif is_charging:
			charge_timer -= delta
			velocity = charge_dir * enemy_data.charge_speed
			move_and_slide()
			if not has_hit_player_this_charge and dist < (38.0 * scale.x):
				has_hit_player_this_charge = true
				player_ref.take_damage(enemy_data.charge_damage, enemy_data.name if enemy_data != null else "Charger")
			if charge_timer <= 0.0:
				is_charging = false
				charge_cooldown_timer = enemy_data.charge_cooldown
				sprite.modulate = Color.WHITE
			return
		else:
			charge_cooldown_timer -= delta
			if charge_cooldown_timer <= 0.0 and dist <= enemy_data.charge_range:
				is_telegraphing = true
				charge_timer = enemy_data.charge_telegraph_time
				charge_dir = dir
				return
	
	# Summoner behavior
	if enemy_data != null and enemy_data.is_summoner:
		summon_cooldown -= delta
		# Clean dead minions
		var alive_m: Array[Node2D] = []
		for m in active_minions:
			if is_instance_valid(m) and not ("is_dead" in m and m.is_dead):
				alive_m.append(m)
		active_minions = alive_m
		
		if summon_cooldown <= 0.0 and active_minions.size() < enemy_data.summon_max_alive:
			summon_cooldown = enemy_data.summon_interval
			summon_requested.emit(self, enemy_data.summon_enemy_data, enemy_data.summon_count)
			if sfx_player != null and enemy_data.sound != null:
				sfx_player.stream = enemy_data.sound
				sfx_player.play()
		
		# Keep distance
		if dist < enemy_data.keep_distance:
			var flee_dir = -dir
			velocity = velocity.move_toward(flee_dir * move_speed, move_speed * 4.0 * delta)
			move_and_slide()
			sprite.rotation = lerp_angle(sprite.rotation, dir.angle() + PI / 2.0, delta * 8.0)
			return
	
	# Ghost visibility check (reveal inside torch light radius)
	if enemy_data != null and enemy_data.is_ghost:
		var torch_r = 180.0
		if player_ref != null and "base_torch_scale" in player_ref and "torch_radius_mult" in player_ref:
			torch_r = 135.0 * player_ref.base_torch_scale * player_ref.torch_radius_mult
		if dist <= torch_r:
			sprite.modulate.a = move_toward(sprite.modulate.a, 0.85, delta * 3.5)
		else:
			sprite.modulate.a = move_toward(sprite.modulate.a, 0.0, delta * 3.5)
	
	# Check ranged attack (spitter & boss)
	if enemy_data != null and enemy_data.is_ranged and dist <= enemy_data.stop_range:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * 4.0 * delta)
		move_and_slide()
		
		shoot_cooldown -= delta
		if shoot_cooldown <= 0.0:
			shoot_cooldown = enemy_data.shoot_interval
			var proj_color = Color(0.1, 1.0, 0.4) if not enemy_data.is_boss else Color(1.0, 0.25, 0.4)
			var spawn_offset = dir * (26.0 * scale.x)
			var shooter_name = enemy_data.name if enemy_data != null else "Spitter"
			shoot_projectile.emit(global_position + spawn_offset, dir, enemy_data.projectile_speed, enemy_data.projectile_damage, proj_color, shooter_name)
	else:
		# Standard movement towards player
		var wobble = sin((Time.get_ticks_msec() * 0.006) + wobble_offset) * 0.35
		var move_dir = dir.rotated(wobble)
		var target_vel = move_dir * move_speed
		velocity = velocity.move_toward(target_vel, move_speed * 4.0 * delta)
		move_and_slide()
	
	# Visual angle
	sprite.rotation = lerp_angle(sprite.rotation, dir.angle() + PI / 2.0, delta * 8.0)
	
	# Eye light pulse
	var important: bool = is_elite or (enemy_data != null and enemy_data.is_boss)
	eyes_light.enabled = eyes_light.visible and (important or _eyes_allowed(dist))
	if eyes_light.enabled:
		eyes_light.energy = (2.5 if (enemy_data != null and enemy_data.is_boss) else 1.8) + sin((Time.get_ticks_msec() * 0.01) + wobble_offset) * 0.4
	
	# Contact damage over time
	if dist < (36.0 * scale.x):
		if player_ref.has_method("take_damage"):
			player_ref.take_damage(touch_damage * delta, enemy_data.name if enemy_data != null else "Zombie")

func take_damage(amount: float, knockback: Vector2) -> void:
	if is_dead:
		return
	
	var final_dmg = amount
	if enemy_data != null and enemy_data.is_boss and player_ref != null and "boss_damage_mult" in player_ref:
		final_dmg *= (1.0 + player_ref.boss_damage_mult)
	
	current_hp -= final_dmg
	var effective_knockback = knockback * 0.2 if (enemy_data != null and enemy_data.is_boss) else knockback
	velocity += effective_knockback
	
	_spawn_damage_number(final_dmg)
	
	if enemy_data != null and enemy_data.is_boss:
		boss_hp_changed.emit(current_hp, max_hp)
	
	var flash_color = game_feel.hit_flash_color if game_feel != null else Color(3.0, 3.0, 3.0, 1.0)
	var flash_dur = game_feel.hit_flash_duration if game_feel != null else 0.09
	
	sprite.modulate = flash_color
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	var tween = create_tween()
	_flash_tween = tween
	var normal_color = Color.WHITE
	if enemy_data != null and enemy_data.is_ghost and sprite.modulate.a <= 0.1:
		normal_color.a = 0.0
	tween.tween_property(sprite, "modulate", normal_color, flash_dur)
	
	if current_hp <= 0.0:
		if enemy_data != null and enemy_data.is_exploder and not is_exploding:
			_trigger_explosion_sequence()
		else:
			_die()
	else:
		if hit_sound != null and sfx_player != null:
			sfx_player.stream = hit_sound
			sfx_player.pitch_scale = randf_range(0.95, 1.25)
			sfx_player.play()

func _trigger_explosion_sequence() -> void:
	if is_exploding or is_dead:
		return
	is_exploding = true
	explode_timer = enemy_data.explosion_delay
	queue_redraw()

func _explode_and_die() -> void:
	if player_ref != null and is_instance_valid(player_ref):
		var d = global_position.distance_to(player_ref.global_position)
		if d <= enemy_data.explosion_radius:
			player_ref.take_damage(enemy_data.explosion_damage, enemy_data.name if enemy_data != null else "Exploder")
	
	if enemy_data.sound != null and sfx_player != null:
		sfx_player.stream = enemy_data.sound
		sfx_player.pitch_scale = randf_range(0.9, 1.1)
		sfx_player.play()
	
	_die()

func _draw() -> void:
	if is_exploding and enemy_data != null and enemy_data.is_exploder:
		draw_arc(Vector2.ZERO, enemy_data.explosion_radius, 0.0, TAU, 32, Color(1.0, 0.2, 0.2, 0.85), 2.5)
		draw_circle(Vector2.ZERO, enemy_data.explosion_radius, Color(1.0, 0.15, 0.15, 0.18))

func _spawn_damage_number(amount: float) -> void:
	var parent_node = get_parent()
	if parent_node == null:
		return
	var is_boss_hit: bool = enemy_data != null and enemy_data.is_boss
	var now := Time.get_ticks_msec()
	if not is_boss_hit and now - _last_number_msec < DAMAGE_NUMBER_GAP_MSEC:
		return
	_last_number_msec = now
	
	var lbl = Label.new()
	lbl.text = str(int(round(amount)))
	lbl.global_position = global_position + Vector2(randf_range(-14.0, 14.0), -28.0 * scale.y)
	
	var num_color = game_feel.damage_number_color if game_feel != null else Color(1.0, 0.95, 0.35, 1.0)
	var num_life = game_feel.damage_number_lifetime if game_feel != null else 0.65
	var num_speed = game_feel.damage_number_float_speed if game_feel != null else 75.0
	
	lbl.add_theme_color_override("font_color", num_color)
	lbl.add_theme_font_size_override("font_size", 16 if (enemy_data == null or not enemy_data.is_boss) else 20)
	lbl.z_index = 20
	parent_node.add_child(lbl)
	
	lbl.scale = Vector2(1.25, 1.25)
	var tween = lbl.create_tween().set_parallel(true)
	tween.tween_property(lbl, "scale", Vector2.ONE, 0.15)
	tween.tween_property(lbl, "global_position:y", lbl.global_position.y - (num_speed * num_life), num_life)
	tween.tween_property(lbl, "modulate:a", 0.0, num_life).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(lbl.queue_free)

func _die() -> void:
	is_dead = true
	is_exploding = false
	queue_redraw()
	died.emit(self)
	collision_shape.set_deferred("disabled", true)
	
	if enemy_data != null and enemy_data.is_boss:
		boss_died.emit(self, global_position)
	
	# Drop crate (boss guaranteed or elite roll)
	if enemy_data != null and enemy_data.drops_crate:
		drop_crate_requested.emit(global_position)
	elif is_elite and elite_data != null and randf() <= elite_data.crate_drop_chance:
		drop_crate_requested.emit(global_position)
	
	var drop_amount = enemy_data.soul_value if enemy_data != null else 1
	if is_elite and elite_data != null:
		drop_amount *= elite_data.souls_multiplier
	drop_souls_requested.emit(global_position, drop_amount)
	
	if death_particles != null:
		death_particles.emitting = true
	
	if sfx_player.stream != null:
		sfx_player.pitch_scale = randf_range(0.85, 1.05)
		sfx_player.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(eyes_light, "energy", 0.0, 0.25)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	
	var wait_time = game_feel.death_particle_lifetime if game_feel != null else 0.4
	await get_tree().create_timer(wait_time).timeout
	queue_free()
