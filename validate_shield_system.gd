extends Node2D
class_name ValidateShieldSystem

# Comprehensive validation script for the shield and hull damage system
# This script tests all aspects of the damage system

func _ready() -> void:
	await get_tree().process_frame  # Wait for scene to load
	
	print("\n" + "=".repeat(70))
	print("SHIELD & HULL SYSTEM VALIDATION TEST")
	print("=".repeat(70))
	
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("❌ ERROR: Player not found!")
		queue_free()
		return
	
	print("\n✓ Player found")
	
	# Validation 1: Shield system properties exist
	print("\n--- VALIDATION 1: Shield System Properties ---")
	if player.has_property("max_shield"):
		print("✓ max_shield: %.1f" % player.max_shield)
	else:
		print("❌ max_shield property missing!")
	
	if player.has_property("current_shield"):
		print("✓ current_shield: %.1f" % player.current_shield)
	else:
		print("❌ current_shield property missing!")
	
	if player.has_property("shield_regen_delay"):
		print("✓ shield_regen_delay: %.1f seconds" % player.shield_regen_delay)
	else:
		print("❌ shield_regen_delay property missing!")
	
	if player.has_property("shield_regen_rate"):
		print("✓ shield_regen_rate: %.1f points/sec" % player.shield_regen_rate)
	else:
		print("❌ shield_regen_rate property missing!")
	
	# Validation 2: Hull system properties exist
	print("\n--- VALIDATION 2: Hull System Properties ---")
	if player.has_property("max_hull"):
		print("✓ max_hull: %.1f" % player.max_hull)
	else:
		print("❌ max_hull property missing!")
	
	if player.has_property("current_hull"):
		print("✓ current_hull: %.1f" % player.current_hull)
	else:
		print("❌ current_hull property missing!")
	
	# Validation 3: Test shield absorption
	print("\n--- VALIDATION 3: Shield Absorption Test ---")
	var initial_shield: float = player.current_shield
	var initial_hull: float = player.current_hull
	
	player.take_damage(30.0, "test")
	await get_tree().process_frame
	
	if player.current_shield < initial_shield:
		print("✓ Shield decreased: %.1f → %.1f" % [initial_shield, player.current_shield])
	else:
		print("❌ Shield did not decrease!")
	
	if player.current_hull == initial_hull:
		print("✓ Hull unchanged (shields absorbed all damage)")
	else:
		print("❌ Hull changed when shields were active!")
	
	# Validation 4: Test hull damage when shields are gone
	print("\n--- VALIDATION 4: Hull Damage (No Shields) Test ---")
	# Drain shields completely
	player.take_damage(500.0, "test_drain")
	await get_tree().process_frame
	
	initial_hull = player.current_hull
	player.take_damage(20.0, "test_hull")
	await get_tree().process_frame
	
	if player.current_hull < initial_hull:
		print("✓ Hull decreased: %.1f → %.1f" % [initial_hull, player.current_hull])
	else:
		print("❌ Hull did not decrease!")
	
	if player.current_shield <= 0:
		print("✓ Shields were depleted (%.1f)" % player.current_shield)
	else:
		print("❌ Shields not depleted!")
	
	# Validation 5: Test game over when hull reaches 0
	print("\n--- VALIDATION 5: Game Over Test ---")
	var player_died_triggered: bool = false
	player.player_died.connect(func(): player_died_triggered = true)
	
	var remaining_hull: float = player.current_hull
	player.take_damage(remaining_hull + 10.0, "test_death")
	await get_tree().process_frame
	
	if player.current_hull <= 0:
		print("✓ Hull reached 0: %.1f" % player.current_hull)
	else:
		print("❌ Hull did not reach 0!")
	
	if player_died_triggered:
		print("✓ Player died signal was triggered")
	else:
		print("❌ Player died signal NOT triggered!")
	
	# Note: Player will be freed after die(), so stop testing
	print("\n--- TEST INTERRUPTED (Player died) ---")
	
	print("\n" + "=".repeat(70))
	print("VALIDATION COMPLETE")
	print("=".repeat(70) + "\n")
	
	queue_free()

func has_property(prop: String) -> bool:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	return player and (prop in player)
