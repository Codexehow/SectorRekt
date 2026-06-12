extends Node2D
class_name TestShieldSystem

# Manual test script for shield and hull damage system

func _ready() -> void:
	await get_tree().process_frame  # Wait for scene to load
	
	print("\n" + "=".repeat(50))
	print("SHIELD & HULL DAMAGE SYSTEM TEST")
	print("=".repeat(50) + "\n")
	
	# Get the player
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("ERROR: Player not found!")
		return
	
	print("Initial State:")
	print("  Hull: %.1f/%.1f" % [player.current_hull, player.max_hull])
	print("  Shield: %.1f/%.1f" % [player.current_shield, player.max_shield])
	print("  Shield Regen Timer: %.2f\n" % player.shield_damage_timer)
	
	# Test 1: Shield absorption
	print("\n--- Test 1: Take 30 damage with shields active ---")
	player.take_damage(30.0, "test_attack")
	await get_tree().process_frame
	print("  After 30 damage:")
	print("  Hull: %.1f/%.1f" % [player.current_hull, player.max_hull])
	print("  Shield: %.1f/%.1f" % [player.current_shield, player.max_shield])
	
	# Test 2: Large damage that breaks shields and damages hull
	print("\n--- Test 2: Take 120 damage (shields should break, hull takes 20) ---")
	player.take_damage(120.0, "test_large_hit")
	await get_tree().process_frame
	print("  After 120 damage:")
	print("  Hull: %.1f/%.1f" % [player.current_hull, player.max_hull])
	print("  Shield: %.1f/%.1f" % [player.current_shield, player.max_shield])
	
	# Test 3: Damage with no shields (should go straight to hull)
	print("\n--- Test 3: Take 20 damage with shields at 0 (hull only) ---")
	player.take_damage(20.0, "test_hull_only")
	await get_tree().process_frame
	print("  After 20 damage:")
	print("  Hull: %.1f/%.1f" % [player.current_hull, player.max_hull])
	print("  Shield: %.1f/%.1f" % [player.current_shield, player.max_shield])
	
	# Test 4: Wait for shield regen
	print("\n--- Test 4: Shield regeneration (waiting %.1f seconds for regen delay) ---" % player.shield_regen_delay)
	var wait_time: float = 0.0
	while wait_time < player.shield_regen_delay + 1.0:
		await get_tree().process_frame
		wait_time += get_physics_process_delta_time()
		if int(wait_time) % 1 == 0 and wait_time != int(wait_time):
			print("  %.1f seconds elapsed... Shield: %.1f/%.1f" % [wait_time, player.current_shield, player.max_shield])
	
	print("  After waiting for regen:")
	print("  Hull: %.1f/%.1f" % [player.current_hull, player.max_hull])
	print("  Shield: %.1f/%.1f" % [player.current_shield, player.max_shield])
	
	print("\n" + "=".repeat(50))
	print("TEST COMPLETE")
	print("=".repeat(50) + "\n")
	
	queue_free()
