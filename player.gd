#extends CharacterBody2D

#@onready var ray = $RayCast2D
#var grid_size = 128
#var inputs = {
	#"ui_up": Vector2.UP,
	#"ui_down": Vector2.DOWN,
	#"ui_left": Vector2.LEFT,
	#"ui_right": Vector2.RIGHT
#}
#var is_moving = false
#var attacking = false

#func _physics_process(delta):
	##for dir in inputs.keys():
		##if Input.is_action_pressed(dir) and not is_moving:
			##is_moving = true
			##$Timer.start()
			##move(dir)
	#
	#if Input.is_action_pressed("ui_up"):
		#velocity.y -=1
		#direction 
	#
	#if not attacking:
		#attack()
		#
#func move(dir):
	#var vector_pos = inputs[dir] * grid_size
	#ray.target_position = vector_pos
	#ray.force_raycast_update()
	#if not ray.is_colliding():
		#position += vector_pos
#

	

extends CharacterBody2D

@export var speed = 2
var moving = false
var grid_size = 128
var movement_direction = "still"

var attacking = false

var inputs = {
	"moveright": Vector2.RIGHT,
	"moveleft": Vector2.LEFT,
	"moveup": Vector2.UP,
	"movedown": Vector2.DOWN,
	"still": Vector2.ZERO
}

@onready var ray = $RayCast2D


var pressed = []

func _input(event):
	if event.as_text() in ["W", "A", "S", "D"]:
		if event.is_action_pressed("moveright"):
			pressed.append("moveright")
		elif event.is_action_pressed("moveleft"):
			pressed.append("moveleft")
		elif event.is_action_pressed("moveup"):
			pressed.append("moveup")
		elif event.is_action_pressed("movedown"):
			pressed.append("movedown")

		if event.is_action_released("moveright"):
			pressed.erase("moveright")
		elif event.is_action_released("moveleft"):
			pressed.erase("moveleft")
		elif event.is_action_released("moveup"):
			pressed.erase("moveup")
		elif event.is_action_released("movedown"):
			pressed.erase("movedown")

		if len(pressed) > 0:
			movement_direction = pressed[-1]
			
		else:
			movement_direction = "still"

func _process(_delta):
	if not moving:
		move(movement_direction)
	if not attacking:
		attack()
		


func move(dir):
	if movement_direction != "still":
		ray.target_position = inputs[dir] * grid_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			moving = true
			position += inputs[dir] * grid_size
			await get_tree().create_timer(0.2).timeout
			moving = false

func attack():
	if Input.is_action_pressed("attackup"):
		$AttackArea.position = Vector2(0, -grid_size)
		$AttackArea/AnimationPlayer.play("attack")
		attacking = true
	if Input.is_action_pressed("attackdown"):
		$AttackArea.position = Vector2(0, grid_size)
		$AttackArea/AnimationPlayer.play("attack")
		attacking = true
	if Input.is_action_pressed("attackleft"):
		$AttackArea.position = Vector2(-grid_size, 0)
		$AttackArea/AnimationPlayer.play("attack")
		attacking = true
	if Input.is_action_pressed("attackright"):
		$AttackArea.position = Vector2(grid_size, 0)
		$AttackArea/AnimationPlayer.play("attack")
		attacking = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		attacking = false
