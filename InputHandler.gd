extends Node2D

signal yo_getting_attacked

var towers: Array[Node]

var player_selected
var other_selected


func _ready():
	towers = get_node("../Towers").get_children()
	for tower in towers:
		tower.tower_selected.connect(_on_tower_tower_selected)


func _on_tower_tower_selected(tower):
	if tower.controller == "Player" && player_selected == null:
		player_selected = tower
		return
	
	if player_selected != null:
		other_selected = tower
		
		if player_selected != null:
			yo_getting_attacked.emit(player_selected, other_selected)

			player_selected = null
			other_selected = null
