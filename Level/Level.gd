extends Node


var PlayerScore = 0
var OpponentScore = 0
var _timer = null
#var pause_ball = false

export var OUTFILE = "savegame.save"
var test =  OS.get_datetime()

#onready var state =  get_node("Player")
onready var timer = get_node("Timer")
onready var pb = get_node("ProgressBar")
onready var http_request = HTTPRequest.new()

#func myprint(num):
#	print(num)
#	return(num)
	
#var testp = myprint(21)
const BAR_SPEED = 5
var current_bar_value

func _ready():
	Autoload.net_id = get_tree().get_network_unique_id()
	timer.set_wait_time(1260)
	timer.start()
	
	# Create a request every second
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(0.5)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	
	# Create an HTTP request node and connect its completion signal.
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")



func _on_Left_body_entered(body):
	OpponentScore += 1
	score_achieved()


func _on_Right_body_entered(body):
	PlayerScore += 1
	score_achieved()

var count = 0
var limit = 60
var partialDataGame = {}

func _process(delta):
	current_bar_value = timer.time_left
	# Don't go below zero
	current_bar_value = max(current_bar_value, 0)
	
	pb.value =  current_bar_value
	set_state(current_bar_value)
	
	$PlayerScore.text = str(PlayerScore)
	$OpponentScore.text = str(OpponentScore)
	$CountdownLabel.text = str(int($CountdownTimer.time_left) + 1)
	count += delta
	if count < limit:
		partialDataGame[str(count)] = recordData()
	else:
		#ave_game(partialDataGame)
		limit += 60
		partialDataGame.clear()
	


func _on_CountdownTimer_timeout():
	get_tree().call_group('BallGroup','restart_ball')
	$CountdownLabel.visible = false


func score_achieved():
	#save_game()
	$Ball.position = Vector2(640,360)
	#if not $Ball.state and Autoload.net_id == 1:
	if (not $Ball.state and (Autoload.net_id == 1 or Autoload.net_id != 1)):
		get_tree().call_group('BallGroup','stop_ball')
		restart_local_countdown()
	else:
		get_tree().call_group('BallGroup','stop_ball')
		$CountdownTimer.start()
		$CountdownLabel.visible = true
		$ScoreSound.play()
		$Player.position.x = 35
		$Opponent.position.x = 1280 - 35
		rpc("restart_countdown")
	

func myDate ():
	var date = OS.get_datetime()
	
	var formatedtime = str(date["year"], "-", date["month"], "-", date["day"], " ",
	 date["hour"], ":", date["minute"], ":", date["second"])
	return (formatedtime)
	
func recordData ():
	var gameData = {
	'datatype': 1,
	'datetime': myDate(),
	'ticksTime': OS.get_ticks_msec(),
	'DeviceID': OS.get_unique_id(),
	'BallPosX': $Ball.position.x,
	'BallPosY': $Ball.position.y,
	'BallSpeed': $Ball.speed,
	'Player1X': $Player.position.x,
	'Player1Y': $Player.position.y,
	'Player2X': $Opponent.position.x,
	'Player2Y': $Opponent.position.y,
	'ScorePlayer1': PlayerScore,
	'ScorePlayer2': OpponentScore,
	'Player1State': $Player.state,
	'Player2State': $Opponent.state
	}
	return gameData

# Note: This can be called from anywhere inside the tree.  This function is path independent.
# Go through everything in the persist category and ask them to return a dict of relevant variables
func save_game(partialDataGame):
	var savegame = File.new()
	#var inventory = recordData()
	if !savegame.file_exists(OUTFILE):
		savegame.open(OUTFILE, File.WRITE)
		savegame.store_line(to_json(partialDataGame))
		savegame.close()
	else:
		savegame.open(OUTFILE, File.READ_WRITE)
		savegame.seek_end()
		savegame.store_line(to_json(partialDataGame))
		savegame.close()

func restart_local_countdown():
	$CountdownTimer.start()
	$CountdownLabel.visible = true
	$ScoreSound.play()
	$Player.position.x = 35
	$Opponent.position.x = 1280 - 35
	
remote func restart_countdown():
	$CountdownTimer.start()
	$CountdownLabel.visible = true
	$ScoreSound.play()
	$Player.position.x = 35
	$Opponent.position.x = 1280 - 35

func set_state (time):
	if int(time) <= 420:
		$Player.state = true
		$Opponent.state = true
		$Ball.state = true
	else:
		if int(time) <= 840:
			$Player.state = false
			$Opponent.state = false
			$Ball.state = false
		else:
			$Player.state = true
			$Opponent.state = true
			$Ball.state = true

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
		var response = parse_json(body.get_string_from_utf8())


func _on_Timer_timeout():
	# Perform the HTTP request. The URL below returns some JSON as of writing.
	var fields = recordData()
	http_request.request("http://127.0.0.1:5000/flask",PoolStringArray(['Content-Type: application/json']), false, 2, to_json(fields))

