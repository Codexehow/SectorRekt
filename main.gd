extends Node2D

@onready var player: Player = $Player
@onready var tilemap: TileMapLayer = get_node_or_null("Level/TileMapLayer") if has_node("Level/TileMapLayer") else get_node_or_null("TileMapLayer")

var enemy_scene: PackedScene = preload("res://basic_virus.tscn")
var ui_scene: PackedScene = preload("res://ui/hallucination_ui.tscn")
var h_ui: CanvasLayer
var status_ui: CanvasLayer

func _ready() -> void:
	# Connect player signals
	if player:
		if player.has_signal("hallucination_triggered"):
			player.hallucination_triggered.connect(_on_player_hallucination)
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
		if player.has_signal("player_won"):
			player.player_won.connect(_on_player_won)
	
	# Instance status UI
	status_ui = CanvasLayer.new()
	add_child(status_ui)
	
	# Instance UI
	if ui_scene:
		h_ui = ui_scene.instantiate() as CanvasLayer
		add_child(h_ui)
	
	if generator:
		generator.level_generated.connect(spawn_initial_enemies)
		generator.generate_level()
	else:
		call_deferred("spawn_initial_enemies")

@onready var generator: SectorGenerator = get_node_or_null("Level/SectorGenerator")

func spawn_initial_enemies() -> void:
	if not generator:
		push_error("Main: SectorGenerator not found!")
		return
		
	# Spawn enemies in random rooms
	for i in range(12):
		var enemy: Node2D = enemy_scene.instantiate()
		enemy.global_position = generator.get_random_spawn_position()
		# Avoid spawning on player
		if enemy.global_position.distance_to(player.global_position) < 200:
			enemy.global_position += Vector2(100, 100)
		add_child(enemy)

func _on_player_died() -> void:
	show_status("SYSTEM CORRUPTED - REBOOTING...")
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func _on_player_won() -> void:
	show_status("SECTOR PURIFIED - ADVANCING...")
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func show_status(text: String) -> void:
	for child in status_ui.get_children():
		child.queue_free()
	
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.add_theme_font_size_override("font_size", 48)
	status_ui.add_child(label)

func _on_player_hallucination(type: String) -> void:
	if h_ui:
		h_ui.trigger_hallucination(type)
