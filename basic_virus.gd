extends CharacterBody2D

var player: Player
@export var speed: float = 80.0
@export var health: float = 50.0
@export var damage: float = 10.0
@export var attack_cooldown: float = 1.0
var last_attack_time: float = 0.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player") as Player

func _physics_process(_delta: float) -> void:
	if player:
		var dir: Vector2 = global_position.direction_to(player.global_position)
		velocity = dir * speed
		move_and_slide()
		
		# Contact damage
		if global_position.distance_to(player.global_position) < 40.0:
			var current_time: float = Time.get_ticks_msec() / 1000.0
			if current_time - last_attack_time > attack_cooldown:
				player.take_damage(damage)
				last_attack_time = current_time

func take_damage(amount: float) -> void:
	health -= amount
	# Visual feedback
	modulate = Color.RED
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if health <= 0:
		die()

func die() -> void:
	# Add death effect if any
	queue_free()
