extends CharacterBody2D

var speed: float = 120.0
var player: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player") as Node2D

func take_damage(amount: float) -> void:
	print("Virus took damage: ", amount)
	queue_free()

func _physics_process(_delta: float) -> void:
	if player:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		velocity = direction * speed
		look_at(player.global_position)
		move_and_slide()
