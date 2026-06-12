extends Node
class_name TestBeforeAfterOverheat

func test_broken_code_behavior() -> void:
	"""Show why overheat never triggered with the old code."""
	print("\nBROKEN CODE TEST old threshold >= 100.0")
	
	var max_cpu: float = 100.0
	var current_cpu: float = 0.0
	var overheat: float = 0.0
	
	for click: int in range(5):
		current_cpu = max(current_cpu - 15.0 * 0.016, 0.0)
		var was_at_max_OLD: bool = current_cpu >= max_cpu
		current_cpu = min(current_cpu + 25.0, max_cpu)
		
		if was_at_max_OLD and current_cpu >= max_cpu:
			overheat += 12.5
		
		print("Click %d CPU=%.1f WasAtMax=%s Overheat=%.1f OLD" % 
			[click, current_cpu, was_at_max_OLD, overheat])
	
	print("RESULT: was_at_max is ALWAYS FALSE")
	print("RESULT: Overheat is NEVER generated")
	print("STATUS: BROKEN\n")


func test_fixed_code_behavior() -> void:
	"""Show how the fix makes overheat work correctly."""
	print("FIXED CODE TEST new threshold >= 95.0")
	
	var max_cpu: float = 100.0
	var current_cpu: float = 0.0
	var overheat: float = 0.0
	var cpu_at_max_threshold: float = max_cpu * 0.95
	
	for click: int in range(5):
		current_cpu = max(current_cpu - 15.0 * 0.016, 0.0)
		var was_at_max_NEW: bool = current_cpu >= cpu_at_max_threshold
		current_cpu = min(current_cpu + 25.0, max_cpu)
		
		if was_at_max_NEW and current_cpu >= cpu_at_max_threshold:
			overheat = min(overheat + 12.5, 100.0)
		
		print("Click %d CPU=%.1f WasAtMax=%s Overheat=%.1f NEW" % 
			[click, current_cpu, was_at_max_NEW, overheat])
	
	print("RESULT: was_at_max becomes TRUE when CPU hits 95%")
	print("RESULT: Overheat IS generated on high CPU clicks")
	print("STATUS: FIXED\n")


func test_side_by_side_comparison() -> void:
	"""Direct side-by-side comparison of both approaches."""
	print("\nSIDE BY SIDE COMPARISON")
	
	var max_cpu: float = 100.0
	var current_cpu: float = 0.0
	var overheat_old: float = 0.0
	var overheat_new: float = 0.0
	var cpu_at_max_threshold: float = max_cpu * 0.95
	
	for click: int in range(8):
		current_cpu = max(current_cpu - 15.0 * 0.016, 0.0)
		
		var was_at_max_old: bool = current_cpu >= max_cpu
		var was_at_max_new: bool = current_cpu >= cpu_at_max_threshold
		
		current_cpu = min(current_cpu + 25.0, max_cpu)
		
		if was_at_max_old and current_cpu >= max_cpu:
			overheat_old = min(overheat_old + 12.5, 100.0)
		
		if was_at_max_new and current_cpu >= cpu_at_max_threshold:
			overheat_new = min(overheat_new + 12.5, 100.0)
		
		var old_str: String = "FALSE" if not was_at_max_old else "TRUE"
		var new_str: String = "FALSE" if not was_at_max_new else "TRUE"
		
		print("Click %d CPU=%.1f OldCheck=%s NewCheck=%s OldHeat=%.1f NewHeat=%.1f" % 
			[click, current_cpu, old_str, new_str, overheat_old, overheat_new])
	
	print("\nOLD CODE: Overheat stays at %.1f BROKEN" % overheat_old)
	print("NEW CODE: Overheat reaches %.1f WORKING\n" % overheat_new)

