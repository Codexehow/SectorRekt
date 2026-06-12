extends CanvasLayer
class_name CPUHUD

# References to UI elements
@onready var cpu_label: Label = $ResourcePanel/VBoxContainer/CPUSection/CPULabel
@onready var cpu_bar: ProgressBar = $ResourcePanel/VBoxContainer/CPUSection/CPUBar
@onready var weapon_label: Label = $ResourcePanel/VBoxContainer/OtherResourcesContainer/WeaponSection/WeaponLabel
@onready var weapon_bar: ProgressBar = $ResourcePanel/VBoxContainer/OtherResourcesContainer/WeaponSection/WeaponBar
@onready var shield_label: Label = $ResourcePanel/VBoxContainer/OtherResourcesContainer/ShieldSection/ShieldLabel
@onready var shield_bar: ProgressBar = $ResourcePanel/VBoxContainer/OtherResourcesContainer/ShieldSection/ShieldBar
@onready var blink_label: Label = $ResourcePanel/VBoxContainer/OtherResourcesContainer/BlinkSection/BlinkLabel
@onready var blink_bar: ProgressBar = $ResourcePanel/VBoxContainer/OtherResourcesContainer/BlinkSection/BlinkBar

func _ready() -> void:
	# Find the player in the scene
	var nodes: Array = get_tree().get_nodes_in_group("player")
	var player: Player = nodes[0] as Player if nodes.size() > 0 else null
	
	if player:
		# Connect the player's cpu_updated signal to our update function
		player.cpu_updated.connect(_on_cpu_updated)
		print("CPUHUD connected to Player signals")
	else:
		print("ERROR: Player not found in scene!")

func _on_cpu_updated(current: float, weapon: float, shield: float, blink: float) -> void:
	# Update CPU bar and label
	cpu_bar.value = current
	cpu_label.text = "CPU: %d/100" % int(current)
	
	# Update Weapon bar and label
	weapon_bar.value = weapon
	weapon_label.text = "Weapon: %d/100" % int(weapon)
	
	# Update Shield bar and label
	shield_bar.value = shield
	shield_label.text = "Shield: %d/100" % int(shield)
	
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
