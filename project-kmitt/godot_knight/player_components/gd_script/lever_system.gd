extends Node

@export var player : CharacterBody3D
var lever_path = null

func _ready() -> void:
	set_physics_process(false)
	
func _physics_process(delta):
	lever_interaction(delta)

func current_lever_path(path):
	if path != null:
		lever_path = path
	else: 
		lever_path = null
	

func lever_interaction(delta):
	if lever_path != null:
		if !player.anim_tree.get("parameters/" + player.state + "/action/active") and !player.jump and !player.disabled_movement:
			if Input.is_action_just_pressed("TRIANGLE") or Input.is_action_just_pressed("E"):
	#			InputPrompt.remove_prompt()
				if lever_path.connected_obj_operational == true:
					#player.weapon_visibility_collecting(false, 1.67)
					#Audio.play_sfx("lever")
					
					player.disabled_movement = true
					player.anim_tree.set("parameters/" + player.state + "/action/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
					player.anim_tree.set("parameters/" + player.state + "/action_anim/action_trans/transition_request", "LEVER")
					lever_path.anim.play("lever_active")
#				else:
#					InputPrompt.prompt_visible(false)
#					InputPrompt.add_prompt("!", "Not operative...", 4.0)
		else:
			if !player.roll and !player.jump and !player.blocking:# and ($TimerAttack1.is_stopped() and $TimerAttack2.is_stopped() and $TimerAttack3.is_stopped()):
				var tween = get_tree().create_tween()
				player.global_position = lever_path.lever_attach_point.global_position
				#tween.tween_property(player, "global_position", lever_path.lever_attach_point.global_position, 0.5)
				#actor_lerp_position(delta, lever_path.lever_attach_point.global_transform.origin)
				player.player_armature.look_at(Vector3(lever_path.global_transform.origin.x,
												player.player_armature.global_transform.origin.y,
												lever_path.global_transform.origin.z), 
										Vector3.UP)
				player.player_armature.rotate_object_local(Vector3.UP, PI)
			
	
