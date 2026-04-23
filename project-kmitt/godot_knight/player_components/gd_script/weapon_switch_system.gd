extends Node

@export var player : CharacterBody3D
var weapon : Node3D

func _ready() -> void:
	weapon = player.get_node("godot_knight/Godot_Knight_Armature/Skeleton3D/right_hand_bone_attachment/right_hand_scale/weapons")
	if player.state != "state_explore":
		var blade : PackedScene = load("res://godot_knight/blades/" + player.state + "_blade.tscn")
		weapon.add_child(blade.instantiate())
	
func _physics_process(delta: float) -> void:
	#print(player.state)
	var state_old = player.state
	if Input.is_action_just_pressed("0"):
		player.state = "state_explore"
	if Input.is_action_just_pressed("1"):
		player.state = "Sword"
	if Input.is_action_just_pressed("2"):
		player.state = "Greatsword"
	if Input.is_action_just_pressed("3"):
		player.state = "Doubleblade"
	if Input.is_action_just_pressed("4"):
		player.state = "Scythe"
		
	if weapon.get_child(1) != null: # if this state == explore
		weapon.get_child(1).queue_free()
	if state_old == player.state and player.state != "state_explore":
		var blade : PackedScene = load("res://godot_knight/blades/" + str(player.state) + "_blade.tscn")
		weapon.add_child(blade.instantiate())
	player.anim_tree.get("parameters/playback").travel(player.state)
