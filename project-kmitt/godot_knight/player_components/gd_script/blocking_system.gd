extends Node

@export var player : CharacterBody3D

var timer_block_one_shot : bool = false
var block_pos_sound : bool = false
#@onready var block_spark = preload("res://VFX/VFX_Magic/Blood_Scroll/Blood_Scroll_block.tscn")
@onready var shield_area : CollisionShape3D = shield.get_node("Area3DBlock/CollisionShape3D")
@onready var shield = $godot_knight
const ACCELERATION : float = 5.0

func block(delta):
	if !player.roll and !player.jump and !player.magic and !player.attack:
		var timer_block : Timer = $TimerBlock
			
		if Input.is_action_pressed("L1") or Input.is_action_pressed("LEFT_MOUSE"):
			player.anim_tree.set("parameters/" + player.state + "/block/blend_amount", lerp(float(player.anim_tree.get("parameters/" + player.state + "/block/blend_amount")), 1.0, delta * ACCELERATION * 2.0))
			player.disabled_movement = true
			shield.set_scale(lerp(shield.get_scale(), Vector3(1.2,1.2,1.2), delta * 10.0))
			#block
			if player.nim_tree.get("parameters/" + player.state + "/block/blend_amount") > 0.92 and !player.anim_tree.get("parameters/" + player.state + "/stagger/active"):
				player.blocking = true
				if timer_block.is_stopped() and !timer_block_one_shot:
					timer_block.start(0)
					shield_area.disabled = false
					#back_area.disabled = false
			#if anim_tree.get("parameters/" + state + "/block/blend_amount") < 0.1:
				
			
		elif player.anim_tree.get("parameters/" + player.state + "/block/blend_amount") > 0.0:
			player.blocking = false
			player.anim_tree.set("parameters/" + player.state + "/block/blend_amount", lerp(float(player.anim_tree.get("parameters/" + player.state + "/block/blend_amount")), 0.0, delta * ACCELERATION))
			shield_area.disabled = true
			#back_area.disabled = true
			shield.set_scale(lerp(shield.get_scale(), Vector3(1,1,1), delta * 10.0))
			
			if !timer_block.is_stopped() or timer_block_one_shot:
				timer_block.stop()
				timer_block_one_shot = false
		#block with coffin
	
	if Input.is_action_just_released("L1") or Input.is_action_just_released("LEFT_MOUSE"):
		player.disabled_movement = false
		block_pos_sound = false
		#back_area.disabled = true
		
	

func _on_timer_block_timeout():
	timer_block_one_shot = true
	shield_area.disabled = true

func _on_area_3d_block_area_entered(area):
	pass
	#if area.is_in_group("WEAPON"):
		#hit_shake_camera(0.2,0.15)
		#shield.add_child(VFX.magic_vfx_instance("Damage_Scroll"))
		
		#var spark_child = block_spark.instantiate()
		#shield.add_child(spark_child)
		
		#Audio.play_sfx("block_perfect")
	

#func _on_area_3d_back_area_enter
