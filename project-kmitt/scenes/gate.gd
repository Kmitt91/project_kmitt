extends Node3D

@export var scene_change : bool = false

@export var key : bool = false
@export var key_name : String = ""
#@export var key_prompt : String = ""

@onready var animL : AnimationPlayer = $gate/AnimationPlayerL
@onready var animR : AnimationPlayer = $gate/AnimationPlayerR
@onready var gate_attach_point = $attach_point

var player = null
var in_front_area : bool = false





func _on_gate_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		in_front_area = true
		
		player = body
		player.get_node("gate_system").set_physics_process(true)
		player.get_node("gate_system").current_gate_path(self)
		
		#InputPrompt.add_prompt("TRIANGLE", "Open Gate")


func _on_gate_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		in_front_area = false
		print("gate_area_body_exited")
		#InputPrompt.remove_prompt()
		
		if !animR.is_playing() and player != null:
			player.get_node("gate_system").set_physics_process(false)
			player.get_node("gate_system").current_gate_path(false)
			player.disabled_movement = false
			player = null


func _on_animation_player_r_animation_finished(anim_name: StringName) -> void:
	if anim_name == "gate_R":
		$gate_area.queue_free()
		if player != null:
			player.player_root_motion = Vector3.ZERO
			player.get_node("gate_system").set_physics_process(false)
			player.get_node("gate_system").current_gate_path(false)
			player.disabled_movement = false
			player = null
			
			#_change_scene() #called in anim "gate_L"
