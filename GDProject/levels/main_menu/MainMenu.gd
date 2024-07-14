extends HBoxContainer

@export var _startScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	var scene_manager : SceneManager = get_tree().root.get_node("Bootstrap/SceneManager")
	scene_manager.start_game()
