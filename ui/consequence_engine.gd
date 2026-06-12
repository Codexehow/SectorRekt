extends Node
class_name ConsequenceEngine

# Reference to player
var player: Player = null

# References to UI
var consequence_popup: ConsequencePopup = null
var consequence_popup_scene: PackedScene = preload("res://ui/consequence_popup.tscn")
var cpu_hud: CanvasLayer = null

# Track if a consequence is currently being handled
var handling_consequence: bool = false

func _ready() -> void:
	# Find the player
	var players: Array = get_tree().get_nodes_in_group("player")
	player = players[0] as Player if players.size() > 0 else null
	
	# Find the CPU HUD canvas layer
	var hud_candidates: Array = get_tree().get_nodes_in_group("cpuhud")
	if hud_candidates.size() > 0:
		cpu_hud = hud_candidates[0] as CanvasLayer
	else:
		# Fallback: search by type
		cpu_hud = get_tree().root.find_child("CPUHUD", true, false) as CanvasLayer
	
	if player:
		# Connect to the player's overheat critical signal
		var connection_result: int = player.overheat_critical.connect(_on_overheat_critical)
		if connection_result == OK:
			print("[CONSEQUENCE ENGINE] Successfully connected to overheat_critical signal!")
			print("[CONSEQUENCE ENGINE] CPU HUD found: ", cpu_hud != null)
		else:
			print("[CONSEQUENCE ENGINE] ERROR: Failed to connect to overheat_critical signal! Code: ", connection_result)
			return  # Exit _ready if connection fails
	else:
		print("[CONSEQUENCE ENGINE] ERROR: Player not found in scene!")

func _on_overheat_critical() -> void:
	"""Called when the player's overheat reaches 100%"""
	if handling_consequence:
		print("[CONSEQUENCE ENGINE] Already handling a consequence, ignoring duplicate signal")
		return
	
	print("[CONSEQUENCE ENGINE] Overheat critical reached! Triggering consequence system...")
	print("[CONSEQUENCE ENGINE] Current game state: paused=", get_tree().paused)
	print("[CONSEQUENCE ENGINE] Player reference valid: ", player != null)
	
	handling_consequence = true
	
	# Pause the game
	get_tree().paused = true
	print("[CONSEQUENCE ENGINE] Game paused - paused state is now: ", get_tree().paused)
	
	# Create and show the consequence popup
	show_consequence_popup()

func show_consequence_popup() -> void:
	"""Show the consequence popup UI and wait for player choice"""
	print("[CONSEQUENCE ENGINE] Attempting to show consequence popup...")
	print("[CONSEQUENCE ENGINE] CPU HUD: ", cpu_hud)
	print("[CONSEQUENCE ENGINE] Scene available: ", consequence_popup_scene != null)
	
	# Create the consequence popup from scene
	consequence_popup = consequence_popup_scene.instantiate() as ConsequencePopup
	if consequence_popup == null:
		print("[CONSEQUENCE ENGINE] ERROR: Failed to instantiate ConsequencePopup scene!")
		return
	
	# Add to appropriate parent
	if cpu_hud:
		cpu_hud.add_child(consequence_popup)
		print("[CONSEQUENCE ENGINE] Popup added to CPU HUD canvas layer")
	else:
		print("[CONSEQUENCE ENGINE] WARNING: CPU HUD not found, adding to scene root")
		get_tree().root.add_child(consequence_popup)
	
	# Connect to the signal when player makes a choice
	consequence_popup.consequence_selected.connect(_on_consequence_selected)
	
	print("[CONSEQUENCE ENGINE] Consequence popup displayed, awaiting player choice...")

func _on_consequence_selected(consequence: String) -> void:
	"""Called when player selects a consequence"""
	print("[CONSEQUENCE ENGINE] Player selected consequence: ", consequence)
	
	# Apply the chosen consequence to the player
	match consequence:
		"movement_lockdown":
			player.apply_movement_lockdown()
		"blink_reset":
			player.apply_blink_reset()
		_:
			print("[CONSEQUENCE ENGINE] Unknown consequence: ", consequence)
	
	# Reset overheat so it can build up again
	player.overheat = 0.0
	player.overheat_updated.emit(player.overheat)
	# Reset the overheat gate flag so it can trigger again on next cycle
	player.overheat_consequence_triggered = false
	print("[CONSEQUENCE ENGINE] Overheat reset to 0")
	
	# Unpause the game
	get_tree().paused = false
	print("[CONSEQUENCE ENGINE] Game unpaused, consequence applied!")
	
	handling_consequence = false
