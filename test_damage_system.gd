extends Node2D
class_name TestDamageSystem

# Test the Shield + Hull damage system

func _ready() -> void:
	print("\n=== DAMAGE SYSTEM TEST ===\n")
	
	# Get the player
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("ERROR: Player not found!")
		return
	
	print("Initial State:")
	print("  Hull: %d/%d" % [int(player.current_hull), int(player.max_hull)])
	print("  Shield: %d/%d" % [int(player.current_shield), int(player.max_shield)])
	
	# Test 1: Damage with shields active
	print("\n--- Test 1: Take 30 damage with shields active ---")
	player.take_damage(30.0, "test_wall")
	print("  After 30 damage:")
	print("  Hull: %d/%d" % [int(player.current_hull), int(player.max_hull)])
	print("  Shield: %d/%d" % [int(player.current_shield), int(player.max_shield)])
	
	# Test 2: Large damage that breaks shields and damages hull
	print("\n--- Test 2: Take 120 damage (shields should break, hull takes 20) ---")
	player.take_damage(120.0, "test_large_hit")
	print("  After 120 damage:")
	print("  Hull: %d/%d" % [int(player.current_hull), int(player.max_hull)])
	print("  Shield: %d/%d" % [int(player.current_shield), int(player.max_shield)])
	
	# Test 3: Damage with no shields
	print("\n--- Test 3: Take 20 damage with shields at 0 (hull only) ---")
	player.take_damage(20.0, "test_hull_only")
	print("  After 20 damage:")
	print("  Hull: %d/%d" % [int(player.current_hull), int(player.max_hull)])
	print("  Shield: %d/%d" % [int(player.current_shield), int(player.max_shield)])
	
	print("\n=== TEST COMPLETE ===\n")
	queue_free()
