extends KinematicBody2D

var speed = 500
var velocity = Vector2.ZERO
var last_delta = 0
var sum_delta = 0
var state = true

func _ready():
	pass

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		restart_ball()

func _physics_process(delta):
	#sum_delta += delta
	var collision_object = move_and_collide(velocity * speed * delta)
	if collision_object:
		#speed += delta
		velocity = velocity.bounce(collision_object.normal)
		####it's bad
		if collision_object.collider.name in ["Player", "Opponent"]:
			velocity *= 1.05
		#if Autoload.net_id == 1:
		if state and Autoload.net_id != 1:
			rpc("sync_ball", velocity, position)

func stop_ball():
	speed = 0

func restart_ball():
	speed = 500
	#if Autoload.net_id == 1:
	if state and Autoload.net_id != 1:
		randomize()
		var initial_x = [-1,1][randi() % 2]
		var initial_y = [-0.8,0.8][randi() % 2]
		start_ball(initial_x, initial_y, position)
		rpc("start_ball", initial_x, initial_y, position)
	elif (not state and (Autoload.net_id != 1 or Autoload.net_id == 1)):
		randomize()
		velocity.x = [-1,1][randi() % 2]
		velocity.y = [-0.8,0.8][randi() % 2]


remote func start_ball(initial_x, initial_y, new_position):
	position = new_position
	velocity.x = initial_x
	velocity.y = initial_y

remote func sync_ball(new_velocity, new_position):
	position = new_position
	velocity = new_velocity
