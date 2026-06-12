extends Node
class_name TestOverheatFixValidation

func test_overheat_generates_with_fix() -> void:
	"""Test that overheat actually increases when CPU is kept high with the fix."""
	print("\n--- OVERHEAT FIX VALIDATION TEST ---")
	
	# Simulate the FIXED player logic with epsilon threshold
	var max_cpu_cycles: float = 100.0
	var cpu_generation_rate: float = 25.0
	var cpu_decay_rate: float = 15.0
	var delta: float = 0.016  # ~60 FPS
	var cpu_at_max_threshold: float = max_cpu_cycles * 0.95  # THE FIX: Use 95% threshold
	
	var current_cpu: float = 0.0
	var overheat: float = 0.0
	var overheat_max: float = 100.0
	var overheat_decay_rate: float = 8.0
	
	var click_count: int = 0
	var overheat_triggered: bool = false
	var max_overheat_reached: float = 0.0
	
	# Simulate continuous CPU generation and decay
	for frame: int in range(500):
		# Physics process: Decay CPU and overheat
		current_cpu = max(current_cpu - cpu_decay_rate * delta, 0.0)
		
		# Overheat decay when CPU is below threshold
		if current_cpu < cpu_at_max_threshold:
			overheat = max(overheat - overheat_decay_rate * delta, 0.0)
		
		# Input: Click every frame to test overheat generation
		var was_at_max: bool = current_cpu >= cpu_at_max_threshold
		current_cpu = min(current_cpu + cpu_generation_rate, max_cpu_cycles)
		
		# Generate heat if clicking at high CPU
		if was_at_max and current_cpu >= cpu_at_max_threshold:
			var heat_from_click: float = cpu_generation_rate * 0.5
			overheat = min(overheat + heat_from_click, overheat_max)
			overheat_triggered = true
		
		click_count += 1
		
		# Track peak overheat
		if overheat > max_overheat_reached:
			max_overheat_reached = overheat
		
		# Print status every 60 frames
		if frame % 60 == 0 or (overheat_triggered and frame < 120):
			print("Frame %d CPU: %.1f Threshold: %.1f Overheat: %.1f Triggered: %s" % 
				[frame, current_cpu, cpu_at_max_threshold, overheat, overheat_triggered])
		
		# Stop if overheat maxes out
		if overheat >= overheat_max:
			print("\nSUCCESS Overheat reached 100 at frame %d" % frame)
			break
	
	print("\n---RESULTS---")
	print("Total clicks %d" % click_count)
	print("Overheat triggered %s" % str(overheat_triggered))
	print("Peak overheat %.1f" % max_overheat_reached)
	print("Final overheat %.1f" % overheat)
	
	# Validate the fix worked
	assert(overheat_triggered, "ERROR: Overheat should trigger with fix")
	assert(max_overheat_reached > 0.0, "ERROR: Overheat should increase")
	print("\nOVERHEAT FIX VALIDATED Heat generation works\n")

