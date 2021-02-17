extends VBoxContainer

signal changed_menu

var AVAILABLE_MENUES = load('res://interface/available_menus.gd').AVAILABLE_MENUES
#var path = "res://interface/HostlMenu.gd"

func _ready():
	#ResourceLoader.load(path)
	hide()


func _on_Back_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Initial)

func _on_Host_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(4242,2)
	get_tree().network_peer = net
