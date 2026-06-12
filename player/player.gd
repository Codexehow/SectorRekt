extends CharacterBody2D
class_name Player

signal hallucination_triggered(type: String)
signal player_died
signal player_won

@export var max_health: float = 100.0
@export var health: float = 100.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 0.4

@export var speed: float = 150.0
@export var segment_count: int = 12
@export var is_corrupted: bool = false:
	set(value):
		is_corrupted = value
		update_visual_mode()

@export var projectile_scene: PackedScene = preload("res://projectile.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

var segments: Array[Sprite2D] = []
var position_history: Array[Vector2] = []

# Corrupted mode texture
var segment_texture_corrupted: Texture2D = preload("res://assets/generated/worm_segment_frame_0.png")

var last_attack_time: float = -1.0
var shake_intensity: float = 0.0
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	add_to_group("player")
	
	# Initialize segments for Corrupted mode
	# We create them anyway but keep them hidden in baseline
	for i in range(segment_count):
		var segment: Sprite2D = Sprite2D.new()
		segment.texture = segment_texture_corrupted
		segment.scale = Vector2(0.6, 0.6)
		segment.modulate = Color(1.5, 0.5, 0.5)
		segment.visible = false
		# Add to parent to follow global positions but not local transform
		get_parent().call_deferred("add_child", segment)
		segments.append(segment)
	
	# Initial position history for segments
	for i in range(segment_count * 20):
		position_history.append(global_position)
	
	update_visual_mode()

func update_visual_mode() -> void:
	if not is_inside_tree(): return
	
	apply_shake(3.0)
	
	# Toggle segments visibility
	for segment in segments:
		segment.visible = is_corrupted
			
	if is_corrupted:
		sprite.modulate = Color(1.5, 0.5, 0.5)
		sprite.speed_scale = 1.0 # Fluid corrupted animation
	else:
		sprite.modulate = Color.WHITE
		sprite.speed_scale = 0.5 # Clunky/Mechanical baseline crawl speed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		attack()
	
	if Input.is_key_pressed(KEY_H):
		hallucination_triggered.emit("glitch")
	
	# G key to toggle corruption
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		is_corrupted = !is_corrupted
		print("Player corrupted state: ", is_corrupted)

func _physics_process(delta: float) -> void:
	# Screen shake
	if shake_intensity > 0:
		camera.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = move_toward(shake_intensity, 0.0, delta * 20.0)
	else:
		camera.offset = Vector2.ZERO

	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		if not is_corrupted:
			# Clunky/Heavy movement feel
			velocity = velocity.move_toward(direction * speed, speed * delta * 3.0)
		else:
			# Fast/Fluid/Glitchy movement
			velocity = direction * speed * 1.5
			
		last_direction = direction
		update_animation(direction)
		sprite.play()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 10.0)
		update_animation(Vector2.ZERO)
		sprite.stop()

	move_and_slide()
	
	# Only process segment logic if corrupted
	if is_corrupted:
		position_history.insert(0, global_position)
		if position_history.size() > segment_count * 20:
			position_history.pop_back()
			
		for i in range(segments.size()):
			var offset_factor: int = 8
			var target_index: int = (i + 1) * offset_factor 
			
			if target_index < position_history.size():
				var target_pos: Vector2 = position_history[target_index]
				# Glitchy/Jittery segments
				segments[i].global_position = target_pos + (Vector2(randf(), randf()) * 2.0 if randf() > 0.9 else Vector2.ZERO)
				segments[i].visible = true
					
				var prev_pos: Vector2 = position_history[target_index - 1] if target_index > 0 else global_position
				segments[i].rotation = (prev_pos - segments[i].global_position).angle() + PI/2.0
	else:
		# Ensure segments are hidden
		for segment in segments:
			if segment.visible: segment.visible = false

func attack() -> void:
	var current_time: float = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time < attack_cooldown:
		return
	
	last_attack_time = current_time
	
	if projectile_scene:
		var projectile: Area2D = projectile_scene.instantiate()
		var target_pos: Vector2 = get_global_mouse_position()
		var attack_dir: Vector2 = global_position.direction_to(target_pos)
		
		projectile.global_position = global_position + attack_dir * 20.0
		projectile.direction = attack_dir
		get_parent().add_child(projectile)
		
		apply_shake(2.0)
		print("Player shoots!")
	
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)

func apply_shake(intensity: float) -> void:
	shake_intensity = intensity

func take_damage(amount: float) -> void:
	health -= amount
	sprite.modulate = Color.RED
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE if not is_corrupted else Color(1.5, 0.5, 0.5), 0.2)
	
	if health <= 0:
		die()

func die() -> void:
	player_died.emit()
	get_tree().reload_current_scene()

func win_game() -> void:
	player_won.emit()

func update_animation(dir: Vector2) -> void:
	var anim_prefix = "corrupted_" if is_corrupted else ""
	var anim_name = ""
	
	if dir == Vector2.ZERO:
		anim_name = "idle_"
		if abs(last_direction.x) > abs(last_direction.y):
			anim_name += "right" if last_direction.x > 0 else "left"
		else:
			anim_name += "down" if last_direction.y > 0 else "up"
	else:
		anim_name = "walk_"
		if abs(dir.x) > abs(dir.y):
			anim_name += "right" if dir.x > 0 else "left"
		else:
			anim_name += "down" if dir.y > 0 else "up"
	
	if sprite.animation != anim_prefix + anim_name:
		sprite.animation = anim_prefix + anim_name
