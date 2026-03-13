extends Node3D

@export var player : CharacterBody3D
@export var drag_camera : bool = true
@export var camera_speed : float = 80.0
@export var camera_distance_from_player : float = 2.2 

@onready var camera : Camera3D = $h/v/ClippedCamera

### camera variables ###
var initial_cam_rotation : Vector3 = Vector3.ZERO
var cam_h_global_pos : Vector3 = Vector3.ZERO
var camera_x_rot : float = 0.0
const CAMERA_ACCELERATION : float = 5.0
const CAM_X_MIN : float = -55.0
const CAM_X_MAX : float = 65.0


### READY ###
func _ready():
	ready_error()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#camera.fov = Globals.fov
	camera.position = Vector3(0.0, 0.0, -camera_distance_from_player)
	
	initial_cam_rotation.x = rad_to_deg(camera.rotation.x)
	initial_cam_rotation.y = rad_to_deg(camera.rotation.y)
	initial_cam_rotation.z = rad_to_deg(camera.rotation.z)
	
	$h/v/CameraCollider.add_exception(player)
	
### PROCESS ###
func _physics_process(delta):
	#for player rotation direction
	player.player_cam_rot = $h.global_transform.basis.get_euler().y
	
	#controlling
	camera_controller(delta)
	camera_strafe_movement(delta)
	#handling
	camera_collider()
	camera_drag(delta)
	
### INPUT ###
func _input(event):
	if event is InputEventMouseMotion:
		if !player.targeting and camera.current and is_physics_processing():
			var cam_speed : float = 0.0012 * (2.0 * (camera_speed / 100.0))
			rotate_camera(event.relative * cam_speed)
	#tutorial_prompt()
	#elif event.is_action_pressed("L3"):
		#drag_camera = !drag_camera
	

#region ### CAMERA HANDLING + FIX ###

func camera_drag(delta):
	#camera drag for jump and roll
	if drag_camera:
		if player.jump:
			self.global_position.y = cam_h_global_pos.y 
		#elif player.roll:
			#self.global_position = cam_h_global_pos
		else:
			cam_h_global_pos = player.global_position
		
	#drag camera reset
	if self.global_position != player.global_position:# and (roll_magic_magnitude == 1.0): #stupid to use roll_magn but better than implementig yet another bool
		self.global_position = lerp(self.global_position, player.global_position, delta * CAMERA_ACCELERATION)
		cam_h_global_pos = self.global_position

func camera_collider(activated : bool = true):
	if activated:
		if $h/v/CameraCollider.is_colliding():
			camera.global_transform.origin = $h/v/CameraCollider.get_collision_point()
		elif !player.targeting:
			camera.position = $h/v/CameraCollider.target_position

func ready_error():
	set_physics_process(false)
	set_process_input(false)
	if player == null:
		push_error("No player connected to " + self.name)
	else:
		set_physics_process(true)
		set_process_input(true)
	

#endregion

#region ### CAMERA CONTROLLING ###

func camera_controller(delta):
	
	if player.targeting and player.target != null:
		
		var cam_vec : Vector3 = (player.target.global_transform.origin - $h.global_transform.origin)
		$h.rotation = Vector3(0.0, $h.rotation.y, 0.0)
		$h.look_at(player.target.global_position, Vector3.UP)
		$h.rotate_object_local(Vector3.UP, PI)
		
		if player.target.is_in_group("ENEMY"):
			#$h.rotate_object_local(Vector3.UP, PI)
			#$h.global_transform.basis = $h.global_transform.basis.slerp($h.global_transform.looking_at(player.target.global_transform.origin, Vector3.UP).basis, delta * 5.0)
			#$h.rotate_object_local(Vector3.UP, PI)
			#$h/v.orthonormalize()
			camera_x_rot = (0.8 - cam_vec.length() * 0.1)
			camera_x_rot = clamp(camera_x_rot, 0.0, (CAM_X_MAX * PI) / 180)
			$h/v.rotation.x = lerp($h/v.rotation.x, camera_x_rot, delta * 4.0)
			
	else: 
		#Input 
		var camera_move : Vector2 = Vector2(
			Input.get_action_strength("view_right") - Input.get_action_strength("view_left"),
			Input.get_action_strength("view_down") - Input.get_action_strength("view_up"))
	
		if camera_move.length() > 0.0:
			var cam_speed : float = 2.0 * delta * (2.0 * (camera_speed / 100.0))
			rotate_camera(camera_move * cam_speed)
	
		var camera_basis : Basis = self.global_transform.basis
		var camera_z : Vector3 = camera_basis.z
		var camera_x : Vector3 = camera_basis.x

		camera_z.y = 0
		camera_z = camera_z.normalized()
		camera_x.y = 0
		camera_x = camera_x.normalized()
	
		#follow Camera
		var player_basis : Vector3 = player.player_armature.global_transform.basis.z
		var rot_speed : float = 0.08
		var auto_rotate = (PI - player_basis.angle_to($h.global_transform.basis.z)) * Vector2(player.velocity.x, player.velocity.z).length() * rot_speed
		
		if $CameraTimer.is_stopped():
			$h.rotation.y = lerp_angle($h.rotation.y, player.player_armature.global_transform.basis.get_euler().y, delta * auto_rotate)


func rotate_camera(move : Vector2):
	$h.rotate_y(-move.x)
	$h/v.orthonormalize()
	$CameraTimer.start()
	camera_x_rot += move.y
	camera_x_rot = clamp(camera_x_rot, (CAM_X_MIN * PI) / 180, (CAM_X_MAX * PI) / 180)
	$h/v.rotation.x = camera_x_rot
	

func camera_strafe_movement(delta):
	
	if player.targeting and player.target != null:
		# When not Rolling and targeting
		if !player.roll: 
			camera.position.z = lerp(camera.position.z, -2.2, CAMERA_ACCELERATION * delta)
			
		if (Input.is_action_pressed("UP") || Input.is_action_pressed("DOWN") || Input.is_action_pressed("LEFT") || Input.is_action_pressed("RIGHT")) and !player.disabled_movement:
			# get strafe as vector2
			var strafe_dir = Vector2(Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"),
									Input.get_action_strength("UP") - Input.get_action_strength("DOWN"))
							
					
			#clamp val between -1 to 1
			strafe_dir.x = clamp(strafe_dir.x, -1.0, 1.0)
			strafe_dir.y = clamp(strafe_dir.y, -1.0, 1.0)
			# adjust strafe direction value
			if strafe_dir.length() > 0.5:
				strafe_dir.normalized()
			else:
				strafe_dir = strafe_dir.normalized() * 0.5
			#move camera when moving left/right for NOT cover enemy
			camera.position.x = lerp(camera.position.x, strafe_dir.x * 1.5, delta)
		else:
			#idle camera pos when stafing (targeting)
			camera.position.x = lerp(camera.position.x, -0.5, delta * CAMERA_ACCELERATION * 0.5)
	else:
		#return to normal state
		camera.position.z = -camera_distance_from_player #lerp(camera.position.z, -2.5, CAMERA_ACCELERATION * delta)
		camera.position.x = 0#lerp(camera.position.x, 0.0, CAMERA_ACCELERATION * delta)

#endregion

#region ### CAMERA SHAKE ###

func hit_shake_camera(period, magnitude):
	#period = 0.2
	#magnitude = 0.15

	var campos = camera.get_position()
	var duration = 0

	while duration < period:
		duration += get_process_delta_time()
		duration = min(duration, period)

		#shake
		var offset = Vector3()
		offset.x = randf_range(-magnitude, magnitude)
		offset.y = randf_range(-period, period)

		var newcampos = campos
		newcampos += offset
		camera.set_position(newcampos)

		await get_tree().process_frame 

	camera.set_position(campos)
