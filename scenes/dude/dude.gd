extends Node2D

@export var controller: String = "None"
var from_tower_name
var to_tower_name
var go_where


func setup(tower, attacking):
	controller = tower.controller
	from_tower_name = tower.name
	to_tower_name = attacking.name
	go_where = attacking.position - tower.position


func _ready():
	$Sprite2D.modulate = ControllerColors.get_color[controller]


func _process(delta):
	position = position.move_toward(go_where, delta*200)
