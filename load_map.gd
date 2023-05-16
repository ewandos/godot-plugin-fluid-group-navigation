extends Control

signal clicked_load_map(map_name: String)

@onready var map_list := $VBox/MapList as ItemList
@onready var load_button := $VBox/LoadButton as Button

var map_names := PackedStringArray()

func _ready() -> void:
	load_button.pressed.connect(_on_load_button_pressed)

func _on_load_button_pressed() -> void:
	if not map_list.is_anything_selected(): return
	var selected_map_name_index := map_list.get_selected_items()[0] as int
	clicked_load_map.emit(map_names[selected_map_name_index])

func _update_map_list() -> void:
	if map_list == null: return
	map_list.clear()
	map_names = DirAccess.get_files_at('res://maps')
	for map_name in map_names:
		map_list.add_item(map_name)

func _on_visibility_changed() -> void:
	_update_map_list()
