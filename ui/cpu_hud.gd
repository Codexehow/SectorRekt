extends CanvasLayer
class_name CPUHUD

# References to UI elements - Will be initialized in _ready() to handle runtime instantiation
var cpu_label: Label = null
var cpu_bar: ProgressBar = null
var weapon_label: Label = null
var weapon_bar: ProgressBar = null
var shield_label: Label = null
var shield_bar: ProgressBar = null
var shield_buffer_label: Label = null
var hull_label: Label = null
var hull_bar: ProgressBar = null
var blink_label: Label = null
var blink_bar: ProgressBar = null

# OverHeat panel references - Will be initialized in _ready() to handle runtime instantiation
var overheat_label: Label = null
var overheat_bar: ProgressBar = null
var overheat_value: Label = null
var overheat_fill_stylebox: StyleBoxFlat = null  # Cache StyleBox to avoid creating new ones every frame

# Controls panel references - Will be initialized in _ready() to handle runtime instantiation
var controls_panel: Control = null
var options_panel: Control = null
var fullscreen_button: CheckButton = null
var resolution_option: OptionButton = null

var controls_visible: bool = true
var options_visible: bool = false

func _ready() -> void:
	# Initialize UI element references
	# This must be done manually since the scene is instantiated at runtime
	_initialize_ui_elements()
	
	# Find the player in the scene
	var nodes: Array = get_tree().get_nodes_in_group("player")
	var player: Player = nodes[0] as Player if nodes.size() > 0 else null
	
	if player:
		# Connect the player's cpu_updated signal to our update function
		player.cpu_updated.connect(_on_cpu_updated)
		# Connect the player's damage signal for hull/shield updates
		player.player_damaged.connect(_on_player_damaged)
		# Connect shield buffer signal
		player.shield_buffer_updated.connect(_on_shield_buffer_updated)
		# Connect overheat signal
		player.overheat_updated.connect(_on_overheat_updated)
		
		# Initialize bars with max values (with null checks)
		if shield_bar:
			shield_bar.max_value = player.max_shield
			shield_bar.value = player.current_shield
		if hull_bar:
			hull_bar.max_value = player.max_hull
			hull_bar.value = player.current_hull
		
		# Initialize overheat bar (with null check)
		if overheat_bar:
			overheat_bar.max_value = player.overheat_max
			overheat_bar.value = player.overheat
			# Create the fill StyleBox once to avoid recreating it every frame
			overheat_fill_stylebox = StyleBoxFlat.new()
			overheat_fill_stylebox.bg_color = Color.YELLOW
			overheat_bar.add_theme_stylebox_override("fill", overheat_fill_stylebox)
			print("Overheat bar initialized: max=", overheat_bar.max_value)
		else:
			print("ERROR: overheat_bar is null!")
		
		print("CPUHUD connected to Player signals")
	else:
		print("ERROR: Player not found in scene!")
	
	# Initialize options panel
	_setup_resolution_options()
	_setup_options_callbacks()
	
	# Hide options panel by default
	if options_panel:
		options_panel.visible = false
	
	# Verify all UI elements were initialized
	_verify_ui_initialization()

func _initialize_ui_elements() -> void:
	"""Manually initialize all UI element references to handle runtime instantiation."""
	# OverHeat panel elements
	overheat_label = get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatLabel")
	overheat_bar = get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatBar")
	overheat_value = get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatValue")
	
	# Resource panel elements (we still need these for other systems)
	var resource_panel: Control = get_node_or_null("ResourcePanel")
	if resource_panel:
		cpu_label = get_node_or_null("ResourcePanel/VBoxContainer/CPUSection/CPULabel")
		cpu_bar = get_node_or_null("ResourcePanel/VBoxContainer/CPUSection/CPUBar")
		weapon_label = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/WeaponSection/WeaponLabel")
		weapon_bar = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/WeaponSection/WeaponBar")
		shield_label = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/ShieldSection/ShieldLabel")
		shield_bar = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/ShieldSection/ShieldBar")
		shield_buffer_label = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/ShieldSection/ShieldBufferLabel")
		hull_label = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/HullSection/HullLabel")
		hull_bar = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/HullSection/HullBar")
		blink_label = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/BlinkSection/BlinkLabel")
		blink_bar = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/BlinkSection/BlinkBar")
	
	# Control and Options panel elements
	controls_panel = get_node_or_null("ControlsPanel")
	options_panel = get_node_or_null("OptionsPanel")
	
	if options_panel:
		fullscreen_button = get_node_or_null("OptionsPanel/VBoxContainer2/FullscreenCheckButton")
		resolution_option = get_node_or_null("OptionsPanel/VBoxContainer2/ResolutionOptionButton")

func _verify_ui_initialization() -> void:
	"""Verify that all critical UI elements were properly initialized."""
	print("\n[CPUHUD] UI Element Initialization Status:")
	print("  Overheat Label: ", "✓" if overheat_label else "✗")
	print("  Overheat Bar: ", "✓" if overheat_bar else "✗")
	print("  Overheat Value: ", "✓" if overheat_value else "✗")
	print("  Controls Panel: ", "✓" if controls_panel else "✗")
	print("  Options Panel: ", "✓" if options_panel else "✗")
	print("  Resolution Option: ", "✓" if resolution_option else "✗")
	print("  Fullscreen Button: ", "✓" if fullscreen_button else "✗")
	print()

func _on_cpu_updated(current: float, weapon: float, _shield: float, blink: float) -> void:
	# Update CPU bar and label
	if cpu_bar:
		cpu_bar.value = current
	if cpu_label:
		cpu_label.text = "CPU: %d/100" % int(current)
	
	# Update Weapon bar and label
	if weapon_bar:
		weapon_bar.value = weapon
	if weapon_label:
		weapon_label.text = "Weapon: %d/100" % int(weapon)
	
	# Note: Shield bar is updated by _on_player_damaged signal, NOT here
	# This shield param is shield_charge (CPU allocation), not actual shield HP
	
	# Update Blink bar and label
	if blink_bar:
		blink_bar.value = blink
	if blink_label:
		blink_label.text = "Blink: %d/100" % int(blink)
	
	# Optional: Change colors based on charge level
	if weapon_bar:
		if weapon >= 30.0:
			weapon_bar.modulate = Color.WHITE
		else:
			weapon_bar.modulate = Color(0.6, 0.6, 0.6)
	
	if blink_bar:
		if blink >= 100.0:
			blink_bar.modulate = Color.WHITE
		else:
			blink_bar.modulate = Color(0.6, 0.6, 0.6)

func _on_player_damaged(hull: float, shield: float) -> void:
	"""Update hull and shield bars when player takes damage."""
	if hull_bar:
		hull_bar.value = hull
	if shield_bar:
		shield_bar.value = shield
	if hull_label:
		hull_label.text = "Hull: %d/100" % int(hull)
	if shield_label:
		shield_label.text = "Shield: %d/100" % int(shield)
	
	# Optional: Flash colors when damaged
	if hull_bar:
		if hull <= 25.0:
			hull_bar.modulate = Color(1.0, 0.0, 0.0, 1.0)  # Red when critical
		else:
			hull_bar.modulate = Color.WHITE

func _on_shield_buffer_updated(buffer: float) -> void:
	"""Update shield buffer display."""
	if shield_buffer_label:
		shield_buffer_label.text = "Buffer: %d" % int(buffer)

func _on_overheat_updated(overheat_val: float) -> void:
	"""Update overheat bar with color gradient from yellow to red."""
	# Validate that UI elements are initialized
	if not overheat_bar or not overheat_value or not overheat_label or not overheat_fill_stylebox:
		print("ERROR: Overheat UI elements not initialized! overheat_val=", overheat_val)
		print("  overheat_bar: ", overheat_bar)
		print("  overheat_value: ", overheat_value)
		print("  overheat_label: ", overheat_label)
		print("  overheat_fill_stylebox: ", overheat_fill_stylebox)
		return
	
	# Update bar value
	overheat_bar.value = overheat_val
	
	# Update value label text
	overheat_value.text = "%d/100" % int(overheat_val)
	
	# Color gradient: Yellow (0%) -> Orange -> Red (100%)
	# Update the cached StyleBox color instead of creating a new one every frame
	var color_ratio: float = overheat_val / 100.0
	overheat_fill_stylebox.bg_color = Color.YELLOW.lerp(Color.RED, color_ratio)
	print("[OVERHEAT UPDATE] Value: %.1f, Color Ratio: %.2f" % [overheat_val, color_ratio])
	
	# Change label color intensity based on heat level
	if overheat_val >= 75.0:
		overheat_label.add_theme_color_override("font_color", Color.RED)
	elif overheat_val >= 50.0:
		overheat_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.0))  # Orange
	else:
		overheat_label.add_theme_color_override("font_color", Color.YELLOW)

func _input(event: InputEvent) -> void:
	"""Handle toggle controls with C key."""
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		controls_visible = not controls_visible
		if controls_panel:
			controls_panel.visible = controls_visible
		
		options_visible = not options_visible
		if options_panel:
			options_panel.visible = options_visible
		
		get_tree().root.set_input_as_handled()

func _setup_resolution_options() -> void:
	"""Setup resolution options for the OptionButton."""
	if not resolution_option:
		print("ERROR: resolution_option is null!")
		return
	
	resolution_option.add_item("1280x720")
	resolution_option.add_item("1600x900")
	resolution_option.add_item("1920x1080")
	resolution_option.add_item("2560x1440")
	resolution_option.add_item("3840x2160")
	resolution_option.select(2)  # Default to 1920x1080

func _setup_options_callbacks() -> void:
	"""Connect callbacks for options UI elements."""
	if fullscreen_button:
		fullscreen_button.toggled.connect(_on_fullscreen_toggled)
	else:
		print("ERROR: fullscreen_button is null!")
	
	if resolution_option:
		resolution_option.item_selected.connect(_on_resolution_selected)
	else:
		print("ERROR: resolution_option is null!")

func _on_fullscreen_toggled(pressed: bool) -> void:
	"""Handle fullscreen toggle."""
	if pressed:
		print("[FULLSCREEN] Enabling fullscreen...")
		get_window().mode = Window.MODE_FULLSCREEN
		print("[FULLSCREEN] Fullscreen mode enabled")
	else:
		print("[FULLSCREEN] Disabling fullscreen...")
		get_window().mode = Window.MODE_WINDOWED
		print("[FULLSCREEN] Windowed mode enabled")

func _on_resolution_selected(index: int) -> void:
	"""Handle resolution selection."""
	var resolutions: Array[Vector2i] = [
		Vector2i(1280, 720),
		Vector2i(1600, 900),
		Vector2i(1920, 1080),
		Vector2i(2560, 1440),
		Vector2i(3840, 2160)
	]
	
	if index >= 0 and index < resolutions.size():
		var new_size: Vector2i = resolutions[index]
		var was_fullscreen: bool = get_window().mode == Window.MODE_FULLSCREEN
		
		print("[RESOLUTION] Selected index: ", index, " (", resolutions[index], ")")
		print("[RESOLUTION] Current size: ", get_window().size)
		print("[RESOLUTION] Was fullscreen: ", was_fullscreen)
		
		# Exit fullscreen BEFORE changing size so the change takes effect
		if was_fullscreen:
			print("[RESOLUTION] Exiting fullscreen mode...")
			get_window().mode = Window.MODE_WINDOWED
			# Wait multiple frames for fullscreen transition to complete
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			print("[RESOLUTION] Fullscreen exit complete, current size: ", get_window().size)
		
		# Now resize the window
		print("[RESOLUTION] Resizing window to: ", new_size)
		get_window().size = new_size
		await get_tree().process_frame
		await get_tree().process_frame
		var current_size: Vector2i = get_window().size
		print("[RESOLUTION] Window resized to: ", current_size)
		
		# Verify the resize worked
		if current_size != new_size:
			print("[RESOLUTION] WARNING: Resize may not have taken effect, got: ", current_size, " expected: ", new_size)
		
		# Restore fullscreen mode if it was enabled before
		if was_fullscreen:
			print("[RESOLUTION] Restoring fullscreen mode...")
			await get_tree().process_frame
			await get_tree().process_frame
			get_window().mode = Window.MODE_FULLSCREEN
			print("[RESOLUTION] Fullscreen mode restored")
		
		print("[RESOLUTION] Resolution change complete")
