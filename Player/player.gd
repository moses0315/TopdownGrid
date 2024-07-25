extends CharacterBody2D

var health = 100

var is_moving = false
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
	#if event.as_text() in ["W", "A", "S", "D"]:
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
	if not is_moving:
		move(movement_direction)
	if not attacking:
		attack()
		


func move(dir):
	if movement_direction != "still":
		
		ray.target_position = inputs[dir] * grid_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			is_moving = true
			position += inputs[dir] * grid_size
			await get_tree().create_timer(0.25).timeout
			is_moving = false

func attack():
	if Input.is_action_pressed("attack"):
		$AttackArea.visible = true
		$AnimationPlayer.play("attack")
		attacking = true

func take_damage():
	health -= 10
	$Label.text = str(health)
	await get_tree().create_timer(0.2).timeout
	$Label.text = ""
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		attacking = false


func _on_attack_area_body_entered(body):
	print("enemy hurt")
