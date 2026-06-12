extends Node
class_name DamageSystemValidator

"""
Simple validation script to test the damage system.
Run this in the editor or game to verify shields and hull work correctly.
"""

static func test_shield_absorption() -> bool:
	var player: Player = Player.new()
	player.current_shield = 50.0
	player.current_hull = 100.0
	
	player.take_damage(30.0, "test")
	
	if player.current_shield != 20.0:
		print("FAIL: Shield absorption - expected shield 20.0, got ", player.current_shield)
		return false
	
	if player.current_hull != 100.0:
		print("FAIL: Shield absorption - expected hull 100.0, got ", player.current_hull)
		return false
	
	print("PASS: Shield absorption test")
	return true

static func test_shield_overflow() -> bool:
	var player: Player = Player.new()
	player.current_shield = 30.0
	player.current_hull = 100.0
	
	player.take_damage(50.0, "test")
	
	if player.current_shield != 0.0:
		print("FAIL: Shield overflow - expected shield 0.0, got ", player.current_shield)
		return false
	
	if player.current_hull != 80.0:
		print("FAIL: Shield overflow - expected hull 80.0, got ", player.current_hull)
		return false
	
	print("PASS: Shield overflow test")
	return true

static func test_hull_only_damage() -> bool:
	var player: Player = Player.new()
	player.current_shield = 0.0
	player.current_hull = 100.0
	
	player.take_damage(25.0, "test")
	
	if player.current_hull != 75.0:
		print("FAIL: Hull only damage - expected hull 75.0, got ", player.current_hull)
		return false
	
	print("PASS: Hull only damage test")
	return true

static func run_all_tests() -> bool:
	print("\n=== Damage System Validation ===\n")
	
	var all_pass: bool = true
	all_pass = test_shield_absorption() and all_pass
	all_pass = test_shield_overflow() and all_pass
	all_pass = test_hull_only_damage() and all_pass
	
	if all_pass:
		print("\n✓ All tests passed!")
	else:
		print("\n✗ Some tests failed")
	
	return all_pass
