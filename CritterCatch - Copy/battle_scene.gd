extends Control

onready var enemy_texture = $MainLayout/BattleArea/EnemySide/TextureRect
onready var text_label: Label = $MainLayout/PanelContainer/Label


func initialize(enemy_data: EnemyData):
	enemy_texture.texture = enemy_data.texture
	text_label.text = enemy_data.name + " jumps out!"



func _on_Run_pressed() -> void:
	print("DEBUG GOT SIGNAL")
	get_tree().paused = false
	queue_free()
