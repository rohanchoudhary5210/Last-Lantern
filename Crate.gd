extends Area2D

signal crate_opened(crate: Node2D)

enum State { FALLING, LANDED, OPENED }

@export var game_feel: GameFeelData

var current_state: State = State.FALLING
var fall_timer: float = 0.0
var fall_duration: float = 2.0
var start_y: float = -500.0

@onready var crate_sprite: Sprite2D = $CrateSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var beacon_light: PointLight2D = $BeaconLight
@onready var land_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var landing_dust: CPUParticles2D = $LandingDust

func _ready() -> void:
	if game_feel == null:
		game_feel = load("res://data/game_feel.tres")
	
	_apply_game_feel()
	body_entered.connect(_on_body_entered)
	crate_sprite.position.y = start_y
	shadow_sprite.scale = Vector2(0.15, 0.08)
	shadow_sprite.modulate.a = 0.1
	beacon_light.energy = 0.0

func _apply_game_feel() -> void:
	if game_feel != null and landing_dust != null:
		landing_dust.amount = game_feel.landing_dust_count
		landing_dust.lifetime = game_feel.landing_dust_lifetime
		landing_dust.initial_velocity_min = game_feel.landing_dust_speed * 0.5
		landing_dust.initial_velocity_max = game_feel.landing_dust_speed
		if game_feel.landing_dust_texture != null:
			landing_dust.texture = game_feel.landing_dust_texture
		if land_audio != null:
			land_audio.volume_db = game_feel.sfx_volume_db

func _process(delta: float) -> void:
	match current_state:
		State.FALLING:
			fall_timer += delta
			var progress = clampf(fall_timer / fall_duration, 0.0, 1.0)
			
			# Accelerating fall curve (ease-in)
			var y_ratio = 1.0 - (progress * progress)
			crate_sprite.position.y = start_y * y_ratio
			
			# Shadow grows as crate approaches ground
			var shadow_scale_x = lerpf(0.15, 0.9, progress)
			var shadow_scale_y = lerpf(0.08, 0.45, progress)
			shadow_sprite.scale = Vector2(shadow_scale_x, shadow_scale_y)
			shadow_sprite.modulate.a = lerpf(0.1, 0.75, progress)
			
			if progress >= 1.0:
				_on_landed()
		
		State.LANDED:
			# Pulse beacon light to guide player in the dark
			var t = Time.get_ticks_msec() * 0.005
			beacon_light.energy = 1.0 + sin(t) * 0.4
			# Floating hover motion
			crate_sprite.position.y = sin(t * 1.5) * 3.0

func _on_landed() -> void:
	current_state = State.LANDED
	crate_sprite.position.y = 0.0
	shadow_sprite.scale = Vector2(0.9, 0.45)
	shadow_sprite.modulate.a = 0.75
	
	# Trigger landing dust particles
	if landing_dust != null:
		landing_dust.emitting = true
	
	if land_audio.stream != null:
		land_audio.pitch_scale = randf_range(0.95, 1.05)
		land_audio.play()
	
	# Landing impact bounce
	var tween = create_tween()
	crate_sprite.scale = Vector2(1.35, 0.65)
	beacon_light.energy = 2.5
	tween.tween_property(crate_sprite, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(beacon_light, "energy", 1.0, 0.35)
	
	# Check if player is already inside the crate area upon landing
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_open()
			break

func _on_body_entered(body: Node2D) -> void:
	if current_state == State.LANDED and body.is_in_group("player"):
		_open()

func _open() -> void:
	if current_state != State.LANDED:
		return
	
	current_state = State.OPENED
	crate_opened.emit(self)
	
	# Opening explosion / flash
	var tween = create_tween().set_parallel(true)
	tween.tween_property(crate_sprite, "scale", Vector2(1.6, 1.6), 0.25)
	tween.tween_property(crate_sprite, "modulate:a", 0.0, 0.25)
	tween.tween_property(beacon_light, "energy", 0.0, 0.25)
	tween.tween_property(shadow_sprite, "modulate:a", 0.0, 0.25)
	
	await get_tree().create_timer(0.3).timeout
	queue_free()
