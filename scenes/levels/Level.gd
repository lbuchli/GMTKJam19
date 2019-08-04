extends Node2D

export (Array, PackedScene) var levels

var current_level = 0
var current_level_instance = null

var _next_scene_mutex = false

var waiting = true

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level_instance = levels[current_level].instance()
	add_child(current_level_instance)
	_modulate(Color(0, 0, 0))
	$AlarmPlayer.play(17)
	yield($AlarmPlayer, "finished")
	$Player.position = $StartPosition.position
	$HouseDoorPlayer.play(1.5)
	waiting = false
	_modulate(Color(1, 1, 1))
	_limit_camera()

func _on_Player_screen_entered():
	pass

func _on_Player_screen_exited():
	if not waiting:
		call_deferred("_reset_scene")

func _on_Player_asleep():
	_reset_scene()

func _reset_player():
	$Player._init()
	$Player.position = $StartPosition.position
	$HouseDoorPlayer.play(1.5)

func _reset_scene():
	remove_child(current_level_instance)
	current_level_instance = levels[current_level].instance()
	add_child(current_level_instance)
	_reset_player()

func _next_scene():
	_next_scene_mutex = true
	$WorkDoorPlayer.play(0)
	if levels.size()-1 > current_level:
		$FadeOut.play("fade")
		yield($FadeOut, "animation_finished")
		remove_child(current_level_instance)
		current_level += 1
		current_level_instance = levels[current_level].instance()
		add_child(current_level_instance)
		$HUDLayer/Day.text = "Day " + str(current_level + 1)
		_reset_player()
		_limit_camera()
	else:
		$FadeOut.play("fade")
		yield($FadeOut, "animation_finished")
		get_tree().change_scene("res://scenes/End.tscn")
	_next_scene_mutex = false

func _physics_process(delta):
	if not waiting:
		var tilemap = current_level_instance.get_node("TileMap")
		var ppos = tilemap.world_to_map($Player.position)
		ppos.x /= 4; ppos.y /= 4
		var ppos_feet = ppos + Vector2(0, 1)
		var ppos_top = ppos - Vector2(0, 10)
		if tilemap.get_cellv(ppos_feet) == 8: # check for coffee
			 $SlurpPlayer.play(5.5)
			 tilemap.set_cellv(ppos_feet, -1)
			 $Player.set("current_energy", $Player.ENERGY)
		if tilemap.get_cellv(ppos) == 8: # check for on head
			 $SlurpPlayer.play(5.5)
			 tilemap.set_cellv(ppos, -1)
			 $Player.set("current_energy", $Player.ENERGY)
		elif tilemap.get_cellv(ppos_top) == 6: # check for end
			if not _next_scene_mutex:
				_next_scene()
		
		var energy_level = $Player.current_energy
		var darkness =  1-($Player.ENERGY - energy_level)/($Player.ENERGY*2)
		
		$AudioPlayer.set("pitch_scale", darkness*darkness*darkness/2 + 0.7)
		
		var color = Color(darkness, darkness, darkness)
		_modulate(color)

func _limit_camera():
	if current_level_instance.has_node("CameraEnd"):
		$Player.get_node("Camera2D").limit_right = current_level_instance.get_node("CameraEnd").position.x
	else:
		$Player.get_node("Camera2D").limit_right = 4096

func _modulate(color):
	set("modulate", color)
	var parallax_layers = get_node("ParallaxBackground").get_children()
	for layer in parallax_layers:
		layer.set("modulate", color)
