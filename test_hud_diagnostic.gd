extends Node

# Diagnostic test to verify HUD presence
func test_hud_exists() -> void:
	print("\n=============== HUD DIAGNOSTIC TEST ===============\n")
	
	# Load the main scene
	var main_scene: PackedScene = load("res://main.tscn")
	print("1. Main scene loaded OK")
	
	# Check for errors during scene load
	var main: Node = main_scene.instantiate()
	print("2. Main scene instantiated OK")
	
	# Check all children
	var children: Array = main.get_children()
	print("3. Main has ", children.size(), " children:")
	for child in children:
		print("   - ", child.name, " (type: ", child.get_class(), ", script: ", child.get_script(), ")")
	
	# Look for CPUHUD
	var hud: Node = main.get_node_or_null("CPUHUD")
	if hud:
		print("\n4. CPUHUD node FOUND")
		print("   - Type: ", hud.get_class())
		print("   - Script: ", hud.get_script())
		print("   - Visible: ", hud.visible if "visible" in hud else "N/A")
		print("   - Layer: ", hud.layer if "layer" in hud else "N/A")
		
		# Check children of HUD
		var hud_children: Array = hud.get_children()
		print("   - Children count: ", hud_children.size())
		for hc in hud_children:
			print("      - ", hc.name, " (", hc.get_class(), ", visible=", hc.visible if "visible" in hc else "N/A", ")")
		
		# Check if the script has the expected methods
		if hud.has_method("_on_overheat_updated"):
			print("   - Has _on_overheat_updated: YES")
		else:
			print("   - Has _on_overheat_updated: NO")
		
		if hud.has_method("_initialize_ui_elements"):
			print("   - Has _initialize_ui_elements: YES")
		else:
			print("   - Has _initialize_ui_elements: NO")
		
		# Check OverHeatPanel nodes
		var oh_label = hud.get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatLabel")
		var oh_bar = hud.get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatBar")
		var oh_value = hud.get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatValue")
		print("   - OverHeatLabel: ", "FOUND" if oh_label else "MISSING")
		print("   - OverHeatBar: ", "FOUND" if oh_bar else "MISSING")
		print("   - OverHeatValue: ", "FOUND" if oh_value else "MISSING")
		
		# Check ResourcePanel nodes
		var resource_panel = hud.get_node_or_null("ResourcePanel")
		print("   - ResourcePanel: ", "FOUND" if resource_panel else "MISSING")
	else:
		print("\n4. CPUHUD node NOT FOUND!")
		print("   This means the HUD scene is not instancing correctly.")
	
	print("\n=============== DIAGNOSTIC COMPLETE ===============\n")
	get_tree().quit()