extends CanvasLayer
class_name CPUHUD

# References to UI elements
@onready var cpu_label: Label = $ResourcePanel/VBoxContainer/CPUSection/CPULabel
@onready var cpu_bar: ProgressBar = $ResourcePanel/VBoxContainer/CPUSection/CPUBar
@onready var weapon_label: Label = $ResourcePanel/VBoxContainer/OtherResourcesContainer/WeaponSection/WeaponLabel
@onready var weapon_bar: ProgressBar = $ResourcePanel/VBoxContainer/OtherResourcesContainer/WeaponSection/WeaponBar
@onready var shield_label: Label = $ResourcePanel/VBoxContainer/OtherResourcesContainer/ShieldSection/ShieldLabel
@onready var shield_bar: ProgressBar = $ResourcePanel/VBoxContainer/OtherResourcesContainer/ShieldSection/ShieldBar
@onready var shield_buffer_label: Label = $ResourcePanel/VBoxContainer/OtherResourcesContainer/ShieldSection/ShieldBufferLabel
@onready var hull_label: Label = $ResourcePanel/VBoxContainer/OtherResourcesContainer/HullSection/HullLabel
@onready var hull_bar: ProgressBar = $ResourcePanel/VBoxContainer/OtherResourcesContainer/HullSection/HullBar
@onready var blink_label: Label = $ResourcePanel/VBoxContainer/OtherResourcesContainer/BlinkSection/BlinkLabel
@onready var blink_bar: ProgressBar = $ResourcePanel/VBoxContainer/OtherResourcesContainer/BlinkSection/BlinkBar

# Controls panel references
@onready var controls_panel: Control = $ControlsPanel
@onready var options_panel: Control = $OptionsPanel
@onready var fullscreen_button: CheckButton = $OptionsPanel/VBoxContainer2/FullscreenCheckButton
@onready var resolution_option: OptionButton = $OptionsPanel/VBoxContainer2/ResolutionOptionButton

var controls_visible: bool = true
var options_visible: bool = false

func _ready() -> void:
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
		# Initialize bars with max values
		hull_bar.max_value = player.max_hull
		shield_bar.max_value = player.max_shield
		hull_bar.value = player.current_hull
		shield_bar.value = player.current_shield
		print("CPUHUD connected to Player signals")
	else:
		print("ERROR: Player not found in scene!")
	
	# Initialize options panel
	_setup_resolution_options()
	_setup_options_callbacks()
	
	# Hide options panel by default
	options_panel.visible = false

func _on_cpu_updated(current: float, weapon: float, _shield: float, blink: float) -> void:
	# Update CPU bar and label
	cpu_bar.value = current
	cpu_label.text = "CPU: %d/100" % int(current)
	
	# Update Weapon bar and label
	weapon_bar.value = weapon
	weapon_label.text = "Weapon: %d/100" % int(weapon)
	
	# Note: Shield bar is updated by _on_player_damaged signal, NOT here
	# This shield param is shield_charge (CPU allocation), not actual shield HP
	
	# Update Blink bar and label
	blink_bar.value = blink
	blink_label.text = "Blink: %d/100" % int(blink)
	
	# Optional: Change colors based on charge level
	if weapon >= 30.0:
		weapon_bar.modulate = Color.WHITE
	else:
		weapon_bar.modulate = Color(0.6, 0.6, 0.6)
	
	if blink >= 100.0:
		blink_bar.modulate = Color.WHITE
	else:
		blink_bar.modulate = Color(0.6, 0.6, 0.6)

func _on_player_damaged(hull: float, shield: float) -> void:
	"""Update hull and shield bars when player takes damage."""
	hull_bar.value = hull
	shield_bar.value = shield
	hull_label.text = "Hull: %d/100" % int(hull)
	shield_label.text = "Shield: %d/100" % int(shield)
	
	# Optional: Flash colors when damaged
	if hull <= 25.0:
		hull_bar.modulate = Color(1.0, 0.0, 0.0, 1.0)  # Red when critical
	else:
		hull_bar.modulate = Color.WHITE

func _on_shield_buffer_updated(buffer: float) -> void:
	"""Update shield buffer display."""
	if shield_buffer_label:
		shield_buffer_label.text = "Buffer: %d" % int(buffer)

func _input(event: InputEvent) -> void:
	"""Handle toggle controls with C key."""
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		controls_visible = not controls_visible
		controls_panel.visible = controls_visible
		options_visible = not options_visible
		options_panel.visible = options_visible
		get_tree().root.set_input_as_handled()

func _setup_resolution_options() -> void:
	"""Setup resolution options for the OptionButton."""
	resolution_option.add_item("1280x720")
	resolution_option.add_item("1600x900")
	resolution_option.add_item("1920x1080")
	resolution_option.add_item("2560x1440")
	resolution_option.add_item("3840x2160")
	resolution_option.select(2)  # Default to 1920x1080

func _setup_options_callbacks() -> void:
	"""Connect callbacks for options UI elements."""
	fullscreen_button.toggled.connect(_on_fullscreen_toggled)
	resolution_option.item_selected.connect(_on_resolution_selected)

func _on_fullscreen_toggled(pressed: bool) -> void:
	"""Handle fullscreen toggle."""
	if pressed:
		get_window().mode = Window.MODE_FULLSCREEN
		print("Fullscreen enabled")
	else:
		get_window().mode = Window.MODE_WINDOWED
		print("Fullscreen disabled")

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
		get_window().size = new_size
		print("Resolution changed to: ", new_size)
