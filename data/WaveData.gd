class_name WaveData
extends Resource

@export var rules: Array[WaveRule] = []
@export var boss_data: EnemyData
@export var boss_interval: float = 120.0 # Every 2 minutes
@export var boss_start_second: float = 120.0
@export var spawn_distance_min: float = 800.0
@export var spawn_distance_max: float = 950.0
