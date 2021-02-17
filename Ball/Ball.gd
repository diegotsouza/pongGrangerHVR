extends KinematicBody2D

var speed = 600
var velocity = Vector2.ZERO
var last_delta = 0
var sum_delta = 0

func _ready():
	pass

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		restart_ball()

func _physics_process(delta):
	sum_delta += delta
	var collision_object = move_and_collide(velocity * speed * delta)
	#if(sum_delta - last_delta) > 0.03:
		
	#	last_delta = sum_delta
	if collision_object:
		#$CollisionSound.play()
		velocity = velocity.bounce(collision_object.normal)
		if Autoload.net_id == 1:
			rpc("sync_ball", velocity, position)
		else:
			pass


func stop_ball():
	speed = 0

func restart_ball():
	speed = 600
	if Autoload.net_id == 1:
		randomize()
		var initial_x = [-1,1][randi() % 2]
		var initial_y = [-0.8,0.8][randi() % 2]
		start_ball(initial_x, initial_y, position)
		rpc("start_ball", initial_x, initial_y, position)
#	else:
#		randomize()
#		var initial_x = [-1,1][randi() % 2]
#		var initial_y = [-0.8,0.8][randi() % 2]
#		start_ball(initial_x, initial_y, position)

remote func start_ball(initial_x, initial_y, new_position):
	position = new_position
	velocity.x = initial_x
	velocity.y = initial_y

remote func sync_ball(new_velocity, new_position):
	position = new_position
	velocity = new_velocity
