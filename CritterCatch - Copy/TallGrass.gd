extends Node2D

onready var anim_player = $AnimationPlayer
onready var area = $Area2D

export(Array, Resource) var critters : Array = []

export(int, 0, 100) var encounter_chance_per_step = 3
export(float) var min_time = 8.0
export(float) var max_time = 15.0

onready var encounter_timer = Timer.new()

var player = null
var distance_traveled = 0.0
var steps_per_check = 16

func _ready():
	encounter_timer.one_shot = true
	encounter_timer.connect("timeout", self, "_on_encounter_timeout")
	add_child(encounter_timer)

func _on_Area2D_body_entered(body):
	anim_player.play("Stepped")
	if body.name == "Player":
		player = body
		distance_traveled = 0.0
		_start_timer()

func _on_Area2D_body_exited(body):
	if body.name == "Player":

		encounter_timer.stop()

func _start_timer():
	encounter_timer.wait_time = rand_range(min_time, max_time)
	encounter_timer.start()

func _on_encounter_timeout():
	if _player_on_grass():
		_try_encounter()
		_start_timer()
	else:
		encounter_timer.stop()

func _physics_process(delta):
	if player == null or not _player_on_grass():
		return

	if player.is_moving:
		encounter_timer.paused = false
		distance_traveled += player.walk_speed * delta * 16
		if distance_traveled >= steps_per_check:
			distance_traveled = 0.0
			if randi() % 100 < encounter_chance_per_step:
				_try_encounter()
	else:
		encounter_timer.paused = true

func _player_on_grass():
	if player == null:
		return false
	if not is_instance_valid(area):
		return false
	return area.overlaps_body(player)

func _try_encounter():
	if not _player_on_grass():
		return
	if critters.empty():
		return
	var random_critter = critters[randi() % critters.size()]
	print("A wild " + random_critter.name + " appears!")
	SignalBus.emit_signal("encounter_start", random_critter)
