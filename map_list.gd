extends ItemList

func _ready() -> void:
	clear()
	var map_names: PackedStringArray = DirAccess.get_files_at('res://maps')
	for map_name in map_names:
		add_item(map_name)
