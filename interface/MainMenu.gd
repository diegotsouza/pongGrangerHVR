extends Control

var AVAILABLE_MENUES = load('res://interface/available_menus.gd').AVAILABLE_MENUES
var current_menu


func _ready():
	current_menu = AVAILABLE_MENUES.Initial
	get_tree().connect("network_peer_connected", self, "Success")
	_change_menu_to(current_menu)

func _show_initial_menu():
	_change_menu_to(AVAILABLE_MENUES.Initial)

func _change_menu_to(menu):
	match menu:
		AVAILABLE_MENUES.Host:
			_hide_all_menues()
			current_menu = menu
			$HostMenu.show()
		AVAILABLE_MENUES.Initial:
			_hide_all_menues()
			current_menu = menu
			$InitialMenu.show()
		AVAILABLE_MENUES.Client:
			_hide_all_menues()
			current_menu = menu
			$ClientMenu.show()
		_:
			printerr("Can't switch to menu ", menu, " because it is not valid!")

func _hide_all_menues():
	for menu in get_children():
		menu.hide()

func Success(id):
	Autoload.player_ids.append(id)
	if Autoload.player_ids.size() == 1:
		var a = preload("res://Level/Level.tscn").instance()
		get_tree().root.add_child(a)
		queue_free()
