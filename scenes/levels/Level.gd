extends Node2D

export (Array, PackedScene) var levels

var current_level = 0
var current_level_instance = null

var _next_scene_mutex = false

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level_instance = levels[current_level].instance()
	add_child(current_level_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_screen_entered():
	_reset_player()

func _on_Player_screen_exited():
	call_deferred("_reset_scene")

func _on_Player_asleep():
	_reset_scene()

func _reset_player():
	$Player._init()
	$Player.position = $StartPosition.position

func _reset_scene():
	remove_child(current_level_instance)
	current_level_instance = levels[current_level].instance()
	add_child(current_level_instance)
	_reset_player()

func _next_scene():
	_next_scene_mutex = true
	$FadeOut.play("fade")
	yield($FadeOut, "animation_finished")
	remove_child(current_level_instance)
	current_level += 1
	current_level_instance = levels[current_level].instance()
	add_child(current_level_instance)
	_reset_player()
	_next_scene_mutex = false

func _on_Player_energy_changed(energy_level):
	var tilemap = current_level_instance.get_node("TileMap")
	var ppos = tilemap.world_to_map($Player.position)
	ppos.y += 1
	if tilemap.get_cellv(ppos) == 1: # check for coffee
		 tilemap.set_cellv(ppos, -1)
		 $Player.set("current_energy", $Player.ENERGY)
	elif tilemap.get_cellv(ppos) == 2: # check for bed
		if not _next_scene_mutex:
			_next_scene()
	
	var darkness =  ($Player.ENERGY - energy_level)/($Player.ENERGY*2)
	set("modulate", Color(1-darkness, 1-darkness, 1-darkness))
