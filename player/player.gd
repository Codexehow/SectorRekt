extends CharacterBody2D
class_name Player

signal hallucination_triggered(type: String)

@export var speed: float = 200.0
@export var segment_count: int = 6
@export var segment_spacing: float = 24.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var segments: Array[Sprite2D] = []
var position_history: Array[Vector2] = []
var segment_texture: Texture2D = preload("res://assets/generated/worm_segment_frame_0.png")

func _ready() -> void:
	add_to_group("player")
	# Initialize segments
	for i in range(segment_count):
		var segment: Sprite2D = Sprite2D.new()
		segment.texture = segment_texture
		segment.scale = Vector2(0.5, 0.5) # Scale down if the original is too big
		get_parent().call_deferred("add_child", segment)
		segments.append(segment)
	
	# Initial position history
	for i in range(segment_count * 100):
		position_history.append(global_position)

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
		update_animation(direction)
		sprite.play()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		sprite.stop()

	move_and_slide()
	
	# Update history
	position_history.insert(0, global_position)
	if position_history.size() > segment_count * 100:
		position_history.pop_back()
	
	# Update segments
	for i in range(segments.size()):
		var target_index: int = int((i + 1) * segment_spacing / (speed * _delta)) # Approximation
		# Simpler approach: fixed index offset
		target_index = (i + 1) * 10 
		if target_index < position_history.size():
			segments[i].global_position = position_history[target_index]
			# Rotate segments to face the next one
			var prev_pos: Vector2 = position_history[target_index - 1] if target_index > 0 else global_position
			segments[i].rotation = (prev_pos - segments[i].global_position).angle() + PI/2

func update_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.animation = "walk_right"
		else:
			sprite.animation = "walk_left"
	else:
		if dir.y > 0:
			sprite.animation = "walk_down"
		else:
			sprite.animation = "walk_up"
