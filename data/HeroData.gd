class_name HeroData
extends Resource

@export var id: String = "luka"
@export var name: String = "Luka the Lanternkeeper"
@export var title: String = "Lanternkeeper"
@export var hp: float = 120.0
@export var speed: float = 200.0
@export var starting_weapon: WeaponData
@export var passive_description: String = "+40% Torch Radius & +20 Max HP"
@export var passive_type: String = "torch_bonus" # torch_bonus, speed_bonus, damage_bonus
@export var passive_value: float = 0.40
@export var sprite: Texture2D

# Unlock condition (Part A)
@export var unlock_type: String = "none" # "none", "runs", "boss_kills"
@export var unlock_requirement: int = 0
@export var unlock_description: String = ""
