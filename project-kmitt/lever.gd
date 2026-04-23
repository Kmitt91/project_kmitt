extends Node3D

var player = null
@onready var lever_attach_point = $attach_point
@onready var anim : AnimationPlayer = $lever_mesh/AnimationPlayer
@export var connected_object : Node3D
@export var connected_obj_operational : bool = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "lever_active":
		if player != null:
			player.disabled_movement = false

		if connected_object != null:
			connected_object.connected_object_active()
				
		
	


func _on_lever_area_body_entered(body):
	if body.is_in_group("PLAYER"):
		player = body
		player.get_node("lever_system").set_physics_process(true)
		player.get_node("lever_system").current_lever_path(self)
		
		#InputPrompt.add_prompt("TRIANGLE", "Pull Lever")
		# if elevator is operatable set lever operatable as well
#		if connected_object.contraption_operational:
#			connected_obj_operational = connected_object.contraption_operational
	

func _on_lever_area_body_exited(body):
	if body.is_in_group("PLAYER"):
		player.get_node("lever_system").set_physics_process(false)
		player.get_node("lever_system").current_lever_path(false)
		player.disabled_movement = false
		player = null
		
		#InputPrompt.remove_prompt()
	
