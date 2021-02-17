extends VBoxContainer

signal changed_menu

var AVAILABLE_MENUES = load('res://interface/available_menus.gd').AVAILABLE_MENUES
#var path = "res://interface/InitialMenu.gd"

func _ready():
	#ResourceLoader.load(path)
	show()

func _on_Host_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Host)

func _on_Join_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Client)
