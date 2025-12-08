extends Node

@export var player : CharacterBody3D
var gate_path = null

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta):
	gate_interaction(delta)
	
func current_gate_path(path):
	if path != null:
		gate_path = path
	else: 
		gate_path = null

func gate_interaction(delta):
	if gate_path != null:
		if !player.anim_tree.get("parameters/" + player.state + "/action/active") and !player.jump and !player.disabled_movement:
			if Input.is_action_just_pressed("TRIANGLE") or Input.is_action_just_pressed("E"):
				print("gate_entered")
				if gate_path.key: # door requires key?
					pass
					#if Globals.global_equipped_keyitems_item_name == gate_path.key_name:# player has key?
						#open gate
						#InputPrompt.prompt_visible(false)
						#InputPrompt.add_prompt("", str(gate_path.key_name + " used"), 6.0)
						#gate_animation()
						#
						#if gate_path.scene_change:
							#gate_path.anim_scene.play(str(gate_path.key_name))
							#$UserInterface/HUD.hide()
							
					#else:
						#InputPrompt.prompt_visible(false)
						#InputPrompt.add_prompt("", gate_path.key_prompt, 2.0)
					#	pass
				else:
					#InputPrompt.remove_prompt()
					#weapon_visibility_collecting(false, 4.67)
					gate_animation()
		else: 
			if !player.roll and !player.jump:# and ($TimerAttack1.is_stopped() and $TimerAttack2.is_stopped() and $TimerAttack3.is_stopped()):
				if player.player_root_motion.length() == 0.0:
					player.global_transform.origin = lerp(player.global_transform.origin, gate_path.gate_attach_point.global_transform.origin, delta * 5.0)
					
				player.player_armature.look_at(Vector3(gate_path.global_transform.origin.x,
													player.player_armature.global_transform.origin.y,
													gate_path.global_transform.origin.z), 
											Vector3.UP)
				player.player_armature.rotate_object_local(Vector3.UP, PI)
				
				player.player_root_motion = player.anim_tree.get_root_motion_position()
	
func gate_animation():
	var blend_tree = player.anim_tree.tree_root.get_node(player.state)
	var one_shot = blend_tree.get_node("action")
	one_shot.set_filter_enabled(true)
	
	player.disabled_movement = true
	
	player.anim_tree.set("parameters/" + player.state + "/action/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	player.anim_tree.set("parameters/" + player.state + "/action_anim/action_trans/transition_request", "GATE_open")
	gate_path.animR.play("gate_R")
	gate_path.animL.play("gate_L")
