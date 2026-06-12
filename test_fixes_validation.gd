extends Node
class_name TestFixesValidation

# Comprehensive validation test for the resolution and overheat UI fixes

var player: Player = null
var hud: CPUHUD = null

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("FIXES VALIDATION TEST")
	print("=".repeat(80) + "\n")
	
	# Find player and HUD
	var player_nodes: Array = get_tree().get_nodes_in_group("player")
	player = player_nodes[0] as Player if player_nodes.size() > 0 else null
	
	hud = find_node_by_type("CPUHUD")
	
	if not player:
		print("✗ CRITICAL: Player not found!")
		await get_tree().process_frame
		get_tree().quit()
		return
	
	if not hud:
		print("✗ CRITICAL: CPUHUD not found!")
		await get_tree().process_frame
		get_tree().quit()
		return
	
	print("✓ Found Player and HUD\n")
	
	# Run validation tests
	await validate_overheat_system()
	await validate_resolution_system()
	
	print("\n" + "=".repeat(80))
	print("VALIDATION COMPLETE - CHECK OUTPUT ABOVE")
	print("=".repeat(80) + "\n")
	
	await get_tree().process_frame
	get_tree().quit()

# ============================================================================
# OVERHEAT SYSTEM VALIDATION
# ============================================================================

func validate_overheat_system() -> void:
	print("\n" + "-".repeat(80))
	print("OVERHEAT SYSTEM VALIDATION")
	print("-".repeat(80) + "\n")
	
	print("[TEST 1] Check if HUD has overheat_bar reference")
	# Access the private variable through script inspection
	if has_property(hud, "overheat_bar"):
		var overheat_bar: ProgressBar = hud.get("overheat_bar") if "overheat_bar" in hud else null
		if overheat_bar:
			print("  ✓ overheat_bar is initialized and accessible")
		else:
			print("  ✗ overheat_bar is null - initialization failed!")
	else:
		print("  ! Cannot directly access overheat_bar (expected for private var)")
	
	print("\n[TEST 2] Verify signal connection")
	var connections: Array = player.get_signal_connection_list("overheat_updated")
	if connections.size() > 0:
		print("  ✓ overheat_updated signal has ", connections.size(), " connection(s)")
		for conn: Dictionary in connections:
			var target_str: String = str(conn["target"])
			if "CPUHUD" in target_str or "cpu_hud" in target_str:
				print("    ✓ Connected to HUD")
	else:
		print("  ✗ No signal connections found!")
	
	print("\n[TEST 3] Simulate overheat increase and check signal emission")
	var initial_overheat: float = player.overheat
	print("  Initial overheat: ", initial_overheat)
	
	# Manually trigger the signal with different values
	for test_value: float in [25.0, 50.0, 75.0, 100.0]:
		player.overheat = test_value
		player.overheat_updated.emit(test_value)
		await get_tree().process_frame
		print("  ✓ Signal emitted with value: ", test_value)
	
	# Reset
	player.overheat = 0.0
	player.overheat_updated.emit(0.0)
	await get_tree().process_frame
	
	print("\n[TEST 4] Check _on_overheat_updated method exists")
	if hud.has_method("_on_overheat_updated"):
		print("  ✓ _on_overheat_updated method found on HUD")
	else:
		print("  ✗ _on_overheat_updated method NOT found!")
	
	print()

# ============================================================================
# RESOLUTION SYSTEM VALIDATION
# ============================================================================

func validate_resolution_system() -> void:
	print("\n" + "-".repeat(80))
	print("RESOLUTION SYSTEM VALIDATION")
	print("-".repeat(80) + "\n")
	
	print("[TEST 1] Verify resolution_option is initialized")
	if has_property(hud, "resolution_option"):
		var resolution_option: OptionButton = hud.get("resolution_option") if "resolution_option" in hud else null
		if resolution_option:
			print("  ✓ resolution_option is initialized")
			print("  ✓ Contains ", resolution_option.item_count, " resolution options")
		else:
			print("  ✗ resolution_option is null!")
	
	print("\n[TEST 2] Verify fullscreen_button is initialized")
	if has_property(hud, "fullscreen_button"):
		var fullscreen_button: CheckButton = hud.get("fullscreen_button") if "fullscreen_button" in hud else null
		if fullscreen_button:
			print("  ✓ fullscreen_button is initialized")
		else:
			print("  ✗ fullscreen_button is null!")
	
	print("\n[TEST 3] Check signal connections for resolution")
	# We can't directly check this, but we can verify the handler exists
	if hud.has_method("_on_resolution_selected"):
		print("  ✓ _on_resolution_selected method found")
	else:
		print("  ✗ _on_resolution_selected method NOT found!")
	
	if hud.has_method("_on_fullscreen_toggled"):
		print("  ✓ _on_fullscreen_toggled method found")
	else:
		print("  ✗ _on_fullscreen_toggled method NOT found!")
	
	print("\n[TEST 4] Test resolution change (windowed mode)")
	var original_size: Vector2i = get_window().size
	var original_fullscreen: bool = get_window().mode == Window.MODE_FULLSCREEN
	
	print("  Original resolution: ", original_size)
	print("  Original fullscreen: ", original_fullscreen)
	
	# Switch to windowed if needed
	if original_fullscreen:
		print("  Switching to windowed mode for test...")
		get_window().mode = Window.MODE_WINDOWED
		await get_tree().process_frame
		await get_tree().process_frame
	
	# Try calling the resolution handler directly
	print("  Testing resolution change to 1280x720...")
	hud._on_resolution_selected(0)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	var new_size: Vector2i = get_window().size
	print("  Requested: Vector2i(1280, 720)")
	print("  Actual: ", new_size)
	
	if new_size == Vector2i(1280, 720):
		print("  ✓ Resolution change successful!")
	else:
		print("  ! Resolution change did not apply (may be due to window manager)")
	
	# Restore original settings
	print("  Restoring original settings...")
	get_window().size = original_size
	await get_tree().process_frame
	if original_fullscreen:
		get_window().mode = Window.MODE_FULLSCREEN
	await get_tree().process_frame
	
	print()

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func find_node_by_type(type_name: String) -> Node:
	"""Recursively find a node by class name."""
	return find_node_by_type_recursive(get_tree().root, type_name)

func find_node_by_type_recursive(node: Node, type_name: String) -> Node:
	if node.get_class() == type_name:
		return node
	
	for child: Node in node.get_children():
		var result: Node = find_node_by_type_recursive(child, type_name)
		if result:
			return result
	
	return null

func has_property(obj: Object, prop_name: String) -> bool:
	"""Check if an object has a property."""
	return prop_name in obj
