class_name Knight extends Node3D 

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var move_tilt_path : String = "parameters/StateMachine/Move/tilt/add_amount"

var run_tilt = 0.0 : set = _set_run_tilt

func _set_run_tilt(value : float):
	run_tilt = clamp(value, -1.0, 1.0)
	animation_tree.set(move_tilt_path, run_tilt)

func idle():
	state_machine.travel("Idle")

func move():
	state_machine.travel("Running")

func fall():
	state_machine.travel("Jump_Land")

func jump_start():
	state_machine.travel("Jump_Start")

func jump_idle():
	state_machine.travel("Jump_Idle")

func wall_slide():
	state_machine.travel("WallSlide")
