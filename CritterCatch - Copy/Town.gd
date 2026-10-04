extends Node2D

export var battle_scene : PackedScene

onready var ui_layer = $UILayer


func _ready():
	SignalBus.connect("encounter_start", self, "start_battle")


func start_battle(enemy_data):
	

	var battle_instance = battle_scene.instance()
	ui_layer.add_child(battle_instance)
	battle_instance.initialize(enemy_data)


