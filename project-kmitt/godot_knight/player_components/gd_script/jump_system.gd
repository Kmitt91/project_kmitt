extends Node

@export var player : CharacterBody3D
@export var jump_force : float = 1.0

var GRAVITY : float = ProjectSettings.get_setting("physics/3d/default_gravity") 
const ACCELERATION : float = 5.0

var jump_count : int = 0
#var fall_damage : float = 0.0

func _ready():
	ready_error()

func ready_error():
	set_physics_process(false)
	if player == null:
		push_error("No player connected to " + self.name)
	else:
		$TimerGravity.start(0)
		#set_physics_process(true)


func _physics_process(delta):
	if !player.LADDER:
		jumping(delta)


#region ### VERTICAL MOVEMENT ###
func apply_gravity(delta):
	if !player.is_on_floor():
		player.player_movement_velocity.y -= GRAVITY * delta * 1.5
		player.velocity.y = player.player_movement_velocity.y
		if !player.jump:
			player.anim_tree.get("parameters/playback").travel("JUMP-loop")
			player.jump = true
	else:
		player.player_movement_velocity.y = -0.01
		player.velocity.y = player.player_movement_velocity.y
		if player.jump:
			player.anim_tree.get("parameters/playback").travel(player.state)
			player.jump = false
	
func jumping(delta):
	apply_gravity(delta)
	if !player.jump and (Input.is_action_just_pressed("CROSS") or Input.is_action_just_pressed("SPACE")) and !player.disabled_movement:
		#cam_h_global_pos = player.global_position
		if player.anim_tree.get("parameters/playback").get_current_node() != "JUMP-loop":
			player.anim_tree.get("parameters/playback").travel("JUMP_UP")
		
		player.player_movement_velocity.y = lerp(player.player_movement_velocity.y, 10.0 * jump_force, delta * ACCELERATION * 8.0)
		player.velocity.y = player.player_movement_velocity.y
		
		#player.decrease_stamina(7, 0.45)
		player.jump = true
	
func _on_timer_gravity_timeout():
	set_physics_process(true)
	
#endregion
