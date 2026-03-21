@tool
extends SceneTree

func _init():
	var file = FileAccess.open("res://scenes/levels/Level_01.tscn", FileAccess.READ)
	var content = file.get_as_text()
	var regex = RegEx.new()
	regex.compile("tile_data = PackedByteArray\\(\"(.*?)\"\\)")
	
	var all_matches = regex.search_all(content)
	if all_matches.size() >= 2:
		# all_matches[0] is Decorations, all_matches[1] is TileMapLayer
		var data_str = all_matches[1].get_string(1)
		var data = Marshalls.base64_to_raw(data_str)
		
		print("TileMapLayer specific tiles mapping test:")
		var counts = {}
		for i in range(0, min(data.size(), 120), 12):
			if i + 12 > data.size(): break
			var b_val = (data[i+4] | (data[i+5] << 8) | (data[i+6] << 16) | (data[i+7] << 24))
			var src_id = (b_val >> 16) & 0xFFFF
			var atlas_x = b_val & 0xFFFF
			
			var c_val = (data[i+8] | (data[i+9] << 8) | (data[i+10] << 16) | (data[i+11] << 24))
			var atlas_y = c_val & 0xFFFF
			var alt = (c_val >> 16) & 0xFFFF
			
			var key = "Src:%d Atlas:(%d,%d) Alt:%d" % [src_id, atlas_x, atlas_y, alt]
			counts[key] = counts.get(key, 0) + 1
			print("Tile at bytes %d: %s" % [i, key])
	quit()
