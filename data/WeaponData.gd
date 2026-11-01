class_name WeaponData
extends Resource

@export var id: String = "pistol"
@export var name: String = "Pistol"
@export var damage: float = 25.0
@export var fire_rate: float = 2.2 # Shots per second
@export var speed: float = 700.0 # Bullet flight speed
@export var hp: float = 0.0 # Not used for weapons, matches spec
@export var spread_angle: float = 0.0 # Degrees
@export var pellets: int = 1
@export var pierce: int = 0
@export var bullet_color: Color = Color(1.0, 0.85, 0.2, 1.0)
@export var sprite: Texture2D
@export var sound: AudioStream
@export var card_icon: Texture2D

# Leveling & Evolution (Phase 5b)
@export var max_level: int = 5
@export var damage_per_level: float = 0.0
@export var fire_rate_per_level: float = 0.0
@export var pellets_per_level: int = 0
@export var pierce_per_level: int = 0
@export var is_evolved: bool = false
@export var evolution_id: String = ""

# Phase 7 Archetypes
@export var bullet_lifetime: float = 1.6
@export var is_flame: bool = false
@export var is_bolt: bool = false
@export var bolt_stick_duration: float = 0.5
@export var is_grenade: bool = false
@export var explosion_radius: float = 125.0
@export var arc_height: float = 50.0
