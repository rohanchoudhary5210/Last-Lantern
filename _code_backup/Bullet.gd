extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 700.0
var damage: float = 25.0
var pierce: int = 0
var lifetime: float = 1.6
var max_lifetime: float = 1.6
var bullet_color: Color = Color(1.0, 0.85, 0.2, 1.0)
var is_enemy_bullet: bool = false
var custom_texture: Texture2D = null

# Phase 7 Archetypes
var is_flame: bool = false
var is_bolt: bool = false
var bolt_stick_duration: float = 0.5
var is_stuck: bool = false
var stick_timer: float = 0.0

var is_grenade: bool = false
var explosion_radius: float = 125.0
var arc_height: float = 50.0
var start_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var total_distance: float = 0.0
var travel_progress: float = 0.0
var shooter_source: String = "Enemy Projectile"

@onready var sprite: Sprite2D = $Sprite2D
@onready var light: PointLight2D = $PointLight2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	_apply_visuals()

func _apply_visuals() -> void:
	if sprite != null and custom_texture != null:
		sprite.texture = custom_texture
	if sprite != null:
		sprite.modulate = bullet_color
	if light != null:
		light.color = bullet_color
	if not is_grenade:
		rotation = direction.angle()
	if is_enemy_bullet:
		collision_layer = 16
		collision_mask = 1

func setup(p_direction: Vector2, p_speed: float, p_damage: float, p_pierce: int, p_color: Color, p_is_enemy: bool = false, p_texture: Texture2D = null, p_lifetime: float = 1.6, p_shooter_source: String = "Enemy Projectile") -> void:
	direction = p_direction.normalized()
	speed = p_speed
	damage = p_damage
	pierce = p_pierce
	bullet_color = p_color
	is_enemy_bullet = p_is_enemy
	shooter_source = p_shooter_source
	lifetime = p_lifetime
	max_lifetime = p_lifetime
	if p_texture != null:
		custom_texture = p_texture
	if is_inside_tree():
		_apply_visuals()

func setup_from_weapon(weapon: WeaponData, p_spawn_pos: Vector2, p_dir: Vector2, p_damage: float, p_pierce: int, p_target_pos: Vector2 = Vector2.ZERO) -> void:
	global_position = p_spawn_pos
	start_pos = p_spawn_pos
	direction = p_dir.normalized()
	speed = weapon.speed
	damage = p_damage
	pierce = p_pierce
	bullet_color = weapon.bullet_color
	custom_texture = weapon.sprite
	lifetime = weapon.bullet_lifetime
	max_lifetime = weapon.bullet_lifetime
	
	is_flame = weapon.is_flame
	is_bolt = weapon.is_bolt
	bolt_stick_duration = weapon.bolt_stick_duration
	
	is_grenade = weapon.is_grenade
	explosion_radius = weapon.explosion_radius
	arc_height = weapon.arc_height
	target_pos = p_target_pos if p_target_pos != Vector2.ZERO else (p_spawn_pos + direction * 280.0)
	total_distance = maxf(1.0, start_pos.distance_to(target_pos))
	travel_progress = 0.0
	
	if is_inside_tree():
		_apply_visuals()

func _physics_process(delta: float) -> void:
	if is_stuck:
		stick_timer -= delta
		if stick_timer <= 0.0:
			queue_free()
		return
	
	if is_grenade:
		travel_progress += (speed * delta) / total_distance
		var clamped_p = minf(1.0, travel_progress)
		global_position = start_pos.lerp(target_pos, clamped_p)
		
		# Parabolic visual arc
		if sprite != null:
			sprite.position.y = -sin(clamped_p * PI) * arc_height
			sprite.rotation += delta * 14.0
		
		if travel_progress >= 1.0:
			_detonate_grenade()
		return
	
	# Normal & Flame & Bolt movement
	position += direction * speed * delta
	lifetime -= delta
	
	if is_flame:
		var prog = 1.0 - (lifetime / max_lifetime)
		scale = Vector2.ONE * lerp(0.85, 2.2, prog)
		if sprite != null:
			sprite.modulate.a = clampf(lifetime / (max_lifetime * 0.4), 0.0, 1.0)
	
	if lifetime <= 0.0:
		if is_bolt and not is_stuck:
			_stick_bolt()
		else:
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	_handle_hit(body)

func _on_area_entered(area: Area2D) -> void:
	_handle_hit(area)

func _handle_hit(target: Node2D) -> void:
	if is_stuck:
		return
	
	if is_enemy_bullet:
		if target.is_in_group("player") and target.has_method("take_damage"):
			target.take_damage(damage, shooter_source)
			queue_free()
		return
	
	if is_grenade:
		_detonate_grenade()
		return
	
	if target.is_in_group("zombies") and target.has_method("take_damage"):
		target.take_damage(damage, direction * 120.0)
		pierce -= 1
		if pierce < 0:
			if is_bolt:
				_stick_bolt()
			else:
				queue_free()

func _stick_bolt() -> void:
	if is_stuck:
		return
	is_stuck = true
	stick_timer = bolt_stick_duration
	speed = 0.0
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	position += direction * 8.0 # Sinks into ground
	
	var tween = create_tween()
	tween.tween_interval(bolt_stick_duration * 0.6)
	tween.tween_property(self, "modulate:a", 0.0, bolt_stick_duration * 0.4)
	tween.tween_callback(queue_free)

func _detonate_grenade() -> void:
	if is_stuck:
		return
	is_stuck = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	
	# Radial blast damage to all enemies within explosion_radius
	var zombies = get_tree().get_nodes_in_group("zombies")
	for z in zombies:
		if is_instance_valid(z) and z.has_method("take_damage"):
			if "is_dead" in z and z.is_dead:
				continue
			var d = global_position.distance_to(z.global_position)
			if d <= explosion_radius:
				var falloff = 1.0 - (d / explosion_radius) * 0.35
				var push_dir = (z.global_position - global_position).normalized()
				z.take_damage(damage * falloff, push_dir * 240.0)
	
	# Blast flash
	if sprite != null:
		sprite.visible = false
	if light != null:
		light.energy = 3.2
		light.texture_scale = explosion_radius / 48.0
		var tween = create_tween()
		tween.tween_property(light, "energy", 0.0, 0.22)
		tween.tween_callback(queue_free)
	else:
		queue_free()
