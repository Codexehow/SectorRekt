extends CharacterBody2D
class_name Player

# ==================== SECTORREKT PLAYER - TANK + CPU CYCLES ====================

# === TANK MOVEMENT ===
@export var base_speed: float = 90.0
@export var turn_speed: float = 1.2
@export var acceleration: float = 120.0

var current_speed: float = 60.0
var target_speed: float = 60.0
var shake_intensity: float = 0.0

# === CPU CYCLES SYSTEM ===
@export var max_cpu_cycles: float = 100.0
var current_cpu: float = 0.0
var cpu_generation_rate: float = 25.0   # per click

# Allocation percentages
const WEAPON_ALLOC: float = 0.50
const SHIELD_ALLOC: float = 0.30
const MOVEMENT_ALLOC: float = 0.10
const LIFE_SUPPORT_ALLOC: float = 0.10
const BLINK_ALLOC: float = 0.10

var weapon_charge: float = 0.0
var shield_charge: float = 0.0
var blink_charge: float = 0.0

# === HEALTH & SHIELDS ===
@export var max_hull: float = 100.0
@export var max_shield: float = 100.0
@export var shield_regen_delay: float = 10.0  # Seconds before shield starts regenerating
@export var shield_regen_rate: float = 1.0  # Points per second

var current_hull: float = 100.0
var current_shield: float = 100.0
var shield_damage_timer: float = 0.0  # Timer for shield regen delay

# === SHIELD BUFFER SYSTEM ===
# When shields are full, incoming CPU allocation goes to a buffer
# When shields drop below 10%, the buffer slowly recharges shields
var shield_buffer: float = 0.0
var shield_buffer_recharge_rate: float = 1.0  # Points per second when shields are low
var shield_low_threshold: float = 10.0  # Shield percentage threshold for buffer recharge

@export var is_corrupted: bool = false

signal hallucination_triggered(type: String)
signal cpu_updated(current: float, weapon: float, shield: float, blink: float)
signal player_damaged(hull: float, shield: float)
signal shield_buffer_updated(buffer: float)
signal player_died
signal player_won

func _ready() -> void:
	add_to_group("player")
	current_hull = max_hull
	current_shield = max_shield
	print("SectorRekt Player - Tank + CPU Cycles System Active")
	print("Shields + Hull System Initialized")

# === DAMAGE SYSTEM ===
func take_damage(amount: float, source: String = "unknown") -> void:
	"""
	Apply damage to the player.
	Shields absorb damage first, then hull.
	Emits player_damaged signal when damage is taken.
	Resets shield regen timer when damage is taken.
	"""
	if current_shield > 0:
		var shield_damage: float = min(amount, current_shield)
		current_shield -= shield_damage
		amount -= shield_damage
		print("Shield absorbed ", shield_damage, " damage from ", source)
		show_impact_glimmer()  # Show glimmer ONLY when shields are active
		shield_damage_timer = 0.0  # Reset shield regen timer on shield damage
	
	if amount > 0 and current_hull > 0:
		current_hull -= amount
		print("Hull took ", amount, " damage from ", source)
		shield_damage_timer = 0.0  # Reset shield regen timer on hull damage too
	
	player_damaged.emit(current_hull, current_shield)
	
	if current_hull <= 0:
		die()

func show_impact_glimmer() -> void:
	"""
	Trigger a sci-fi shield impact effect (cyan/blue glitchy flash).
	Only called when shields actively absorb damage.
	"""
	if has_node("ImpactGlimmer"):
		$ImpactGlimmer.trigger_glimmer()

func _process(delta: float) -> void:
	# Camera shake logic
	if shake_intensity > 0:
		$Camera2D.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = move_toward(shake_intensity, 0.0, delta * 20.0)
	else:
		$Camera2D.offset = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# === CPU CYCLE DECAY ===
	# CPU decays naturally over time when not being generated
	current_cpu = max(current_cpu - 15.0 * delta, 0.0)
	
	# === SYSTEM DRAIN WHEN CPU IS ZERO ===
	# When CPU reaches 0, all systems begin losing power rapidly
	if current_cpu <= 0:
		weapon_charge = max(weapon_charge - 30.0 * delta, 0.0)
		shield_charge = max(shield_charge - 30.0 * delta, 0.0)
		blink_charge = max(blink_charge - 30.0 * delta, 0.0)
		current_speed = max(current_speed - 50.0 * delta, 30.0)
	
	# === SHIELD BUFFER & REGENERATION ===
	# Shield buffer accumulates when shields are at max
	# When shields drop below threshold, buffer recharges shields slowly
	if current_shield >= max_shield:
		# Shields at max - accumulate CPU allocation into buffer
		shield_buffer = min(shield_buffer + current_cpu * SHIELD_ALLOC * delta * 2.5, 500.0)  # Large buffer
		shield_damage_timer = 0.0  # Reset regen timer since shields are full
	elif current_shield < shield_low_threshold and shield_buffer > 0:
		# Shields critically low - recharge from buffer
		var recharge_amount: float = shield_buffer_recharge_rate * delta
		var shield_healed: float = min(recharge_amount, shield_buffer)
		shield_buffer -= shield_healed
		current_shield = min(current_shield + shield_healed, max_shield)
		player_damaged.emit(current_hull, current_shield)  # Update UI
	else:
		# Standard shield regen with delay
		if current_shield < max_shield:
			shield_damage_timer += delta
			if shield_damage_timer >= shield_regen_delay:
				# Shields are regenerating
				current_shield = min(current_shield + shield_regen_rate * delta, max_shield)
				player_damaged.emit(current_hull, current_shield)  # Update UI
	
	# Distribute CPU to weapon and blink (shield handled above)
	if current_cpu > 0:
		weapon_charge = min(weapon_charge + current_cpu * WEAPON_ALLOC * delta * 2.5, 100.0)
		blink_charge = min(blink_charge + current_cpu * BLINK_ALLOC * delta * 2.5, 100.0)
	
	# === TANK MOVEMENT ===
	var turn_input: float = 0.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		turn_input += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		turn_input -= 1.0
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		target_speed = min(target_speed + acceleration * delta, base_speed * 2.0)
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		target_speed = max(target_speed - acceleration * delta, 30.0)
	
	# Speed presets
	if Input.is_key_pressed(KEY_1): target_speed = base_speed * 0.5
	if Input.is_key_pressed(KEY_2): target_speed = base_speed * 0.75
	if Input.is_key_pressed(KEY_3): target_speed = base_speed * 1.0
	if Input.is_key_pressed(KEY_4): target_speed = base_speed * 1.35
	if Input.is_key_pressed(KEY_5): target_speed = base_speed * 1.8
	
	current_speed = lerp(current_speed, target_speed, 6.0 * delta)
	
	rotation += turn_input * turn_speed * delta
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	velocity = direction * current_speed * (1.0 + MOVEMENT_ALLOC * (current_cpu / max_cpu_cycles))
	
	move_and_slide()
	
	# === WALL DAMAGE (sliding against walls) ===
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision: KinematicCollision2D = get_slide_collision(i)
			var collider: Node = collision.get_collider()
			# Check if colliding with tilemap or static walls
			if collider is TileMapLayer or (collider is StaticBody2D):
				take_damage(0.5 * delta, "wall")
	
	# Weapon aiming (Pivot only)
	$WeaponPivot.look_at(get_global_mouse_position())

	cpu_updated.emit(current_cpu, weapon_charge, shield_charge, blink_charge)
	shield_buffer_updated.emit(shield_buffer)

func _input(event: InputEvent) -> void:
	# CPU Generation on click (Q or Right Click)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		generate_cpu_cycles()
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		generate_cpu_cycles()
	
	# Primary Attack (Fire Thunderbolt)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if weapon_charge >= 30.0:
			fire_thunderbolt()
			weapon_charge -= 30.0
		else:
			print("Weapon not charged! (", int(weapon_charge), "%)")

	# Blink Drive
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		if blink_charge >= 100.0:
			blink_drive()
		else:
			print("Blink Drive not charged!")

	# Debug toggle
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		is_corrupted = not is_corrupted
		print("Player corrupted mode: ", is_corrupted)

func generate_cpu_cycles() -> void:
	# Generate CPU on click (Q or Right Mouse Button)
	current_cpu = min(current_cpu + cpu_generation_rate, max_cpu_cycles)
	print("CPU Generated! Current: ", int(current_cpu), " / ", int(max_cpu_cycles))

func fire_thunderbolt() -> void:
	var thunderbolt_scene: PackedScene = preload("res://projectile.tscn")
	var tb: Area2D = thunderbolt_scene.instantiate()
	
	var muzzle: Marker2D = $WeaponPivot/Muzzle
	tb.global_position = muzzle.global_position
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	if "direction" in tb:
		tb.direction = (mouse_pos - muzzle.global_position).normalized()
	
	get_parent().add_child(tb)
	print("THUNDERBOLT FIRED!")

func blink_drive() -> void:
	print("BLINK DRIVE ACTIVATED - Teleport forward!")
	var blink_distance: float = 150.0
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	global_position += direction * blink_distance
	blink_charge = 0.0

func trigger_hallucination(type: String = "glitch") -> void:
	hallucination_triggered.emit(type)

func apply_shake(intensity: float) -> void:
	shake_intensity = max(shake_intensity, intensity)

func _on_body_entered(body: Node2D) -> void:
	"""Handle collision damage from enemies."""
	if body.is_in_group("enemies"):
		take_damage(25.0, "enemy")
		apply_shake(5.0)  # Visual feedback
		print("Player hit by enemy!")

func die() -> void:
	player_died.emit()
	queue_free()

func win() -> void:
	player_won.emit()
