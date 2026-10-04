extends KinematicBody2D

signal player_moving_signal
signal player_stopped_signal

signal player_entering_door_signal
signal player_entered_door_signal


export var walk_speed = 6.5
const TILE_SIZE = 16
onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")
onready var ray = $BlockingRayCast2D
onready var door_ray = $DoorRayCast2D

enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 1)
var is_moving = false
var stop_input: bool = false
var percent_moved_to_next_tile = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.visible = true
	anim_tree.active = true
	initial_position = position
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	
func set_spawn(location: Vector2, direction: Vector2):
		anim_tree.set("parameters/Idle/blend_position", direction)
		anim_tree.set("parameters/Walk/blend_position", direction)
		position = location
	
func _physics_process(delta):
	if stop_input:
		return
	elif is_moving == false:
		process_player_movement_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk")
		move(delta)
	else:
		anim_state.travel("Idle")
		is_moving = false

func process_player_movement_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		
	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		
		initial_position = position
		is_moving = true
	else:
		anim_state.travel("Idle")

func entered_door():
	emit_signal("player_entered_door_signal")

func move(delta):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray.cast_to = desired_step
	ray.force_raycast_update()
	
	door_ray.cast_to = desired_step
	door_ray.force_raycast_update()
	
	if door_ray.is_colliding():
		if percent_moved_to_next_tile == 0.0:
			emit_signal("player_entering_door_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			stop_input = true
			$AnimationPlayer.play("Disappear")
			$Camera2D.clear_current()
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
		
	elif !ray.is_colliding():
		if percent_moved_to_next_tile == 0:
			emit_signal("player_moving_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			emit_signal("player_stopped_signal")
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	else:
		is_moving = false
