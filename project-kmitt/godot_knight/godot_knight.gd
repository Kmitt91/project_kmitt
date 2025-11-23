extends CharacterBody3D

@onready var player_armature : Skeleton3D = $godot_knight/Godot_Knight_Armature/Skeleton3D
@onready var anim_tree : AnimationTree = $godot_knight/AnimationPlayer/AnimationTree
#@onready var left_hand : Node3D = $The_One_Reborn/The_One_Reborn_Armature/Skeleton3D/LeftHand/LHandScale
#@onready var right_hand : Node3D = $The_One_Reborn/The_One_Reborn_Armature/Skeleton3D/RightHand/RHandScale
@onready var greatshield : Node3D = $godot_knight/Godot_Knight_Armature/Skeleton3D/DEF_Shoulder_L_001/greatshield

# required for camera system
var player_cam_rot : float = 0.0 #!

#jumping
var jump : bool = false #!

#rolling
var roll : bool = false
var roll_magic : bool = false
var roll_magic_magnitude : float = 1.0
#var cam_h_global_pos : Vector3 = Vector3.ZERO #!

#targeting
var target = null
var targets_arr = []
var targeting : bool = false
