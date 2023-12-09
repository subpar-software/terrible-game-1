extends Node2D

signal selected

@export var controller: String = "None"
@export var level: int = 1
var controller_color
var controller_selected_color

var is_selected: bool = false

var max_dudes = 1
var sending_dudes_to = []

var attackable_towers = []

var enemy_decision_counter = 0
var enemy_take_action = false

var dude = preload("res://scenes/dude/dude.tscn")

func _ready():
	var input_handler = get_tree().get_root().get_node("InputHandler")
	input_handler.send_dudes.connect(_on_sending_dudes)
	
	if (controller == "Enemy"):
		enemy_setup()


func enemy_setup():
	attackable_towers= get_parent().get_children()
	for tower in attackable_towers:
		if tower.controller == "Enemy":
			attackable_towers.erase(tower)
	attackable_towers.shuffle()
	

func _process(_delta):
	controller_color = ControllerColors.get_color[controller]
	controller_selected_color = ControllerColors.get_selected_color[controller]
	$Sprite2D.modulate = controller_selected_color if is_selected else controller_color

	$LevelLabel.text = str(level)
	$SendingLabel.text = str(sending_dudes_to.size())
	
	queue_redraw()

	if level >= 10:
		max_dudes = 2
	if level >= 20:
		max_dudes = 3

	if enemy_take_action && controller == "Enemy" && enemy_decision_counter % 2 == 0 && attackable_towers.size() > 0:
		enemy_take_action = false
		if len(sending_dudes_to) < max_dudes:
			var last_tower = attackable_towers.pop_back()
			sending_dudes_to.append(last_tower)


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			sending_dudes_to = []


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_selected = false

func _on_sending_dudes(sending_tower, recieving_tower):
	if self == sending_tower:
		if len(sending_dudes_to) < max_dudes:
			sending_dudes_to.append(recieving_tower)


func _draw():
	var tower_center = Vector2(0, 0)
	var line_width = 10.0

	for tower in sending_dudes_to:
		var attack_tower_center = tower.global_position - global_position
		draw_line(tower_center, attack_tower_center, controller_color, line_width)


func _on_timer_timeout():
	for tower in sending_dudes_to:
		var new_dude = dude.instantiate()
		new_dude.setup(self, tower)
		add_child(new_dude)
	
	if controller == "Enemy":
		enemy_decision_counter += 1
		enemy_take_action = true


func _on_area_2d_area_entered(area):
	var a_dude = area.get_parent()
	
	# only collide with tower dude is going to
	if (a_dude.to_tower_name != name):
		return
	
	# attacking
	if (a_dude.controller != controller):
		level -= 1
		if level == 0:
			controller = a_dude.controller
			sending_dudes_to = []
			if controller == "Enemy":
				enemy_setup()

	# supporting
	if (a_dude.controller == controller):
		if level < 30:
			level += 1
	
	a_dude.queue_free()
