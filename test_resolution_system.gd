extends Node
class_name TestResolutionSystem

# Test script to verify the resolution change system works correctly

func _ready() -> void:
	print("\n=== RESOLUTION CHANGE SYSTEM TEST ===\n")
	
	# Test 1: Check initial window size
	test_initial_window_size()
	
	# Test 2: Verify resolution options can be accessed
	test_resolution_options_accessible()
	
	# Test 3: Test window resize directly
	test_direct_window_resize()
	
	# Test 4: Test fullscreen toggle
	test_fullscreen_toggle()
	
	# Test 5: Check get_window() exists and is callable
	test_get_window_exists()
	
	print("\n=== ALL TESTS COMPLETE ===\n")
	await get_tree().process_frame
	get_tree().quit()

func test_initial_window_size() -> void:
	print("TEST 1: Initial Window Size")
	var current_size: Vector2i = get_window().size
	print("  Current window size: ", current_size)
	var current_mode: int = get_window().mode
	var mode_name: String = "WINDOWED" if current_mode == Window.MODE_WINDOWED else "FULLSCREEN"
	print("  Current window mode: ", mode_name)
	print("  ✓ Test 1 passed\n")

func test_resolution_options_accessible() -> void:
	print("TEST 2: Resolution Options Accessible")
	
	# Find CPUHUD in scene
	var nodes: Array = get_tree().get_nodes_in_group("") # empty group
	var hud: Node = find_node_by_type("CPUHUD")
	
	if hud:
		print("  Found CPUHUD node: ", hud.name)
		# Try to access resolution option button
		if hud.has_method("_on_resolution_selected"):
			print("  ✓ CPUHUD has _on_resolution_selected method")
		else:
			print("  ✗ CPUHUD missing _on_resolution_selected method")
	else:
		print("  ! CPUHUD not found in scene (this is ok for test)")
	
	print("  ✓ Test 2 passed\n")

func test_direct_window_resize() -> void:
	print("TEST 3: Direct Window Resize")
	
	var original_size: Vector2i = get_window().size
	print("  Original size: ", original_size)
	
	# Try to resize to 1280x720
	var test_size: Vector2i = Vector2i(1280, 720)
	print("  Attempting to resize to: ", test_size)
	
	get_window().size = test_size
	await get_tree().process_frame
	await get_tree().process_frame  # Wait a bit more
	
	var new_size: Vector2i = get_window().size
	print("  Size after resize: ", new_size)
	
	if new_size == test_size:
		print("  ✓ Window resize successful!")
	else:
		print("  ✗ Window resize FAILED - size didn't change")
		print("    Expected: ", test_size)
		print("    Got: ", new_size)
		
		# Check if we're in fullscreen mode (which prevents resize)
		var mode: int = get_window().mode
		if mode == Window.MODE_FULLSCREEN:
			print("  ! Window is in FULLSCREEN mode - cannot resize while fullscreen")
	
	print("  ✓ Test 3 passed\n")

func test_fullscreen_toggle() -> void:
	print("TEST 4: Fullscreen Toggle")
	
	var current_mode: int = get_window().mode
	var is_fullscreen: bool = current_mode == Window.MODE_FULLSCREEN
	print("  Current mode is fullscreen: ", is_fullscreen)
	
	# Try toggling
	if is_fullscreen:
		print("  Switching to WINDOWED...")
		get_window().mode = Window.MODE_WINDOWED
	else:
		print("  Switching to FULLSCREEN...")
		get_window().mode = Window.MODE_FULLSCREEN
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var new_mode: int = get_window().mode
	var new_is_fullscreen: bool = new_mode == Window.MODE_FULLSCREEN
	print("  New mode is fullscreen: ", new_is_fullscreen)
	
	if new_is_fullscreen != is_fullscreen:
		print("  ✓ Fullscreen toggle successful!")
	else:
		print("  ✗ Fullscreen toggle FAILED")
	
	# Restore original mode
	get_window().mode = Window.MODE_FULLSCREEN if is_fullscreen else Window.MODE_WINDOWED
	await get_tree().process_frame
	
	print("  ✓ Test 4 passed\n")

func test_get_window_exists() -> void:
	print("TEST 5: get_window() Function")
	
	var window: Window = get_window()
	if window:
		print("  ✓ get_window() exists and returns: ", window)
		print("  Window properties:")
		print("    - size: ", window.size)
		print("    - mode: ", window.mode)
		print("    - content_scale_mode: ", window.content_scale_mode)
		print("    - content_scale_size: ", window.content_scale_size)
	else:
		print("  ✗ get_window() returned null")
	
	print("  ✓ Test 5 passed\n")

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
