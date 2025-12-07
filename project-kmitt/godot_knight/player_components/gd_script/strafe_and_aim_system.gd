extends Node
#strafe_movement and strafe_camera in according system
@export var player : CharacterBody3D

const STRAFE_SPEED : float = 3.3
const ACCELERATION : float = 6.0

var direction : Vector3 = Vector3.BACK
var root_vel : Vector3 = Vector3.ZERO
var movement_speed : float = 0.0

var targets_arr = []


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("R3") or Input.is_action_just_pressed("F"):
		check_targets()
	

### TARGETING ###
func check_targets():
	if targets_arr.size() < 1:
		unaim_target()
		return
	else:
		if !player.targeting:
			aim_target()
		else:
			unaim_target()
		return
	

func aim_target():
	player.target = targets_arr[0]
	player.targeting = true
	#add target(s) to array
	if Input.is_action_just_pressed("view_up"):
		bubble_sort_vertical()
		for i in range(targets_arr.size()):
			if targets_arr[i] == player.target:
				if i < targets_arr.size() - 1:
					player.target = targets_arr[i + 1]
	if Input.is_action_just_pressed("view_down"):
		bubble_sort_vertical()
		for i in range(targets_arr.size()):
			if targets_arr[i] == player.target:
				if i > 0:
					player.target = targets_arr[i - 1]
	return

func unaim_target():
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
