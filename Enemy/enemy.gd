extends Node2D

@onready var tile_map = $"../TileMap"

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var player = null

var is_moving = false

var is_attacking = false

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(1024, 1024)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

	for x in range(tile_map.get_used_rect().size.x):
		for y in range(tile_map.get_used_rect().size.y):
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)

			var tile_data = tile_map.get_cell_tile_data(0, tile_position)

			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)

func _input(event):
	if player == null:
		return

	var id_path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position / tile_map.scale),
		tile_map.local_to_map(player.position / tile_map.scale)
	).slice(1)

	if id_path.is_empty() == false:
		current_id_path = id_path

func _physics_process(delta):
	if current_id_path.is_empty() or is_moving:
		return

	var target_position = tile_map.map_to_local(current_id_path.front()) * tile_map.scale
	
	if is_moving == false and target_position != player.position:
		is_moving = true
		move_to_position(target_position)

func move_to_position(target_position):
	global_position = target_position
	$MoveTimer.start()
	
	if global_position == target_position:
		current_id_path.pop_front()

func attack(direction):
	is_attacking = false
	if direction == 'right':
		$AttackArea2D.rotation_degrees = 0
	elif direction == 'left':
		$AttackArea2D.rotation_degrees = 180
	elif direction == 'up':
		$AttackArea2D.rotation_degrees = 270
	elif direction == 'down':
		$AttackArea2D.rotation_degrees = 90
	$AnimationPlayer.play("attack")

func _on_player_detection_area_2d_body_entered(body):
	player = body


func _on_move_timer_timeout():
	is_moving = false


func _on_player_detection_area_2d_body_exited(body):
	pass
	



func _on_attack_area_2d_body_entered(body):
	$AttackTimer.start()
	is_attacking = true


func _on_animation_player_animation_finished(anim_name):
	pass # Replace with function body.


func _on_right_detection_area_2d_body_entered(body):
	attack('right')


func _on_left_detection_area_2d_body_entered(body):
	attack('left')


func _on_up_detection_area_2d_body_entered(body):
	attack('up')


func _on_down_detection_area_2d_body_entered(body):
	attack('down')


func _on_attack_area_2d_body_exited(body):
	is_attacking = false


func _on_attack_timer_timeout():
	if is_attacking == true:
		player.take_damage()
