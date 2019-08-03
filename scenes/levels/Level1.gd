extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_screen_entered():
	_reset_player()

func _on_Player_screen_exited():
	_reset_scene()

func _on_Player_asleep():
	_reset_scene()

func _reset_player():
	$Player._init()
	$Player.position = $StartPosition.position

func _reset_scene():
	get_tree().reload_current_scene()

func _on_Player_energy_changed(energy_level):
	var ppos = $TileMap.world_to_map($Player.position)
	if $TileMap.get_cellv(ppos) == 1: # check for coffee
		 $TileMap.set_cellv(ppos, -1)
		 $Player.set("current_energy", $Player.ENERGY)
	
	var darkness =  ($Player.ENERGY - energy_level)/($Player.ENERGY*2)
	set("modulate", Color(1-darkness, 1-darkness, 1-darkness))
