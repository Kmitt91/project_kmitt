extends Node

@export var player : CharacterBody3D

const SPRINT_SPEED : float = 8.0
const RUN_SPEED : float = 5.0
const WALK_SPEED : float = 1.9
const STRAFE_SPEED : float = 3.3
const ACCELERATION : float = 6.0
const ANGULAR_ACCELERATION : float = 7.0

var direction : Vector3 = Vector3.BACK
var root_vel : Vector3 = Vector3.ZERO
var movement_speed : float = 0.0
var sprint_toggle : bool = false

func _ready():
	ready_error()

func _physics_process(delta):
	if !player.LADDER:
		basic_movement(delta)
		strafe_movement(delta)
	

#region ### HORIZONTAL MOVEMENT ###

func basic_movement(delta):
	
	if Input.is_action_pressed("L3") or Input.is_action_pressed("SHIFT"):
		sprint_toggle = true
	
	if input_WASD() and !player.disabled_movement:
		direction = Vector3(Input.get_action_strength("LEFT") - Input.get_action_strength("RIGHT"),
					0,
					Input.get_action_strength("UP") - Input.get_action_strength("DOWN")).rotated(Vector3.UP, player.player_cam_rot)#.normalized()
		if !player.targeting:
			if sprint_toggle:# and player.staminabar.value > 0.1:# and !jump: #SPRINT faster in explore_state
				player.anim_tree.set("parameters/" + player.state + "/idle_move/blend_amount", lerp(float(player.anim_tree.get("parameters/" + player.state + "/idle_move/blend_amount")), -1.0, delta * ACCELERATION))
				
				#stamina decreasing when runniung
				#player.decrease_stamina(0.1, 0.3)
				
				if player.state == player.EXPLORE:
					movement_speed = SPRINT_SPEED * 1.04
				else:
					movement_speed = SPRINT_SPEED
#				sound_footstep(0.31) #wait time for each step
				#roll_magnitude = 9.0
				
			else: #MOVE
				player.anim_tree.set("parameters/" + player.state + "/idle_move/blend_amount", lerp(float(player.anim_tree.get("parameters/" + player.state + "/idle_move/blend_amount")), 0.0, delta * ACCELERATION))
				
				#WALK OR RUN
				
				if direction.length() < 0.5:
					player.anim_tree.set("parameters/" + player.state + "/walk_run/blend_amount", lerp(float(player.anim_tree.get("parameters/" + player.state + "/walk_run/blend_amount")), 0.0, delta * ACCELERATION))
					movement_speed = WALK_SPEED
#					sound_footstep(0.5) #wait time for each step
					#roll_magnitude = 5.0
				else:
					player.anim_tree.set("parameters/" + player.state + "/walk_run/blend_amount", lerp(float(player.anim_tree.get("parameters/" + player.state + "/walk_run/blend_amount")), 1.0, delta * ACCELERATION))
					
					if player.state == player.EXPLORE:
						movement_speed = RUN_SPEED * 1.02
					else:
						movement_speed = RUN_SPEED
#					sound_footstep(0.32) #wait time for each step
					#roll_magnitude = 6.5
			
	else:
		sprint_toggle = false
		if !player.targeting: #IDLE
			player.anim_tree.set("parameters/" + player.state + "/idle_move/blend_amount", lerp(float(player.anim_tree.get("parameters/" + player.state + "/idle_move/blend_amount")), 1.0, delta * ACCELERATION))
			movement_speed = 0.0
		
	player.player_movement_velocity.x = lerp(player.player_movement_velocity.x, direction.normalized().x * movement_speed, delta * ACCELERATION)
	player.player_movement_velocity.z = lerp(player.player_movement_velocity.z, direction.normalized().z * movement_speed, delta * ACCELERATION)
	player.velocity.x = (player.player_movement_velocity + root_motion_velocity()).x
	player.velocity.z = (player.player_movement_velocity + root_motion_velocity()).z
	
	### Player Rotation ###
	var angle = atan2(direction.x, direction.z)
	player.player_armature.rotation.y = lerp_angle(player.player_armature.rotation.y, angle, delta * ANGULAR_ACCELERATION)
	
func strafe_movement(delta):
	
	if player.targeting and player.target != null:
		# switch to bland_space2D "STARFE"
		player.anim_tree.set("parameters/" + player.state + "/strafe_blend/blend_amount", 1.0)
		#when not Rolling and targeting
		if !player.roll:# and !jump: 
			player.player_armature.rotate_object_local(Vector3.UP, PI)
			player.player_armature.look_at(Vector3(player.target.global_transform.origin.x, 
												player.player_armature.global_transform.origin.y, 
												player.target.global_transform.origin.z), 
											Vector3.UP)
			player.player_armature.rotate_object_local(Vector3.UP, PI)
			
			# Rolltimer starts in jump_and_roll()
			#Rolling and no Input -> rolls in place
			#if $RollTimer.is_stopped():
				#player.direction = Vector3.ZERO
			
		
		if input_WASD() and !player.disabled_movement:
			#roll_magnitude = 5.0
			# get strafe as vector2
			var strafe_dir = Vector2(Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"),
									Input.get_action_strength("UP") - Input.get_action_strength("DOWN"))
			#clamp val between -1 to 1
			strafe_dir.x = clamp(strafe_dir.x, -1.0, 1.0)
			strafe_dir.y = clamp(strafe_dir.y, -1.0, 1.0)
			
			if strafe_dir.length() > 0.5:
				movement_speed = STRAFE_SPEED
				strafe_dir.normalized()
#				sound_footstep(0.32)
			else:
				movement_speed = STRAFE_SPEED * 0.5
				strafe_dir = strafe_dir.normalized() * 0.5
#				sound_footstep(0.55)
				
			#strafe movement animation
			player.anim_tree.set("parameters/" + player.state + "/STRAFE/blend_position", 
								lerp(player.anim_tree.get("parameters/" + player.state + "/STRAFE/blend_position"), 
								Vector2(strafe_dir.x, strafe_dir.y), delta * ACCELERATION))
		else:
			#idle animation and speed
			movement_speed = 0.0
			player.anim_tree.set("parameters/" + player.state + "/STRAFE/blend_position", 
								lerp(player.anim_tree.get("parameters/" + player.state + "/STRAFE/blend_position"), 
								Vector2.ZERO, delta * ACCELERATION))
	else:
		#return from blend_space2D to blend_tree 
		player.anim_tree.set("parameters/" + player.state + "/strafe_blend/blend_amount", 0)
	
func root_motion_velocity():
	
	var fps : float = float(Performance.get_monitor(Performance.TIME_FPS))
	### Root Motion Rotation ###
	var position_matrix : Quaternion = player.player_armature.get_quaternion()
	### Root Motion Translation ###
	var root_motion_displ : Vector3 = (position_matrix * player.player_root_motion) / (1.0 / fps) * 1.5 #delta * 1.5# (position_matrix * root_motion / delta) * 1.5
	
	root_vel.x = root_motion_displ.x
	root_vel.z = root_motion_displ.z
	root_vel.y = 0.0
	
	return root_vel
	
#endregion

#region ### MISCELLANEOUS ###
func ready_error():
	set_physics_process(false)
	if player == null:
		push_error("No player connected to " + self.name)
	else:
		set_physics_process(true)
	
func input_WASD():
	
	var W : bool = Input.is_action_pressed("UP")
	var A : bool = Input.is_action_pressed("LEFT")
	var S : bool = Input.is_action_pressed("DOWN")
	var D : bool = Input.is_action_pressed("RIGHT")
	
	if (W or A or S or D):
		return true
	else:
		return false
	
#endregion
