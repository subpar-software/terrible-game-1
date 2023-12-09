extends Node

signal send_dudes

var towers: Array[Node]

var first_selected
var second_selected

var label
var label2

func _ready():
	towers = get_node("../GameScene/Towers").get_children()
	for tower in towers:
		tower.selected.connect(_on_tower_selected)
	
	label = get_node("../GameScene/Info/Label")
	label2 = get_node("../GameScene/Info/Label2")

func _process(_delta):
	if first_selected:
		label.text = first_selected.name
	if second_selected:
		label2.text = second_selected.name


func _on_tower_selected(tower):
	deslect_all_towers()
	tower.is_selected = true
	
	if first_selected == null:
		first_selected = tower
		return
	
	if second_selected == null && first_selected.controller == "Player":
		second_selected = tower
		send_dudes.emit(first_selected, second_selected)
		first_selected = null
		second_selected = null


#	if tower.controller == "Player" && player_selected == null:
#		player_selected = tower
#		return
#
#	if player_selected != null:
#		other_selected = tower
#
#		send_dudes.emit(player_selected, other_selected)
#		player_selected = null
#		#other_selected = null

func deslect_all_towers():
	for tower in towers:
		tower.is_selected = false
