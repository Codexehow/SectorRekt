extends Control
class_name ConsequencePopup

# References to UI elements
var movement_button: Button = null
var blink_button: Button = null
var dark_overlay: Panel = null

# Track which consequence was chosen
var consequence_chosen: bool = false
var chosen_consequence: String = ""

signal consequence_selected(consequence: String)

func _ready() -> void:
	# Ensure popup processes even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Make this popup fullscreen for the overlay
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Ensure input is processed even when paused
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	print("[CONSEQUENCE POPUP] _ready() called - Process mode: ", process_mode)
	
	# Create dark overlay
	dark_overlay = Panel.new()
	dark_overlay.anchor_left = 0.0
	dark_overlay.anchor_top = 0.0
	dark_overlay.anchor_right = 1.0
	dark_overlay.anchor_bottom = 1.0
	add_child(dark_overlay)
	
	# Style the dark overlay (semi-transparent dark with red tint for corruption theme)
	var overlay_style: StyleBoxFlat = StyleBoxFlat.new()
	overlay_style.bg_color = Color(0.1, 0.0, 0.0, 0.8)  # Dark red overlay
	dark_overlay.add_theme_stylebox_override("panel", overlay_style)
	
	# Create main container (centered popup)
	var popup_container: VBoxContainer = VBoxContainer.new()
	popup_container.anchor_left = 0.5
	popup_container.anchor_top = 0.5
	popup_container.anchor_right = 0.5
	popup_container.anchor_bottom = 0.5
	popup_container.offset_left = -320.0
	popup_container.offset_top = -200.0
	popup_container.offset_right = 320.0
	popup_container.offset_bottom = 200.0
	popup_container.custom_minimum_size = Vector2(640, 400)
	add_child(popup_container)
	
	# Create popup background panel
	var popup_bg: Panel = Panel.new()
	popup_bg.custom_minimum_size = Vector2(640, 400)
	popup_container.add_child(popup_bg)
	
	# Style the popup background (glitchy neon digital theme)
	var popup_style: StyleBoxFlat = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)  # Dark blue-gray
	popup_style.border_color = Color(0.0, 1.0, 1.0, 0.8)  # Cyan border
	popup_style.set_border_width_all(3)
	popup_bg.add_theme_stylebox_override("panel", popup_style)
	
	# Create title
	var title: Label = Label.new()
	title.text = "SYSTEM CRITICAL: CONSEQUENCE REQUIRED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var title_font_size: int = 24
	title.add_theme_font_size_override("font_size", title_font_size)
	title.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0))  # Red text
	popup_container.add_child(title)
	
	# Add spacing
	var spacer1: Control = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 20)
	popup_container.add_child(spacer1)
	
	# Create description
	var description: Label = Label.new()
	description.text = "Your tank has overheated from sustained abuse.\nChoose one consequence to continue:"
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD
	var desc_font_size: int = 16
	description.add_theme_font_size_override("font_size", desc_font_size)
	description.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))  # Light gray
	popup_container.add_child(description)
	
	# Add spacing
	var spacer2: Control = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	popup_container.add_child(spacer2)
	
	# Create buttons container
	var buttons_container: HBoxContainer = HBoxContainer.new()
	buttons_container.add_theme_constant_override("separation", 20)
	buttons_container.custom_minimum_size = Vector2(0, 60)
	popup_container.add_child(buttons_container)
	
	# Movement Lockdown Button
	movement_button = Button.new()
	movement_button.text = "Movement Lockdown\n(Tank Frozen)"
	movement_button.custom_minimum_size = Vector2(300, 60)
	movement_button.add_theme_font_size_override("font_size", 14)
	movement_button.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))  # Yellow
	var movement_style: StyleBoxFlat = StyleBoxFlat.new()
	movement_style.bg_color = Color(0.3, 0.2, 0.0, 1.0)  # Dark yellow-brown
	movement_style.border_color = Color(1.0, 0.8, 0.0, 0.8)  # Yellow border
	movement_style.set_border_width_all(2)
	movement_button.add_theme_stylebox_override("normal", movement_style)
	movement_button.mouse_filter = Control.MOUSE_FILTER_STOP  # Ensure button can receive input
	movement_button.pressed.connect(_on_movement_pressed)
	movement_button.focus_mode = Control.FOCUS_ALL  # Enable focus
	buttons_container.add_child(movement_button)
	print("[CONSEQUENCE POPUP] Movement button created and connected")
	
	# Blink Reset Button
	blink_button = Button.new()
	blink_button.text = "Blink Drive Reset\n(Blink Charge to 0)"
	blink_button.custom_minimum_size = Vector2(300, 60)
	blink_button.add_theme_font_size_override("font_size", 14)
	blink_button.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0, 1.0))  # Cyan
	var blink_style: StyleBoxFlat = StyleBoxFlat.new()
	blink_style.bg_color = Color(0.0, 0.2, 0.3, 1.0)  # Dark cyan
	blink_style.border_color = Color(0.5, 0.8, 1.0, 0.8)  # Cyan border
	blink_style.set_border_width_all(2)
	blink_button.add_theme_stylebox_override("normal", blink_style)
	blink_button.mouse_filter = Control.MOUSE_FILTER_STOP  # Ensure button can receive input
	blink_button.pressed.connect(_on_blink_pressed)
	blink_button.focus_mode = Control.FOCUS_ALL  # Enable focus
	buttons_container.add_child(blink_button)
	print("[CONSEQUENCE POPUP] Blink button created and connected")
	
	print("[CONSEQUENCE POPUP] Initialized and displayed")

func _on_movement_pressed() -> void:
	"""Player chose Movement Lockdown consequence"""
	chosen_consequence = "movement_lockdown"
	consequence_chosen = true
	consequence_selected.emit(chosen_consequence)
	print("[CONSEQUENCE] Player chose: Movement Lockdown")
	queue_free()

func _on_blink_pressed() -> void:
	"""Player chose Blink Drive Reset consequence"""
	chosen_consequence = "blink_reset"
	consequence_chosen = true
	consequence_selected.emit(chosen_consequence)
	print("[CONSEQUENCE] Player chose: Blink Drive Reset")
	queue_free()
