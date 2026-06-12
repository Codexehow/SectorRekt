extends Node2D
class_name ConsequenceAuditTest

func _ready() -> void:
	print("\n========================================")
	print("CONSEQUENCE SYSTEM AUDIT")
	print("========================================\n")
	
	test_popup_instantiation()
	await get_tree().process_frame
	
	test_popup_structure()
	await get_tree().process_frame
	
	test_consequence_engine_setup()
	await get_tree().process_frame
	
	test_full_flow()
	await get_tree().process_frame
	
	print("\n========================================")
	print("AUDIT COMPLETE")
	print("========================================\n")
	
	get_tree().quit()

func test_popup_instantiation() -> void:
	print("[TEST 1] Testing ConsequencePopup instantiation...")
	
	var scene: PackedScene = preload("res://ui/consequence_popup.tscn")
	if scene == null:
		print("  ✗ Failed to preload scene")
		return
	
	var popup: Control = scene.instantiate()
	if popup == null:
		print("  ✗ Failed to instantiate popup")
		return
	
	if popup is ConsequencePopup:
		print("  ✓ Popup is ConsequencePopup class")
	else:
		print("  ✗ Popup is not ConsequencePopup (is: ", popup.get_class(), ")")
	
	popup.queue_free()

func test_popup_structure() -> void:
	print("\n[TEST 2] Testing ConsequencePopup structure...")
	
	var scene: PackedScene = preload("res://ui/consequence_popup.tscn")
	var popup: ConsequencePopup = scene.instantiate() as ConsequencePopup
	
	add_child(popup)
	
	await get_tree().process_frame
	
	print("  Process Mode: ", popup.process_mode, " (expected: ", Node.PROCESS_MODE_ALWAYS, ")")
	if popup.process_mode == Node.PROCESS_MODE_ALWAYS:
		print("  ✓ Popup has PROCESS_MODE_ALWAYS")
	else:
		print("  ✗ Popup does NOT have PROCESS_MODE_ALWAYS")
	
	print("  Mouse Filter: ", popup.mouse_filter, " (expected: ", Control.MOUSE_FILTER_STOP, ")")
	if popup.mouse_filter == Control.MOUSE_FILTER_STOP:
		print("  ✓ Popup has MOUSE_FILTER_STOP")
	else:
		print("  ✗ Popup does NOT have MOUSE_FILTER_STOP")
	
	if popup.movement_button:
		print("  ✓ Movement button created")
		if popup.movement_button.mouse_filter == Control.MOUSE_FILTER_STOP:
			print("    ✓ Movement button accepts input")
		else:
			print("    ✗ Movement button mouse_filter: ", popup.movement_button.mouse_filter)
	else:
		print("  ✗ Movement button is null")
	
	if popup.blink_button:
		print("  ✓ Blink button created")
		if popup.blink_button.mouse_filter == Control.MOUSE_FILTER_STOP:
			print("    ✓ Blink button accepts input")
		else:
			print("    ✗ Blink button mouse_filter: ", popup.blink_button.mouse_filter)
	else:
		print("  ✗ Blink button is null")
	
	popup.queue_free()

func test_consequence_engine_setup() -> void:
	print("\n[TEST 3] Testing ConsequenceEngine setup...")
	
	# Create mock player
	var player: Node2D = Node2D.new()
	player.add_to_group("player")
	add_child(player)
	
	# Add signals
	if not player.has_signal("overheat_critical"):
		player.add_user_signal("overheat_critical")
	if not player.has_signal("overheat_updated"):
		player.add_user_signal("overheat_updated")
	
	# Create CPU HUD
	var cpu_hud_scene: PackedScene = preload("res://ui/cpu_hud.tscn")
	var cpu_hud: Node = cpu_hud_scene.instantiate()
	add_child(cpu_hud)
	
	await get_tree().process_frame
	
	# Verify CPU HUD group
	if cpu_hud.is_in_group("cpuhud"):
		print("  ✓ CPU HUD in 'cpuhud' group")
	else:
		print("  ✗ CPU HUD NOT in 'cpuhud' group")
	
	# Create engine
	var engine: ConsequenceEngine = ConsequenceEngine.new()
	add_child(engine)
	
	await get_tree().process_frame
	
	if engine.player != null:
		print("  ✓ Engine found player")
	else:
		print("  ✗ Engine did NOT find player")
	
	if engine.cpu_hud != null:
		print("  ✓ Engine found CPU HUD")
	else:
		print("  ✗ Engine did NOT find CPU HUD")
	
	# Check signal connection
	var connections: Array = player.get_signal_connection_list("overheat_critical")
	if connections.size() > 0:
		print("  ✓ overheat_critical connected (", connections.size(), " connection(s))")
	else:
		print("  ✗ overheat_critical NOT connected")
	
	player.queue_free()
	cpu_hud.queue_free()
	engine.queue_free()

func test_full_flow() -> void:
	print("\n[TEST 4] Testing full consequence flow...")
	
	# Setup
	var player: Node2D = Node2D.new()
	player.add_to_group("player")
	add_child(player)
	
	if not player.has_signal("overheat_critical"):
		player.add_user_signal("overheat_critical")
	if not player.has_signal("overheat_updated"):
		player.add_user_signal("overheat_updated")
	
	var cpu_hud_scene: PackedScene = preload("res://ui/cpu_hud.tscn")
	var cpu_hud: Node = cpu_hud_scene.instantiate()
	add_child(cpu_hud)
	
	var engine: ConsequenceEngine = ConsequenceEngine.new()
	add_child(engine)
	
	await get_tree().process_frame
	
	# Initial state
	print("  Initial paused state: ", get_tree().paused)
	if not get_tree().paused:
		print("  ✓ Game not paused initially")
	else:
		print("  ✗ Game is paused (should not be)")
	
	if engine.consequence_popup == null:
		print("  ✓ No popup initially")
	else:
		print("  ✗ Popup exists when it shouldn't")
	
	# Trigger overheat
	print("\n  Triggering overheat_critical...")
	player.overheat_critical.emit()
	await get_tree().process_frame
	
	# Check pause
	print("  Paused state after signal: ", get_tree().paused)
	if get_tree().paused:
		print("  ✓ Game paused after overheat_critical")
	else:
		print("  ✗ Game NOT paused (should be)")
	
	# Check popup
	if engine.consequence_popup != null:
		print("  ✓ Popup created")
		if engine.consequence_popup is ConsequencePopup:
			print("  ✓ Popup is ConsequencePopup instance")
			if engine.consequence_popup.movement_button:
				print("  ✓ Popup has movement button")
			if engine.consequence_popup.blink_button:
				print("  ✓ Popup has blink button")
		else:
			print("  ✗ Popup is not ConsequencePopup")
	else:
		print("  ✗ Popup NOT created")
	
	# Simulate selection
	if engine.consequence_popup:
		print("\n  Simulating button click...")
		engine.consequence_popup.movement_button.pressed.emit()
		await get_tree().process_frame
		
		print("  Paused state after selection: ", get_tree().paused)
		if not get_tree().paused:
			print("  ✓ Game unpaused after selection")
		else:
			print("  ✗ Game still paused (should be unpaused)")
	
	player.queue_free()
	cpu_hud.queue_free()
	engine.queue_free()
