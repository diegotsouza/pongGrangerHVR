extends VBoxContainer

signal changed_menu

var AVAILABLE_MENUES = load('res://interface/available_menus.gd').AVAILABLE_MENUES
#var path = "res://interface/ClientMenu.gd"
var seted_ip

func _ready():
	#ResourceLoader.load(path)
	hide()

func _on_Back_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Initial)

func _on_Join_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_client(seted_ip,4242)
	get_tree().network_peer = net


func _on_PlayerName_text_changed(new_text):
	seted_ip = new_text
