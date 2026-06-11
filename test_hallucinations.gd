extends Node

func test_hallucination_manager():
	print("Testing HallucinationManager...")
	var manager = HallucinationManager.new()
	manager._ready() # Force load
	
	var image = manager.get_random_hallucination("fire")
	if image:
		print("Successfully retrieved 'fire' hallucination.")
	else:
		print("Failed to retrieve 'fire' hallucination.")
		return false
		
	var nonexistent = manager.get_random_hallucination("banana")
	if nonexistent == null:
		print("Correctly returned null for nonexistent category.")
	else:
		print("Error: returned something for nonexistent category.")
		return false
	
	print("HallucinationManager test passed!")
	return true

func _init():
	if await test_hallucination_manager():
		print("All tests passed!")
		get_tree().quit()
	else:
		print("Tests failed!")
		get_tree().quit(1)
