class_name GameFeelData
extends Resource

@export_group("Screen Shake")
@export var screen_shake_strength: float = 14.0
@export var screen_shake_duration: float = 0.25

@export_group("Zombie Hit Flash")
@export var hit_flash_duration: float = 0.09
@export var hit_flash_color: Color = Color(3.0, 3.0, 3.0, 1.0)

@export_group("Zombie Death Particles")
@export var death_particle_count: int = 18
@export var death_particle_lifetime: float = 0.4
@export var death_particle_speed: float = 160.0
@export var death_particle_texture: Texture2D

@export_group("Floating Damage Numbers")
@export var damage_number_lifetime: float = 0.65
@export var damage_number_float_speed: float = 75.0
@export var damage_number_color: Color = Color(1.0, 0.95, 0.35, 1.0)

@export_group("Airdrop Landing Dust")
@export var landing_dust_count: int = 14
@export var landing_dust_lifetime: float = 0.45
@export var landing_dust_speed: float = 120.0
@export var landing_dust_texture: Texture2D

@export_group("Audio Settings")
@export var music_volume_db: float = -6.0
@export var sfx_volume_db: float = 0.0
