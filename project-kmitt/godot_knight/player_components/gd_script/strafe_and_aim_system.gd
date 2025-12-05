extends Node

@export var player : CharacterBody3D
@export var camera_system : Node3D
@export var basic_movement_system : Node

const STRAFE_SPEED : float = 3.3
const ACCELERATION : float = 6.0

var direction : Vector3 = Vector3.BACK
var root_vel : Vector3 = Vector3.ZERO
var movement_speed : float = 0.0

var targets_arr = []


func _ready() -> void:
	set_physics_process(false)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("R3") or event.is_action_pressed("F"):
		if targets_arr.size() < 1:
			unaim_target()
		check_targets()
		

func _physics_process(delta):
	print("strafe")
	if !player.LADDER:
		strafe_movement(delta)
		check_targets()

### STRAFING ###
func strafe_movement(delta):
	# strafe movement input
	if (Input.is_action_pressed("UP") || Input.is_action_pressed("DOWN") || Input.is_action_pressed("LEFT") || Input.is_action_pressed("RIGHT")) and !player.disabled_movement:
		# get strafe as vector2
		var strafe_dir = Vector2(Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"),
								Input.get_action_strength("UP") - Input.get_action_strength("DOWN"))
							
		#strafe movement velocity
		strafe_dir.x = clamp(strafe_dir.x, -1.0, 1.0) #clamp val between -1 to 1
		strafe_dir.y = clamp(strafe_dir.y, -1.0, 1.0) #clamp val between -1 to 1
		direction = Vector3(strafe_dir.x, 0.0, strafe_dir.y)
		#play strafe animation
		player.anim_tree.set("parameters/" + player.state + "/STRAFE/blend_position", 
		lerp(player.anim_tree.get("parameters/" + player.state + "/STRAFE/blend_position"), 
		Vector2(strafe_dir.x, strafe_dir.y), delta * ACCELERATION))
		#move camera when moving left/right for NOT cover enemy
		camera_system.camera.position.x = lerp(camera_system.camera.position.x, strafe_dir.x * 1.5, delta)
		if strafe_dir.length() > 0.5:
			movement_speed = STRAFE_SPEED
			#sound_footstep(0.32)
			strafe_dir.normalized()
		else:
			movement_speed = STRAFE_SPEED * 0.5
			strafe_dir = strafe_dir.normalized() * 0.5
			#sound_footstep(0.55)
		
	else: # no input - idle
		movement_speed = 0.0
		#anim
		player.anim_tree.set("parameters/" + player.state + "/STRAFE/blend_position", 
		lerp(player.anim_tree.get("parameters/" + player.state + "/STRAFE/blend_position"), 
		Vector2.ZERO, delta * ACCELERATION))
		#camera to origin pos
		camera_system.camera.position.x = lerp(camera_system.camera.position.x, -0.5, delta * ACCELERATION * 0.5)
	
		
	player.player_movement_velocity.x = lerp(player.player_movement_velocity.x, direction.normalized().x * movement_speed, delta * ACCELERATION)
	player.player_movement_velocity.z = lerp(player.player_movement_velocity.z, direction.normalized().z * movement_speed, delta * ACCELERATION)
	#need root_motion from basic_movement_system
	player.velocity.x = (player.player_movement_velocity + basic_movement_system.root_motion_velocity()).x
	player.velocity.z = (player.player_movement_velocity + basic_movement_system.root_motion_velocity()).z
	
	
	
	## When not Rolling
	#
	#if !player.roll:# and !jump: 
		##player looking at target
		#player.player_armature.rotate_object_local(Vector3.UP, PI)
		#player.player_armature.look_at(Vector3(player.target.global_transform.origin.x, 
										#player.player_armature.global_transform.origin.y, 
										#player.target.global_transform.origin.z), 
								#Vector3.UP)
		#player.player_armature.rotate_object_local(Vector3.UP, PI)
			#
			## Rolltimer starts in jump_and_roll()
			##Rolling and no Input -> rolls in place
			##if $RollTimer.is_stopped():
				##player.direction = Vector3.ZERO
			#
		
		


### TARGETING ###
func check_targets():
	if targets_arr.size() < 1:
		unaim_target()
	else:
		aim_target()
	


func aim_target():
	# switch anim to strafe state
	basic_movement_system.set_physics_process(false)
	set_physics_process(true)
	# anim and camera
	player.anim_tree.set("parameters/" + player.state + "/strafe_blend/blend_amount", 1)

	
	#add target(s) to array
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
	return

func unaim_target():
	#return to normal state
	basic_movement_system.set_physics_process(true)
	player.anim_tree.set("parameters/" + player.state + "/strafe_blend/blend_amount", 0)
	camera_system.camera.position.x = 0.0
	set_physics_process(false)
	
	#remove target(s) to array
	player.target = null
	player.targeting = false
	return

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
			
		
	
	


func _on_target_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("ENEMY"):
		targets_arr.append(body)
		bubble_sort_vertical()

func _on_target_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("ENEMY"):
		targets_arr.erase(body)
		bubble_sort_vertical()
