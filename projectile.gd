extends Area2D

@export var speed: float = 600.0
@export var damage: float = 25.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Set rotation based on direction
	rotation = direction.angle()
	
	# Self-destruct after lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
	# Connect signals
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_on_hit()
	elif body is TileMapLayer:
		# Check if it's a destructible tile
		var tile_pos: Vector2i = body.local_to_map(body.to_local(global_position + direction * 4.0))
		var source_id: int = body.get_cell_source_id(tile_pos)
		
		# SOURCE_DESTRUCTIBLE is 3 based on SectorGenerator
		if source_id == 3:
			body.erase_cell(tile_pos)
			# Maybe add a small explosion/debris effect here
			print("Destroyed a wall segment!")
		
		_on_hit()
	elif body.name != "Player" and not body.is_in_group("player"):
		_on_hit()

func _on_hit() -> void:
	# Add impact particles or sound here
	# For now, just queue_free
	spawn_particles()
	
	# Trigger screenshake if player exists
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.apply_shake(4.0)
	
	queue_free()

func spawn_particles() -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color.CYAN
	
	# Auto-remove particles
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)
