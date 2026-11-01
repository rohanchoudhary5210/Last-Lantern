class_name EnemyData
extends Resource

@export var id: String = "walker"
@export var name: String = "Walker"
@export var damage: float = 15.0 # Damage per second / contact
@export var fire_rate: float = 1.0 # Attack cadence in seconds
@export var speed: float = 85.0
@export var hp: float = 35.0
@export var score_value: int = 10
@export var soul_value: int = 1
@export var sprite: Texture2D
@export var sound: AudioStream

# Ranged / Spitter & Boss extensions
@export var is_ranged: bool = false
@export var stop_range: float = 240.0
@export var shoot_interval: float = 2.4
@export var projectile_speed: float = 260.0
@export var projectile_damage: float = 12.0
@export var is_boss: bool = false
@export var drops_crate: bool = false

# Exploder Archetype (Phase 6)
@export var is_exploder: bool = false
@export var explosion_radius: float = 130.0
@export var explosion_damage: float = 40.0
@export var explosion_delay: float = 0.5

# Charger Archetype (Phase 6)
@export var is_charger: bool = false
@export var charge_telegraph_time: float = 0.7
@export var charge_speed: float = 420.0
@export var charge_duration: float = 0.65
@export var charge_cooldown: float = 3.5
@export var charge_range: float = 280.0
@export var charge_damage: float = 25.0

# Summoner Archetype (Phase 6)
@export var is_summoner: bool = false
@export var summon_interval: float = 6.0
@export var summon_count: int = 2
@export var summon_max_alive: int = 6
@export var summon_enemy_data: EnemyData
@export var keep_distance: float = 320.0

# Ghost Archetype (Phase 6)
@export var is_ghost: bool = false
@export var passes_through_enemies: bool = true
@export var invisible_in_darkness: bool = true
