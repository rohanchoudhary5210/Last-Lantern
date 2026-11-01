class_name UpgradeData
extends Resource

@export var id: String = "fire_rate"
@export var name: String = "Rapid Trigger"
@export var description: String = "+25% Fire Rate"
@export var stat_type: String = "fire_rate"
@export var multiplier_bonus: float = 0.25
@export var flat_bonus: float = 0.0
@export var damage: float = 0.0
@export var fire_rate: float = 0.25
@export var speed: float = 0.0
@export var hp: float = 0.0
@export var sprite: Texture2D # Icon texture
@export var sound: AudioStream

# Phase 7: Passives & Level Scaling
@export var max_level: int = 1
@export var current_level: int = 1
@export var per_level_bonus: float = 0.0
@export var is_passive: bool = false

# Runtime crate card payload
var weapon_drop_ref: WeaponData = null
var weapon_drop_rarity: Dictionary = {}
