@tool
extends SceneTree

func _init():
	var file = FileAccess.open("res://scenes/levels/Level_01.tscn", FileAccess.READ)
	if not file:
		print("Failed to open file")
		quit()
		return
	var content = file.get_as_text()
	var regex = RegEx.new()
	regex.compile('\\[node name="(.*?)" type="TileMapLayer".*?tile_map_data = PackedByteArray\\( (.*?) \\)')
	var matches = regex.search_all(content)
	
	for m in matches:
		var name = m.get_string(1)
		var data_b64 = m.get_string(2).replace("\n", "").replace(" ", "")
		var data = Marshalls.base64_to_raw(data_b64)
		print("--- Layer: ", name, " ---")
		if data.size() < 8: continue
		for i in range(8, min(data.size(), 248), 12):
			var x = data.decode_s16(i)
			var y = data.decode_s16(i + 2)
			var source = data.decode_s16(i + 4)
			var atlas_x = data.decode_s16(i + 6)
			var atlas_y = data.decode_s16(i + 8)
			print("Pos: (", x, ", ", y, ") Source: ", source, " Atlas: (", atlas_x, ", ", atlas_y, ")")
	quit()
