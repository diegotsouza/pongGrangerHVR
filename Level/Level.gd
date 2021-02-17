extends Node

var PlayerScore = 0
var OpponentScore = 0
#var pause_ball = false

export var OUTFILE = "savegame.save"
var test =  OS.get_datetime()

#onready var state =  get_node("Player")
onready var timer = get_node("Timer")
onready var pb = get_node("ProgressBar")
#func myprint(num):
#	print(num)
#	return(num)
	
#var testp = myprint(21)
const BAR_SPEED = 5
var current_bar_value

func _ready():
	Autoload.net_id = get_tree().get_network_unique_id()
	timer.set_wait_time(120)
	timer.start()


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
		save_game(partialDataGame)
		limit += 60
		partialDataGame.clear()


func _on_CountdownTimer_timeout():
	get_tree().call_group('BallGroup','restart_ball')
	$CountdownLabel.visible = false


func score_achieved():
	#save_game()
	
	$Ball.position = Vector2(640,360)
	if Autoload.net_id == 1:
		get_tree().call_group('BallGroup','stop_ball')
	else:
		get_tree().call_group('BallGroup','stop_ball')
		
		$CountdownTimer.start()
		$CountdownLabel.visible = true
		$ScoreSound.play()
		$Player.position.x = 35
		$Opponent.position.x = 1280 - 35
		rpc("restart_countdown")


func recordData ():
	var gameData = {
	'TicksTime': OS.get_time(),
	'BallPosX': $Ball.position.x,
	'BallPosY': $Ball.position.y,
	'BallSpeed': $Ball.speed,
	'Player1X': $Player.position.x,
	'Player1Y': $Player.position.y,
	'Player2X': $Opponent.position.x,
	'Player2Y': $Opponent.position.y,
	'ScorePlayer1': PlayerScore,
	'ScorePlayer2': OpponentScore
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

remote func restart_countdown():
	$CountdownTimer.start()
	$CountdownLabel.visible = true
	$ScoreSound.play()
	$Player.position.x = 35
	$Opponent.position.x = 1280 - 35

func set_state (time):
	if int(time) <= 40:
		$Player.state = true
		$Opponent.state = true
	else:
		if int(time) <= 80:
			$Player.state = false
			$Opponent.state = false
		else:
			$Player.state = true
			$Opponent.state = true

func _on_Timer_timeout():
	pass
