extends Node2D

export (Array, PackedScene) var levels

var current_level = 0
var current_level_instance = null

var _next_scene_mutex = false

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level_instance = levels[current_level].instance()
	add_child(current_level_instance)

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
	if levels.size()-1 > current_level:
		$FadeOut.play("fade")
		yield($FadeOut, "animation_finished")
		remove_child(current_level_instance)
		current_level += 1
		current_level_instance = levels[current_level].instance()
		add_child(current_level_instance)
		$HUDLayer/Day.text = "Day " + str(current_level + 1)
		_reset_player()
	else:
		$FadeOut.play("fade")
		yield($FadeOut, "animation_finished")
		get_tree().change_scene("res://scenes/End.tscn")
	_next_scene_mutex = false

func _physics_process(delta):
	var tilemap = current_level_instance.get_node("TileMap")
	var ppos = tilemap.world_to_map($Player.position)
	ppos.x /= 4; ppos.y /= 4
	ppos.y += 1
	if tilemap.get_cellv(ppos) == 1: # check for coffee
		 tilemap.set_cellv(ppos, -1)
		 $Player.set("current_energy", $Player.ENERGY)
	elif tilemap.get_cellv(ppos) == 32: # check for end
		if not _next_scene_mutex:
			_next_scene()
	
	var energy_level = $Player.current_energy
	var darkness =  1-($Player.ENERGY - energy_level)/($Player.ENERGY*2)
	
	$AudioPlayer.set("pitch_scale", darkness*darkness*darkness/2 + 0.7)
	
	var color = Color(darkness, darkness, darkness)
	set("modulate", color)
	var parallax_layers = current_level_instance.get_node("ParallaxBackground").get_children()
	for layer in parallax_layers:
		layer.set("modulate", color)
