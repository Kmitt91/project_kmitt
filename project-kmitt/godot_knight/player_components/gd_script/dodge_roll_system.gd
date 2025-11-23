extends Node

@export var player : CharacterBody3D
@export var basic_movement_system : Node

const ROLL_MAGNITUDE : float = 6.0


func _ready():
	#$RollTimer.wait_time = 0.6
	ready_error()

func ready_error():
	set_physics_process(false)
	if player == null and basic_movement_system == null:
		push_error("No player connected to " + self.name)
	else:
		set_physics_process(true)


func _physics_process(_delta):
	if !player.jump and !player.LADDER:
		rolling()
	
func rolling():
	#check if roll_anim is active
	if !player.disabled_movement:
		if !player.roll and !player.jump:
			if (Input.is_action_just_pressed("CIRCLE") or Input.is_action_just_pressed("R")):
						
				#cam_h_global_pos = player.global_position
				
				player.anim_tree.set("parameters/" + player.state + "/roll/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				#player.decrease_stamina(14, 1.0)
				player.disabled_movement = true
				
				$RollTimer.start(0)
				player.roll = true
				#I-frames while rolling
				player.hurtbox_collision.disabled = true
				return
			
		
	#Rolling while wait time : 0.6 in RollTimer
	if !$RollTimer.is_stopped():
		if basic_movement_system.direction.length() == 0.0:
			if player.targeting:
				basic_movement_system.direction = (player.global_transform.origin - player.target.global_transform.origin).normalized()
				basic_movement_system.direction *= Vector3(1.0, 0.0, 1.0)
			else:
				basic_movement_system.direction = Vector3.FORWARD.rotated(Vector3.UP, player.player_cam_rot)
		player.player_movement_velocity.x = basic_movement_system.direction.normalized().x * ROLL_MAGNITUDE
		player.player_movement_velocity.z = basic_movement_system.direction.normalized().z * ROLL_MAGNITUDE
		#player.velocity = player.player_movement_velocity #done in basic_movement_system

func _on_roll_timer_timeout():
	player.disabled_movement = false
	player.roll = false
	#I-frames off
	player.hurtbox_collision.disabled = false
