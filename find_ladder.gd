extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/island3/tiles/Medieval_props_free.png")
	if not img:
		print("Failed")
		quit()
		return
	
	print("Size: ", img.get_size())
	
	# Find all non-transparent pixels, cluster them into bounding boxes
	var w = img.get_width()
	var h = img.get_height()
	var visited = []
	for y in range(h):
		visited.append([])
		for x in range(w):
			visited[y].append(false)
			
	var components = []
	for y in range(h):
		for x in range(w):
			if visited[y][x]: continue
			var c = img.get_pixel(x, y)
			if c.a == 0:
				visited[y][x] = true
				continue
				
			# BFS
			var min_x = x
			var max_x = x
			var min_y = y
			var max_y = y
			
			var queue = [Vector2i(x,y)]
			visited[y][x] = true
			
			while queue.size() > 0:
				var p = queue.pop_front()
				if p.x < min_x: min_x = p.x
				if p.x > max_x: max_x = p.x
				if p.y < min_y: min_y = p.y
				if p.y > max_y: max_y = p.y
				
				for dx in [-1,0,1]:
					for dy in [-1,0,1]:
						var nx = p.x + dx
						var ny = p.y + dy
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							if not visited[ny][nx] and img.get_pixel(nx, ny).a > 0.1:
								visited[ny][nx] = true
								queue.append(Vector2i(nx,ny))
								
			components.append({"rect": Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)})

	# Print components that could be ladders (tall and somewhat wide)
	for comp in components:
		var r = comp.rect
		if r.size.y > 20:
			print("Found object at: ", r.position, " size: ", r.size)
		
	quit()
