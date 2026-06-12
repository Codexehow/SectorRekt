# TEST COMMENT
extends Node2D

class_name SectorGenerator

@export var tilemap_layer: TileMapLayer
@export var background_layer: TileMapLayer
@export var map_width: int = 100
@export var map_height: int = 100
@export var room_count: int = 15
@export var min_room_size: int = 10
@export var max_room_size: int = 20

const SOURCE_FLOOR = 0
const SOURCE_WALL = 1
const SOURCE_EXIT = 2
const SOURCE_DESTRUCTIBLE = 3
const SOURCE_BACKGROUND = 4

const TILE_COORD = Vector2i(0, 0)

signal level_generated

func _ready() -> void:
	# Add CRT Overlay if not present
	if not get_parent().has_node("CRTOverlay"):
		var crt_scene = load("res://crt_overlay.tscn")
		if crt_scene:
			var crt = crt_scene.instantiate()
			crt.name = "CRTOverlay"
			get_parent().add_child.call_deferred(crt)

var rooms: Array[Rect2i] = []

func generate_level() -> void:
	if not tilemap_layer:
		push_error("SectorGenerator: No TileMapLayer assigned!")
		return
		
	tilemap_layer.clear()
	rooms.clear()
	
	# Fill background
	var bg = background_layer if background_layer else get_parent().get_node_or_null("BackgroundLayer")
	if bg:
		bg.clear()
		for x in range(-20, map_width + 20):
			for y in range(-20, map_height + 20):
				bg.set_cell(Vector2i(x, y), SOURCE_BACKGROUND, TILE_COORD)
	else:
		for x in range(-10, map_width + 10):
			for y in range(-10, map_height + 10):
				tilemap_layer.set_cell(Vector2i(x, y), SOURCE_BACKGROUND, TILE_COORD)
	
	var attempts: int = 0
	var target_rooms: int = randi_range(room_count / 2, room_count)
	
	# 1. Generate Rooms
	while rooms.size() < target_rooms and attempts < 200:
		var w: int = randi_range(min_room_size, max_room_size)
		var h: int = randi_range(min_room_size, max_room_size)
		var x: int = randi_range(2, map_width - w - 2)
		var y: int = randi_range(2, map_height - h - 2)
		
		var new_room: Rect2i = Rect2i(x, y, w, h)
		var overlaps: bool = false
		for other in rooms:
			if new_room.grow(2).intersects(other):
				overlaps = true
				break
		
		if not overlaps:
			rooms.append(new_room)
			create_room(new_room)
		attempts += 1
	
	# 2. Connect Rooms (Branching & Loops)
	for i in range(rooms.size() - 1):
		var p1: Vector2i = rooms[i].get_center()
		var p2: Vector2i = rooms[i+1].get_center()
		create_corridor(p1, p2)
	
	for i in range(rooms.size()):
		if randf() < 0.3:
			var j: int = randi() % rooms.size()
			if i != j:
				create_corridor(rooms[i].get_center(), rooms[j].get_center())
	
	for i in range(4):
		var start_room: Rect2i = rooms[randi() % rooms.size()]
		var direction: Vector2i = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
		var length: int = randi_range(5, 15)
		var current: Vector2i = start_room.get_center()
		for j in range(length):
			set_corridor_tile(current)
			current += direction
			if current.x < 2 or current.x > map_width - 2 or current.y < 2 or current.y > map_height - 2:
				break

	# 3. Place Player and Exit
	if rooms.size() > 1:
		var player_pos: Vector2i = rooms[0].get_center()
		var player: Node2D = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = tilemap_layer.map_to_local(player_pos)
		
		var exit_room: Rect2i = rooms[rooms.size() - 1]
		var exit_pos: Vector2i = exit_room.get_center()
		tilemap_layer.set_cell(exit_pos, SOURCE_EXIT, TILE_COORD)
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0: continue
				tilemap_layer.set_cell(exit_pos + Vector2i(dx, dy), SOURCE_FLOOR, TILE_COORD)
	
	level_generated.emit()


func create_room(room: Rect2i) -> void:
	# Floor
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			tilemap_layer.set_cell(Vector2i(x, y), SOURCE_FLOOR, TILE_COORD)
	
	# Walls around the room
	for x in range(room.position.x - 1, room.end.x + 1):
		place_wall_if_empty(Vector2i(x, room.position.y - 1))
		place_wall_if_empty(Vector2i(x, room.end.y))
	for y in range(room.position.y - 1, room.end.y + 1):
		place_wall_if_empty(Vector2i(room.position.x - 1, y))
		place_wall_if_empty(Vector2i(room.end.x, y))

func create_corridor(start: Vector2i, end: Vector2i) -> void:
	var current: Vector2i = start
	
	# Move horizontally
	while current.x != end.x:
		set_corridor_tile(current)
		current.x += 1 if end.x > current.x else -1
	
	# Move vertically
	while current.y != end.y:
		set_corridor_tile(current)
		current.y += 1 if end.y > current.y else -1
	
	set_corridor_tile(current)

func set_corridor_tile(pos: Vector2i) -> void:
	# Make corridor 2x2 floor
	for dx in range(0, 2):
		for dy in range(0, 2):
			var p: Vector2i = pos + Vector2i(dx, dy)
			tilemap_layer.set_cell(p, SOURCE_FLOOR, TILE_COORD)
			
	# Surround with walls
	for dx in range(-1, 3):
		for dy in range(-1, 3):
			var p: Vector2i = pos + Vector2i(dx, dy)
			if tilemap_layer.get_cell_source_id(p) == -1:
				place_wall_if_empty(p)

func get_random_spawn_position() -> Vector2:
	if rooms.is_empty():
		return Vector2.ZERO
	
	var room: Rect2i = rooms[randi() % rooms.size()]
	var rx: int = randi_range(room.position.x, room.end.x - 1)
	var ry: int = randi_range(room.position.y, room.end.y - 1)
	return tilemap_layer.map_to_local(Vector2i(rx, ry))

func place_wall_if_empty(pos: Vector2i) -> void:
	if tilemap_layer.get_cell_source_id(pos) == -1:
		# Use destructible tiles sparingly for "glowing blue" cyberpunk bits
		if randf() < 0.1:
			tilemap_layer.set_cell(pos, SOURCE_DESTRUCTIBLE, TILE_COORD)
		else:
			tilemap_layer.set_cell(pos, SOURCE_WALL, TILE_COORD)
