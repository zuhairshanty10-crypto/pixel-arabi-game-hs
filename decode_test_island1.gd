@tool
extends SceneTree

func _init():
	var base64_str = "AACy/1sAAAAMAAkAAACz/1sAAAANAAkAAACy/1oAAAAMAAgAAACz/1oAAAANAAgAAACy/1kAAAAMAAcAAADq/1QAAAAkAAkAAADq/1MAAAAkAAgAAADs/1QAAAAkAAUAAADs/1MAAAAkAAQAAACm/1QAAAAQAAQAAACn/1QAAAARAAQAAACm/1MAAAAQAAMAAACn/1MAAAARAAMAAACm/1IAAAAQAAIAAACl/1IAAAAPAAIAAACn/1IAAAARAAIAAACo/1MAAAASAAMAAACo/1IAAAASAAIAAACo/1EAAAASAAEAAACn/1EAAAARAAEAAACm/1EAAAAQAAEAAACm/1AAAAAQAAAAAACn/1AAAAARAAAAAACp/1QAAAAVAAUAAACp/1MAAAAVAAQAAAA="
	var data = Marshalls.base64_to_raw(base64_str)
	var sources = {}
	
	for i in range(0, data.size(), 12):
		if i + 12 > data.size(): break
		var b_val = (data[i+4] | (data[i+5] << 8) | (data[i+6] << 16) | (data[i+7] << 24))
		var src_id = (b_val >> 16) & 0xFFFF
		if src_id != 65535:
			sources[src_id] = true
			
	print("Island 1 decorations tiles sources:")
	var keys = sources.keys()
	keys.sort()
	print(keys)
	quit()
