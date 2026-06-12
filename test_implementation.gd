extends Node2D
class_name TestImplementation

# Simple test to verify the Shield + Hull damage system implementation

func _ready() -> void:
	print("\n==================================================")
	print("SHIELD + HULL DAMAGE SYSTEM TEST")
	print("==================================================\n")
	
	# Get the player
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("ERROR: Player not found in scene!")
		return
	
	print("Player found")
	print("Initial Hull: %d/%d" % [int(player.current_hull), int(player.max_hull)])
	print("Initial Shield: %d/%d\n" % [int(player.current_shield), int(player.max_shield)])
	
	# Check ImpactGlimmer exists
	if player.has_node("ImpactGlimmer"):
		print("ImpactGlimmer node found in Player")
		var glimmer = player.get_node("ImpactGlimmer")
		print("Script: %s\n" % glimmer.get_script().resource_path)
	else:
		print("ERROR: ImpactGlimmer node NOT found!\n")
	
	# Test 1: Shield damage with glimmer
	print("--------------------------------------------------")
	print("TEST 1: Damage with shields (should show glimmer)")
	print("--------------------------------------------------")
	print("Taking 30 damage...")
	player.take_damage(30.0, "test")
	print("Result: Hull=%d Shield=%d\n" % [int(player.current_hull), int(player.current_shield)])
	
	# Test 2: Shield break damage
	print("--------------------------------------------------")
	print("TEST 2: Damage that breaks shields")
	print("--------------------------------------------------")
	print("Taking 120 damage...")
	player.take_damage(120.0, "test")
	print("Result: Hull=%d Shield=%d\n" % [int(player.current_hull), int(player.current_shield)])
	
	# Test 3: Hull-only damage (no glimmer)
	print("--------------------------------------------------")
	print("TEST 3: Damage with no shields (NO glimmer)")
	print("--------------------------------------------------")
	print("Taking 20 damage...")
	player.take_damage(20.0, "test")
	print("Result: Hull=%d Shield=%d\n" % [int(player.current_hull), int(player.current_shield)])
	
	print("==================================================")
	print("TEST COMPLETE - Check implementation")
	print("==================================================\n")
	
	queue_free()
