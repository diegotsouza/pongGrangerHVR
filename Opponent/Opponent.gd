extends KinematicBody2D

var speed = 400
var ball 
var is_master = false
var state = true

export var area_min = 0
export var area_max = 0

func _ready():
	ball = get_parent().find_node("Ball")


func get_opponent_direction():
	if abs(ball.position.y - position.y) > 20 \
	and (ball.velocity.x > 0 or (ball.position.x > 640 and ball.velocity.x < 0)):
		if ball.position.y > position.y: return 1
		else:return -1
	else: return 0

	
func _physics_process(delta):
	if state and Autoload.net_id != 1:
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		move_and_slide(velocity * speed)
		rpc_unreliable("set_pos", position)
	elif Autoload.net_id != 1:
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		move_and_slide(velocity * speed)
	elif not state and Autoload.net_id == 1:
		move_and_slide(Vector2(0,get_opponent_direction()) * speed)

	
func initialize(id):
	is_master = id == Autoload.player_ids[1]

remote func set_pos(pos):
	position = pos
