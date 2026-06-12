extends CharacterBody2D
class_name Player

# ==================== SECTORREKT PLAYER - TANK CONTROLS ====================
# Always moving forward. A/D = slow turn. W/S = speed control. 1-5 = presets.
# Mouse aims primary attack.

@export var base_speed: float = 90.0      # Reduced for clunkier feel
@export var turn_speed: float = 1.2       # Slower turning (more tank-like)
@export var acceleration: float = 120.0   # Slower speed changes
@export var friction: float = 120.0

var current_speed: float = 60.0           # Starts quite slow and heavy
var target_speed: float = 60.0
var shake_intensity: float = 0.0

@export var is_corrupted: bool = false    # Toggle with G key

# Signals
signal hallucination_triggered(type: String)
signal player_died
signal player_won

func _ready() -> void:
	add_to_group("player")
	print("SectorRekt Player - Tank Controls Initialized (Clunky Baseline)")

func _process(delta: float) -> void:
	# Camera shake logic
	if shake_intensity > 0:
		$Camera2D.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = move_toward(shake_intensity, 0.0, delta * 20.0)
	else:
		$Camera2D.offset = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# === INPUT ===
	var turn_input: float = 0.0
	
	# Using keys directly since actions might not be defined in Input Map
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		turn_input += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		turn_input -= 1.0
	
	# W/S speed control
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		target_speed = min(target_speed + acceleration * delta, base_speed * 2.0)
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		target_speed = max(target_speed - acceleration * delta, 30.0)
	
	# Number keys for speed presets (1 slowest → 5 fastest)
	if Input.is_key_pressed(KEY_1): target_speed = base_speed * 0.5
	if Input.is_key_pressed(KEY_2): target_speed = base_speed * 0.75
	if Input.is_key_pressed(KEY_3): target_speed = base_speed * 1.0
	if Input.is_key_pressed(KEY_4): target_speed = base_speed * 1.35
	if Input.is_key_pressed(KEY_5): target_speed = base_speed * 1.8
	
	# Smooth speed lerp (keeps it feeling mechanical)
	current_speed = lerp(current_speed, target_speed, 6.0 * delta)
	
	# === TURNING ===
	rotation += turn_input * turn_speed * delta
	
	# === MOVEMENT - Always moving forward ===
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	velocity = direction * current_speed
	
	move_and_slide()
	
	# === ATTACK AIMING (Mouse) ===
	$WeaponPivot.look_at(get_global_mouse_position())

func _input(event: InputEvent) -> void:
	# Primary Attack (Thunderbolt) - Mouse click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		fire_thunderbolt()
	
	# Debug toggle corrupted mode
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		is_corrupted = not is_corrupted
		print("Player corrupted mode: ", is_corrupted)

func fire_thunderbolt() -> void:
	var thunderbolt_scene: PackedScene = preload("res://projectile.tscn")
	var tb: Area2D = thunderbolt_scene.instantiate()
	
	var muzzle: Marker2D = $WeaponPivot/Muzzle
	tb.global_position = muzzle.global_position
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	# Set the direction - ensure projectile.gd has a 'direction' property
	if "direction" in tb:
		tb.direction = (mouse_pos - muzzle.global_position).normalized()
	
	get_parent().add_child(tb)
	print("Thunderbolt fired toward mouse!")

func apply_shake(intensity: float) -> void:
	shake_intensity = max(shake_intensity, intensity)

# Hallucination trigger
func trigger_hallucination(type: String = "glitch") -> void:
	hallucination_triggered.emit(type)

func die() -> void:
	player_died.emit()
	queue_free()

func win() -> void:
	player_won.emit()
