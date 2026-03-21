@tool
extends SceneTree

func _init():
	var scene = ResourceLoader.load("res://scenes/levels/Level_01.tscn")
	var instance = scene.instantiate()
	var layer = instance.get_node("TileMapLayer")
	
	if layer:
		print("Found TileMapLayer!")
		var used = layer.get_used_cells()
		print("Used cells count: ", used.size())
		
		# Sample first 10 cells
		for i in range(min(10, used.size())):
			var pos = used[i]
			var src = layer.get_cell_source_id(pos)
			var atlas = layer.get_cell_atlas_coords(pos)
			var alt = layer.get_cell_alternative_tile(pos)
			print("Cell ", pos, " -> Src:", src, " Atlas:", atlas, " Alt:", alt)
	else:
		print("TileMapLayer not found.")
		
	var layer2 = instance.get_node("Decorations")
	if layer2:
		print("Found Decorations Layer!")
		var used2 = layer2.get_used_cells()
		for i in range(min(10, used2.size())):
			var pos = used2[i]
			var src = layer2.get_cell_source_id(pos)
			var atlas = layer2.get_cell_atlas_coords(pos)
			var alt = layer2.get_cell_alternative_tile(pos)
			print("Deco ", pos, " -> Src:", src, " Atlas:", atlas, " Alt:", alt)
			
	quit()
