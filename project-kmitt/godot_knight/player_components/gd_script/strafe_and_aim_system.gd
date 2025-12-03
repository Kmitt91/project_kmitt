extends Node

@export var player : CharacterBody3D
@export var camera_system : Node3D

const STRAFE_SPEED : float = 3.3
const ACCELERATION : float = 6.0

var direction : Vector3 = Vector3.BACK
var root_vel : Vector3 = Vector3.ZERO
var movement_speed : float = 0.0

var targets_arr = []


### STRAFING ###
func strafe_movement(delta):
	
	if player.targeting and player.target != null:
		# switch to strafe state
		player.anim_tree.set("parameters/" + player.state + "/strafe_blend/blend_amount", 1.0)
		
		# When not Rolling and targeting
		if !player.roll:# and !jump: 
			#player target
			player.player_armature.rotate_object_local(Vector3.UP, PI)
			player.player_armature.look_at(Vector3(player.target.global_transform.origin.x, 
											player.player_armature.global_transform.origin.y, 
											player.target.global_transform.origin.z), 
									Vector3.UP)
			player.player_armature.rotate_object_local(Vector3.UP, PI)
			
			# Rolltimer starts in jump_and_roll()
			#Rolling and no Input -> rolls in place
			if $RollTimer.is_stopped():
				player.direction = Vector3.ZERO
			#set camera to strafe position
			#####camera.position.z = lerp(camera.position.z, -2.2, acceleration * delta)
			
		
		if (Input.is_action_pressed("UP") || Input.is_action_pressed("DOWN") || Input.is_action_pressed("LEFT") || Input.is_action_pressed("RIGHT")) and !player.disabled_movement:
			# get strafe as vector2
			var strafe_dir = Vector2(Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"),
									Input.get_action_strength("UP") - Input.get_action_strength("DOWN"))
								
							
			#clamp val between -1 to 1
			strafe_dir.x = clamp(strafe_dir.x, -1.0, 1.0)
			strafe_dir.y = clamp(strafe_dir.y, -1.0, 1.0)
			
			if strafe_dir.length() > 0.5:
				movement_speed = STRAFE_SPEED
#				sound_footstep(0.32)
				strafe_dir.normalized()
			else:
				movement_speed = STRAFE_SPEED * 0.5
				strafe_dir = strafe_dir.normalized() * 0.5
#				sound_footstep(0.55)
				
			#play animation
			player.anim_tree.set("parameters/" + player.state + "/STRAFE/blend_position", 
			lerp(player.anim_tree.get("parameters/" + player.state + "/STRAFE/blend_position"), 
			Vector2(strafe_dir.x, strafe_dir.y), delta * ACCELERATION))
			
			
			#move camera when moving left/right for NOT cover enemy
			camera.position.x = lerp(camera.position.x, strafe_dir.x * 1.5, delta)
		
		else:
			player.anim_tree.set("parameters/" + player.state + "/STRAFE/blend_position", 
			lerp(player.anim_tree.get("parameters/" + player.state + "/STRAFE/blend_position"), 
			Vector2.ZERO, delta * ACCELERATION))
			
			movement_speed = 0.0
			camera.position.x = lerp(camera.position.x, -0.5, delta * ACCELERATION * 0.5)
		
	else:
		#return to normal state
		player.anim_tree.set("parameters/" + player.state + "/strafe_blend/blend_amount", 0)
		
		camera.position.z = lerp(camera.position.z, -2.5, ACCELERATION * delta)
		camera.position.x = lerp(camera.position.x, 0.0, ACCELERATION * delta)



### TARGETING ###

func aim_target():
	
	if Input.is_action_just_pressed("R3") or Input.is_action_just_pressed("F"):
	
		if targets_arr.size() < 1:
			player.target = null
			player.targeting = false
			return
			
		else:
			
			if !player.targeting:
				player.target = targets_arr[0]
				player.targeting = true
				#target hud
				#player.target.armature.get_node("Spine/lock_point").show() # node_path_lp
				#player.target.get_node("HealthBar3D").show() #node_path_hb
				
		
			else:
				player.armature.get_node("Spine/lock_point").hide() # node_path_lp
				#target.get_node("HealthBar3D").hide() #node_path_hb
				
				player.target = null
				player.targeting = false
				
				
#				#reset camera when aiming from different height
#				var tween : Tween = get_tree().create_tween()
#				tween.EASE_IN_OUT
#				tween.tween_property($camera_pivot/h, "rotation", Vector3(0.0, $camera_pivot/h.rotation.y, 0.0), 0.5)
#				#tween.tween_property($camera_pivot/h/v, "rotation", Vector3(0.0, $camera_pivot/h.rotation.y, 0.0), 0.5)
#				#tween.tween_property(camera, "rotation_degrees", Vector3(0.0, -180.0, 0.0), 0.5)
			return
		
	if targets_arr.size() > 1:
		
		if Input.is_action_just_pressed("view_up"):
			
			bubble_sort_vertical()
			for i in range(targets_arr.size()):
				if targets_arr[i] == player.target:
					if i < targets_arr.size() - 1:
						player.target = targets_arr[i + 1]
						return
					
				
			
			
		if Input.is_action_just_pressed("view_down"):
			
			bubble_sort_vertical()
			for i in range(targets_arr.size()):
				if targets_arr[i] == player.target:
					if i > 0:
						player.target = targets_arr[i - 1]
						return


func _on_TargetArea_body_entered(body):
	if body.is_in_group("ENEMY"):
		targets_arr.append(body)
		bubble_sort_vertical()
	
func _on_TargetArea_body_exited(body):
	if body.is_in_group("ENEMY"):
		targets_arr.erase(body)
		bubble_sort_vertical()

func bubble_sort_vertical():
	var n : int = targets_arr.size()
	
	if n < 1 :
		player.targeting = false
		player.target = null
		return
		
	#bubble sort elements 
	for j in range(n - 1):
		for i in range(n - j - 1):
			var distance_to_next_target_i : float = (targets_arr[i].global_transform.origin - self.global_transform.origin).length()
			var distance_to_next_target_i_1 : float = (targets_arr[i+1].global_transform.origin - self.global_transform.origin).length()
			
			if distance_to_next_target_i > distance_to_next_target_i_1:
				var temp_i = targets_arr[i]
				var temp_i_1 = targets_arr[i+1]
				
				targets_arr[i] = temp_i_1
				targets_arr[i+1] = temp_i
			
		
	
	
