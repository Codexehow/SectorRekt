extends Node2D

@onready var player: Player = $Player
@onready var tilemap: TileMapLayer = $TileMapLayer

var enemy_scene: PackedScene = preload("res://basic_virus.tscn")
var ui_scene: PackedScene = preload("res://ui/hallucination_ui.tscn")
var h_ui: CanvasLayer

func _ready() -> void:
	# Connect player signal
	if player.has_signal("hallucination_triggered"):
		player.hallucination_triggered.connect(_on_player_hallucination)
	
	# Instance UI
	h_ui = ui_scene.instantiate() as CanvasLayer
	add_child(h_ui)
	
	# Spawn some enemies initially
	for i in range(5):
		spawn_enemy()
	
	# Set up a timer for more enemies
	var spawn_timer: Timer = Timer.new()
	spawn_timer.name = "EnemySpawner"
	spawn_timer.wait_time = 5.0
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(spawn_enemy)
	add_child(spawn_timer)

func spawn_enemy() -> void:
	var enemy: Node2D = enemy_scene.instantiate()
	# Random position around the player
	var angle: float = randf() * TAU
	var distance: float = randf_range(300, 600)
	enemy.global_position = player.global_position + Vector2.from_angle(angle) * distance
	add_child(enemy)

func _on_player_hallucination(type: String) -> void:
	if h_ui:
		h_ui.trigger_hallucination(type)
