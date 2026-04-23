extends Node

@export var player : CharacterBody3D
var atk_tap : int = 0
const TIME_DIFF : float = 0.15


### READY ###
func _ready():
	ready_error()
	
### PROCESS ###
func _physics_process(_delta):
	if player.state != "state_explore" and !player.LADDER:
		initialize_timers()
		readjust_attack_when_falling()
		if !player.LADDER:
			fast_sword_attack()
			slow_sword_atack()
	

#region ### SETUP AND FIXES ###

func ready_error():
	set_physics_process(false)
	if player == null:
		push_error("No player connected to " + self.name)
	else:
		set_physics_process(true)



#set the timer nodes to the time of the attack animation
func initialize_timers():
	#for a particular weapon type (player.state)
	if player.state != "state_explore":
		var _weapon_local : String = player.state
				
		#set wait time
		$TimerAttack1.wait_time = (player.anim_tree.get_parent().get_animation(_weapon_local + "_ATTACK1").get_length() - TIME_DIFF - 0.01)
		$TimerAttack2.wait_time = (player.anim_tree.get_parent().get_animation(_weapon_local + "_ATTACK2").get_length() - TIME_DIFF - 0.01)
		$TimerAttack3.wait_time = (player.anim_tree.get_parent().get_animation(_weapon_local + "_ATTACK3").get_length() - TIME_DIFF - 0.01)

#starts timer to swapn and despawn weapon collider, rest in magic_sword_trail.gd
#func weapon_col_instance(atk_number):
	#if player.right_hand.get_child_count() > 0:
		##get timer node
		#var timer_start : Timer = player.right_hand.get_child(0).get_node("TimerCol/TimerAtkStart" + str(atk_number))
		#var timer_end : Timer = timer_start.get_node("TimerAtkEnd" + str(atk_number))
#
		##start timer begin and timer end
		#timer_start.start(0)
		#timer_end.start(0)
	#

#Bugfix attacking while falling
func readjust_attack_when_falling():
	if player.jump:
		if !$TimerAttack1.is_stopped() or !$TimerAttack2.is_stopped() or !$TimerAttack3.is_stopped():
			$TimerAttack1.stop()
			$TimerAttack2.stop()
			$TimerAttack3.stop()
			player.disabled_movement = false
		
#endregion

#region ### ATTACK HANDLING ###
func fast_sword_attack():
	
	if (Input.is_action_just_pressed("R1") or Input.is_action_just_pressed("RIGHT_MOUSE")) and !player.jump:
		print("attack")
		if $TimerAttack1.is_stopped() and $TimerAttack2.is_stopped() and $TimerAttack3.is_stopped() and !player.disabled_movement:
			$TimerAttack1.start()
		
	# play anim of attack 1,2,3
	if true:
		
		if !$TimerAttack1.is_stopped():
			
			player.player_root_motion = player.anim_tree.get_root_motion_position()
			var blend_tree = player.anim_tree.tree_root.get_node(player.state)
			var one_shot = blend_tree.get_node(player.state + "_atk1")
			
			if !player.anim_tree.get("parameters/" + str(player.state) + "/" + str(player.state) + "_atk1/active"):
				player.anim_tree.set("parameters/" + player.state + "/" + player.state + "_atk1/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				
				one_shot.fadeout_time = TIME_DIFF
				player.attack = true
				player.disabled_movement = true
			
				#weapon_col_instance(1)
			
			elif (Input.is_action_just_pressed("R1") or Input.is_action_just_pressed("RIGHT_MOUSE")):
				if $TimerAttack1.time_left < 0.5 * $TimerAttack1.wait_time: # wait a bit before the follow up attack can be triggerd.
					atk_tap += 1
					one_shot.fadeout_time = 0.0
				
			
		if !$TimerAttack2.is_stopped():
			
			player.player_root_motion = player.anim_tree.get_root_motion_position()
			
			if !player.anim_tree.get("parameters/"+ player.state + "/" + player.state + "_atk2/active"):
				player.anim_tree.set("parameters/" + player.state + "/" + player.state + "_atk2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			
				player.disabled_movement = true
				player.attack = true
				
				#weapon_col_instance(2)
			
			elif (Input.is_action_just_pressed("R1") or Input.is_action_just_pressed("RIGHT_MOUSE")):
				if $TimerAttack2.time_left < 0.5 * $TimerAttack2.wait_time: # wait a bit before the follow up attack can be triggerd.
					atk_tap += 1
			
			
		elif player.jump or player.roll:
			player.anim_tree.set("parameters/" + player.state + "/" + player.state + "_atk1/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
			player.anim_tree.set("parameters/" + player.state + "/" + player.state + "_atk2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
			player.player_root_motion = Vector3.ZERO
		

func slow_sword_atack():
	#Conditions
	#Input and enough stamina
	if (Input.is_action_just_pressed("R2") or (Input.is_action_just_pressed("RIGHT_MOUSE") and Input.is_action_pressed("CTRL"))) and !player.jump:
		if $TimerAttack1.is_stopped() and $TimerAttack2.is_stopped() and $TimerAttack3.is_stopped() and !player.disabled_movement:
			$TimerAttack3.start(0)
		
	if true: # just for better overview
		# animation not played
		if !$TimerAttack3.is_stopped():
			player.player_root_motion = player.anim_tree.get_root_motion_position()
			if !player.anim_tree.get("parameters/" + player.state + "/" + player.state + "_atk3/active"):
				player.anim_tree.set("parameters/" + player.state + "/" + player.state + "_atk3/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			
				player.disabled_movement = true
				player.attack = true
				
				#weapon_col_instance(3)
				
		elif player.jump or player.roll:
			player.anim_tree.set("parameters/" + player.state + "/" + player.state + "_atk3/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
			player.player_root_motion = Vector3.ZERO
		
#endregion

#region ### TIMER TIMEOUT ###

func _on_timer_attack_1_timeout():
	if atk_tap >= 1:
		await get_tree().create_timer(TIME_DIFF,false).timeout
		$TimerAttack2.start(0)
		atk_tap = 0
	else:
		atk_tap = 0
		
	player.disabled_movement = false
	player.attack = false


func _on_timer_attack_2_timeout():
	if atk_tap >= 1:
		await get_tree().create_timer(TIME_DIFF,false).timeout
		$TimerAttack1.start(0)
		atk_tap = 0
	else:
		atk_tap = 0
		
	player.disabled_movement = false
	player.attack = false


func _on_timer_attack_3_timeout():
	player.disabled_movement = false
	player.attack = false
#endregion
