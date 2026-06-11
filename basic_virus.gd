extends CharacterBody2D

var player: CharacterBody2D
var speed: float = 100.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if player:
		var dir: Vector2 = global_position.direction_to(player.global_position)
		velocity = dir * speed
		move_and_slide()
