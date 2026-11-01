class_name SoulPickup
extends Area2D

signal collected(value: int)

@export var value: int = 1

var is_collected: bool = false
var magnetized: bool = false
var speed: float = 0.0
var max_speed: float = 750.0
var acceleration: float = 1600.0
var scatter_velocity: Vector2 = Vector2.ZERO
var player_ref: Node2D = null
var wobble_time: float = 0.0

# Perf: souls pile up fast; only the first few glow with a real light.
const MAX_SOUL_LIGHTS := 14
static var _lit_souls: int = 0
var _has_light_slot: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var light: PointLight2D = $PointLight2D

func _ready() -> void:
	add_to_group("souls")
	wobble_time = randf_range(0.0, 10.0)
	body_entered.connect(_on_body_entered)
	if _lit_souls < MAX_SOUL_LIGHTS:
		_lit_souls += 1
		_has_light_slot = true
	elif light != null:
		light.enabled = false

func _exit_tree() -> void:
	if _has_light_slot:
		_has_light_slot = false
		_lit_souls = maxi(0, _lit_souls - 1)

func setup(soul_value: int, impulse: Vector2 = Vector2.ZERO) -> void:
	value = maxi(1, soul_value)
	scatter_velocity = impulse
	if value >= 5:
		# Slightly larger glow for high-value souls (tanks / bosses)
		scale = Vector2(1.2, 1.2)
		if light != null:
			light.energy = 1.8
			light.texture_scale = 0.65

func _physics_process(delta: float) -> void:
	if is_collected:
		return
	
	wobble_time += delta
	
	if player_ref == null or not is_instance_valid(player_ref):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player_ref = players[0]
	
	if player_ref != null and is_instance_valid(player_ref):
		var to_player = player_ref.global_position - global_position
		var dist = to_player.length()
		var magnet_radius = player_ref.soul_magnet_radius if ("soul_magnet_radius" in player_ref) else 120.0
		
		if dist <= magnet_radius or magnetized:
			magnetized = true
			speed = minf(max_speed, speed + acceleration * delta)
			var dir = to_player.normalized()
			global_position += dir * speed * delta
			sprite.rotation = dir.angle() + PI / 2.0
			
			if dist <= 28.0:
				_collect(player_ref)
				return
		else:
			if scatter_velocity.length_squared() > 1.0:
				global_position += scatter_velocity * delta
				scatter_velocity = scatter_velocity.move_toward(Vector2.ZERO, 380.0 * delta)
			
			if sprite != null:
				sprite.position.y = sin(wobble_time * 6.0) * 3.5
				sprite.rotation = sin(wobble_time * 3.0) * 0.15

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		_collect(body)

func _collect(collector: Node2D) -> void:
	if is_collected:
		return
	is_collected = true
	collision_shape.set_deferred("disabled", true)
	
	if collector.has_method("collect_souls"):
		collector.collect_souls(value)
	collected.emit(value)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.12).set_ease(Tween.EASE_IN)
	if light != null:
		tween.tween_property(light, "energy", 0.0, 0.12)
	tween.chain().tween_callback(queue_free)
