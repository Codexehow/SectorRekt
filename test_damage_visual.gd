extends Node
class_name TestDamageVisual

"""
Quick visual test of the damage system.
Add this as an AutoLoad or run scene to see damage system in action.
"""

func _ready() -> void:
	print("\n" + "=".repeat(60))
	print("PLAYER DAMAGE SYSTEM - VISUAL TEST")
	print("=".repeat(60) + "\n")
	
	# Create a test player
	var player: Player = Player.new()
	
	# Initialize
	player.current_hull = 100.0
	player.current_shield = 100.0
	print("Initial State: Shield %.1f / Hull %.1f\n" % [player.current_shield, player.current_hull])
	
	# Test 1: Shield absorption
	print("--- TEST 1: Shield Absorption ---")
	print("Taking 30 damage (shield should absorb)")
	player.take_damage(30.0, "test_1")
	print("Result: Shield %.1f / Hull %.1f\n" % [player.current_shield, player.current_hull])
	
	# Test 2: Shield overflow
	print("--- TEST 2: Shield Overflow ---")
	print("Taking 50 damage (shield breaks, hull takes 20)")
	player.take_damage(50.0, "test_2")
	print("Result: Shield %.1f / Hull %.1f\n" % [player.current_shield, player.current_hull])
	
	# Test 3: No shield damage
	print("--- TEST 3: Direct Hull Damage ---")
	print("Taking 25 damage (no shield left)")
	player.take_damage(25.0, "test_3")
	print("Result: Shield %.1f / Hull %.1f\n" % [player.current_shield, player.current_hull])
	
	# Test 4: Multiple hits
	print("--- TEST 4: Multiple Hits ---")
	for i in range(1, 6):
		print("Hit %d: Taking 10 damage" % i)
		player.take_damage(10.0, "test_4")
		print("  → Shield %.1f / Hull %.1f" % [player.current_shield, player.current_hull])
	
	# Test 5: Lethal damage
	print("\n--- TEST 5: Player Death ---")
	print("Current: Shield %.1f / Hull %.1f" % [player.current_shield, player.current_hull])
	print("Taking 100 damage (should trigger death)")
	
	var death_triggered: bool = false
	player.player_died.connect(func(): 
		death_triggered = true
		print("  ✓ PLAYER DIED (signal emitted)")
	)
	
	player.take_damage(100.0, "test_5")
	print("Result: Shield %.1f / Hull %.1f" % [player.current_shield, player.current_hull])
	
	print("\n" + "=".repeat(60))
	if death_triggered:
		print("✓ ALL TESTS COMPLETED SUCCESSFULLY")
	else:
		print("✗ DEATH SIGNAL NOT TRIGGERED")
	print("=".repeat(60) + "\n")
	
	# Cleanup
	queue_free()
