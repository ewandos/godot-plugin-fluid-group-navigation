extends Control

signal clicked_save_map(map_name: String)

@onready var button := $HBox/Button
@onready var text_edit := $HBox/TextEdit

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func set_map_name(map_name: String) -> void:
	text_edit.text = map_name

func _on_button_pressed() -> void:
	var map_name: String = text_edit.text
	if map_name.is_empty():
		print('No map name provided')
		return
	clicked_save_map.emit(map_name)
