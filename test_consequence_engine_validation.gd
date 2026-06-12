extends Node
class_name TestConsequenceEngineValidation

func _ready() -> void:
	test_movement_system_exists()
	test_movement_lockdown_consequence()
	test_blink_reset_consequence()
	test_overheat_critical_signal()
	test_movement_regeneration()
	test_consequence_popup_creation()

# Test 1: Movement system exists and initializes correctly
func test_movement_system_exists() -> void:
	print("\n--- TEST: Movement System Exists ---")
	
	var test_node: Node = Node.new()
	var player: Player = Player.new()
	player.add_to_group("player")
	test_node.add_child(player)
	get_tree().root.add_child(test_node)
	
	# Check movement system
	assert(player.max_movement == 100.0, "Movement max should be 100")
	assert(player.current_movement == 100.0, "Current movement should start at 100")
	assert(player.movement_regen_rate == 15.0, "Movement regen rate should be 15/sec")
	
	print("✓ Movement system initialized correctly")
	print("  - max_movement: %.1f" % player.max_movement)
	print("  - current_movement: %.1f" % player.current_movement)
	print("  - movement_regen_rate: %.1f" % player.movement_regen_rate)
	
	test_node.queue_free()

# Test 2: Movement Lockdown consequence works
func test_movement_lockdown_consequence() -> void:
	print("\n--- TEST: Movement Lockdown Consequence ---")
	
	var test_node: Node = Node.new()
	var player: Player = Player.new()
	player.add_to_group("player")
	test_node.add_child(player)
	get_tree().root.add_child(test_node)
	
	# Player starts with full movement
	assert(player.current_movement == 100.0, "Should start with full movement")
	
	# Apply consequence
	player.apply_movement_lockdown()
	
	# Movement should be locked
	assert(player.current_movement == 0.0, "Movement should be 0 after lockdown")
	print("✓ Movement Lockdown consequence applied successfully")
	print("  - Before: 100.0")
	print("  - After: %.1f" % player.current_movement)
	
	test_node.queue_free()

# Test 3: Blink Reset consequence works
func test_blink_reset_consequence() -> void:
	print("\n--- TEST: Blink Reset Consequence ---")
	
	var test_node: Node = Node.new()
	var player: Player = Player.new()
	player.add_to_group("player")
	test_node.add_child(player)
	get_tree().root.add_child(test_node)
	
	# Give player blink charge
	player.blink_charge = 100.0
	assert(player.blink_charge == 100.0, "Should have blink charge")
	
	# Apply consequence
	player.apply_blink_reset()
	
	# Blink should be reset
	assert(player.blink_charge == 0.0, "Blink charge should be 0 after reset")
	print("✓ Blink Reset consequence applied successfully")
	print("  - Before: 100.0")
	print("  - After: %.1f" % player.blink_charge)
	
	test_node.queue_free()

# Test 4: Overheat critical signal emits
func test_overheat_critical_signal() -> void:
	print("\n--- TEST: Overheat Critical Signal ---")
	
	var test_node: Node = Node.new()
	var player: Player = Player.new()
	player.add_to_group("player")
	test_node.add_child(player)
	get_tree().root.add_child(test_node)
	
	var signal_emitted: bool = false
	player.overheat_critical.connect(func(): signal_emitted = true)
	
	# Set overheat to max
	player.overheat = 100.0
	
	# Process physics frame
	player._physics_process(0.016)
	
	assert(signal_emitted, "overheat_critical signal should emit")
	print("✓ Overheat critical signal emits correctly")
	print("  - Signal emitted: ", signal_emitted)
	
	test_node.queue_free()

# Test 5: Movement regeneration works
func test_movement_regeneration() -> void:
	print("\n--- TEST: Movement Regeneration ---")
	
	var test_node: Node = Node.new()
	var player: Player = Player.new()
	player.add_to_group("player")
	test_node.add_child(player)
	get_tree().root.add_child(test_node)
	
	# Lock movement
	player.apply_movement_lockdown()
	assert(player.current_movement == 0.0, "Movement should be locked")
	
	# Process 1 second
	player._physics_process(1.0)
	
	# Should have regenerated
	var regenerated: float = player.current_movement
	assert(regenerated > 0.0, "Movement should regenerate")
	assert(regenerated < 100.0, "Regeneration should be gradual")
	
	print("✓ Movement regenerates correctly")
	print("  - Before: 0.0")
	print("  - After 1 sec: %.1f" % regenerated)
	print("  - Regen rate: %.1f/sec" % player.movement_regen_rate)
	
	test_node.queue_free()

# Test 6: Consequence popup can be created
func test_consequence_popup_creation() -> void:
	print("\n--- TEST: Consequence Popup Creation ---")
	
	var popup: ConsequencePopup = ConsequencePopup.new()
	var test_node: Node = Node.new()
	test_node.add_child(popup)
	get_tree().root.add_child(test_node)
	
	await get_tree().process_frame
	
	# Popup should create UI elements
	assert(popup.get_child_count() > 0, "Popup should create UI elements")
	print("✓ Consequence Popup created successfully")
	print("  - Child count: %d" % popup.get_child_count())
	print("  - Has dark overlay: ", popup.dark_overlay != null)
	print("  - Has movement button: ", popup.movement_button != null)
	print("  - Has blink button: ", popup.blink_button != null)
	
	test_node.queue_free()

# Test 7: Consequence Engine integration
func test_consequence_engine_integration() -> void:
	print("\n--- TEST: Consequence Engine Integration ---")
	
	var test_node: Node = Node.new()
	
	# Create player
	var player: Player = Player.new()
	player.add_to_group("player")
	test_node.add_child(player)
	
	# Create consequence engine
	var engine: ConsequenceEngine = ConsequenceEngine.new()
	test_node.add_child(engine)
	
	get_tree().root.add_child(test_node)
	await get_tree().process_frame
	
	# Engine should find player
	assert(engine.player == player, "Engine should find player")
	assert(!engine.handling_consequence, "Should not be handling consequence initially")
	
	print("✓ Consequence Engine integrates correctly")
	print("  - Found player: ", engine.player != null)
	print("  - Handling consequence: ", engine.handling_consequence)
	
	test_node.queue_free()

# Test 8: Full consequence flow
func test_full_consequence_flow() -> void:
	print("\n--- TEST: Full Consequence Flow ---")
	
	var test_node: Node = Node.new()
	
	# Setup player and engine
	var player: Player = Player.new()
	player.add_to_group("player")
	test_node.add_child(player)
	
	var engine: ConsequenceEngine = ConsequenceEngine.new()
	test_node.add_child(engine)
	
	get_tree().root.add_child(test_node)
	await get_tree().process_frame
	
	# Start with clean state
	assert(player.overheat == 0.0, "Should start with 0 overheat")
	assert(player.current_movement == 100.0, "Should start with full movement")
	
	# Trigger overheat critical
	engine._on_overheat_critical()
	assert(get_tree().paused, "Game should pause")
	
	# Choose consequence
	engine._on_consequence_selected("movement_lockdown")
	assert(!get_tree().paused, "Game should unpause")
	assert(player.current_movement == 0.0, "Movement should be locked")
	assert(player.overheat == 0.0, "Overheat should reset")
	
	print("✓ Full consequence flow works correctly")
	print("  - Game paused: true")
	print("  - Consequence applied: movement_lockdown")
	print("  - Game unpaused: true")
	print("  - Movement after: %.1f" % player.current_movement)
	print("  - Overheat after: %.1f" % player.overheat)
	
	# Cleanup: unpause if still paused
	get_tree().paused = false
	test_node.queue_free()

# Test 9: Movement affects velocity
func test_movement_affects_velocity() -> void:
	print("\n--- TEST: Movement Affects Velocity ---")
	
	var test_node: Node = Node.new()
	var player: Player = Player.new()
	player.add_to_group("player")
	test_node.add_child(player)
	get_tree().root.add_child(test_node)
	
	player.current_speed = 100.0
	player.rotation = 0
	
	# Full movement
	player.current_movement = 100.0
	player._physics_process(0.016)
	var full_velocity: Vector2 = player.velocity
	
	# Half movement
	player.current_movement = 50.0
	player._physics_process(0.016)
	var half_velocity: Vector2 = player.velocity
	
	# Full should be faster than half
	assert(full_velocity.length() > half_velocity.length(),
		"Full movement should allow faster velocity")
	
	print("✓ Movement multiplier affects velocity")
	print("  - Full movement velocity: %.1f" % full_velocity.length())
	print("  - Half movement velocity: %.1f" % half_velocity.length())
	
	test_node.queue_free()
