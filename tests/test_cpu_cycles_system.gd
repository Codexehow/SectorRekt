extends GutTest
# Test suite for CPU Cycles System

func test_cpu_generation_while_holding_q() -> void:
	# Test that CPU increases when Q is held
	var player: Player = Player.new()
	player._ready()
	
	var initial_cpu: float = player.current_cpu
	
	# Simulate holding Q
	Input.action_press("ui_select")  # Q key equivalent
	player._physics_process(0.1)
	
	assert_greater(player.current_cpu, initial_cpu, "CPU should increase when generating")

func test_cpu_distribution() -> void:
	# Test that CPU is distributed correctly
	var player: Player = Player.new()
	player._ready()
	
	# Set CPU to 50 for testing
	player.current_cpu = 50.0
	player._physics_process(0.1)
	
	# Check weapon charge receives 50% allocation
	assert_greater(player.weapon_charge, 0.0, "Weapon should charge")
	assert_greater(player.shield_charge, 0.0, "Shield should charge")
	assert_greater(player.blink_charge, 0.0, "Blink should charge")
	
	# Weapon should have more charge than shield and blink
	assert_greater(player.weapon_charge, player.shield_charge, "Weapon should charge faster")
	assert_greater(player.shield_charge, player.blink_charge, "Shield should charge faster than blink")

func test_weapon_fire_cost() -> void:
	# Test that firing weapon costs 30 CPU
	var player: Player = Player.new()
	player._ready()
	
	player.weapon_charge = 100.0
	var initial_weapon: float = player.weapon_charge
	
	player.fire_thunderbolt()
	
	assert_equal(player.weapon_charge, initial_weapon - 30.0, "Weapon charge should decrease by 30 after firing")

func test_blink_charge_requirement() -> void:
	# Test that blink requires full charge
	var player: Player = Player.new()
	player._ready()
	
	player.blink_charge = 99.0
	assert_equal(player.blink_charge, 99.0, "Blink should not activate at 99%")
	
	player.blink_charge = 100.0
	var initial_pos: Vector2 = player.global_position
	player.blink_drive()
	
	assert_not_equal(player.global_position, initial_pos, "Player should teleport")
	assert_equal(player.blink_charge, 0.0, "Blink charge should reset after use")

func test_cpu_degeneration() -> void:
	# Test that CPU decreases when not generating
	var player: Player = Player.new()
	player._ready()
	
	player.current_cpu = 50.0
	var initial_cpu: float = player.current_cpu
	
	# Don't hold any input
	player._physics_process(1.0)
	
	assert_less(player.current_cpu, initial_cpu, "CPU should decrease when not generating")

func test_corrupted_mode_toggle() -> void:
	# Test that corrupted mode can be toggled
	var player: Player = Player.new()
	player._ready()
	
	assert_equal(player.is_corrupted, false, "Should start in normal mode")
	
	player.is_corrupted = true
	assert_equal(player.is_corrupted, true, "Should be corrupted")
	
	player.is_corrupted = false
	assert_equal(player.is_corrupted, false, "Should toggle back")

func test_allocation_percentages() -> void:
	# Verify allocation constants are correct
	assert_equal(Player.WEAPON_ALLOC, 0.50, "Weapon allocation should be 50%")
	assert_equal(Player.SHIELD_ALLOC, 0.30, "Shield allocation should be 30%")
	assert_equal(Player.MOVEMENT_ALLOC, 0.10, "Movement allocation should be 10%")
	assert_equal(Player.LIFE_SUPPORT_ALLOC, 0.10, "Life Support allocation should be 10%")
	assert_equal(Player.BLINK_ALLOC, 0.10, "Blink allocation should be 10%")
