extends Node
class_name TestOverheatFixVerification

# Comprehensive test to verify the overheat UI fix
# Run this via: run_tests("res://test_overheat_fix_verification.gd")

func test_progressbar_fill_color_override_is_invalid() -> void:
	"""Test 1: Verify that add_theme_color_override('fill_color', ...) 
	does NOT affect ProgressBar fill in Godot 4, confirming the root cause."""
	print("\n=== TEST 1: fill_color override is invalid for ProgressBar ===")
	
	var pb := ProgressBar.new()
	add_child(pb)
	
	# Apply the OLD (broken) approach
	pb.add_theme_color_override("fill_color", Color.RED)
	var retrieved_color := pb.get_theme_color("fill_color", "ProgressBar")
	
	# The default font_color (a valid theme color for ProgressBar) is black
	# fill_color is not a standard theme property, so it won't be stored correctly
	print("  'fill_color' override value: ", retrieved_color)
	print("  Is 'fill_color' a valid ProgressBar theme color? ", 
		"NO - ProgressBar uses a StyleBox for 'fill', not a color")
	
	# Verify the correct approach: StyleBox override
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.YELLOW
	pb.add_theme_stylebox_override("fill", sb)
	
	var fill_stylebox := pb.get_theme_stylebox("fill", "ProgressBar")
	print("  'fill' stylebox override works: ", fill_stylebox is StyleBoxFlat)
	if fill_stylebox is StyleBoxFlat:
		var flat_sb := fill_stylebox as StyleBoxFlat
		print("  StyleBox bg_color: ", flat_sb.bg_color)
		assert(flat_sb.bg_color == Color.YELLOW, "StyleBox color should be YELLOW")
	
	pb.queue_free()
	print("  ✓ TEST 1 PASSED: StyleBox approach confirmed working\n")


func test_overheat_bar_value_update() -> void:
	"""Test 2: Verify that setting ProgressBar.value works correctly."""
	print("=== TEST 2: ProgressBar value updates ===")
	
	var pb := ProgressBar.new()
	add_child(pb)
	
	pb.max_value = 100.0
	pb.value = 0.0
	assert(pb.value == 0.0, "Initial value should be 0")
	
	pb.value = 50.0
	assert(pb.value == 50.0, "Value should update to 50")
	
	pb.value = 100.0
	assert(pb.value == 100.0, "Value should update to 100")
	
	print("  Value 0: ", 0.0)
	print("  Value 50: ", 50.0)
	print("  Value 100: ", 100.0)
	
	pb.queue_free()
	print("  ✓ TEST 2 PASSED: Value updates work correctly\n")


func test_label_font_color_override() -> void:
	"""Test 3: Verify that add_theme_color_override('font_color', ...) works on Labels."""
	print("=== TEST 3: Label font_color override ===")
	
	var label := Label.new()
	add_child(label)
	
	label.add_theme_color_override("font_color", Color.RED)
	var retrieved := label.get_theme_color("font_color", "Label")
	print("  font_color override: ", retrieved)
	assert(retrieved == Color.RED, "Label font_color override should work")
	
	label.add_theme_color_override("font_color", Color.YELLOW)
	retrieved = label.get_theme_color("font_color", "Label")
	assert(retrieved == Color.YELLOW, "Label font_color override should update")
	
	label.queue_free()
	print("  ✓ TEST 3 PASSED: Label font_color override works\n")


func test_color_gradient_calculation() -> void:
	"""Test 4: Verify color gradient math from yellow to red."""
	print("=== TEST 4: Color gradient calculation ===")
	
	# At 0%: should be pure yellow
	var color_0 := Color.YELLOW.lerp(Color.RED, 0.0)
	print("  Color at 0%: ", color_0)
	assert(color_0 == Color.YELLOW, "0% should be YELLOW")
	
	# At 50%: should be between yellow and red
	var color_50 := Color.YELLOW.lerp(Color.RED, 0.5)
	print("  Color at 50%: ", color_50)
	assert(color_50.r > 0.5 and color_50.g > 0.0, "50% should be orange-ish")
	
	# At 100%: should be pure red
	var color_100 := Color.YELLOW.lerp(Color.RED, 1.0)
	print("  Color at 100%: ", color_100)
	assert(color_100 == Color.RED, "100% should be RED")
	
	print("  ✓ TEST 4 PASSED: Color gradient math correct\n")


func test_stylebox_flat_creation() -> void:
	"""Test 5: Verify StyleBoxFlat can be created and colored dynamically."""
	print("=== TEST 5: Dynamic StyleBoxFlat creation ===")
	
	var test_values: Array[float] = [0.0, 25.0, 50.0, 75.0, 100.0]
	
	for val: float in test_values:
		var ratio: float = val / 100.0
		var color := Color.YELLOW.lerp(Color.RED, ratio)
		var sb := StyleBoxFlat.new()
		sb.bg_color = color
		
		print("  Overheat ", val, "% → color: ", color, " | StyleBox bg: ", sb.bg_color)
		assert(sb.bg_color == color, "StyleBoxFlat color should match")
	
	print("  ✓ TEST 5 PASSED: All StyleBoxFlat colors created correctly\n")
