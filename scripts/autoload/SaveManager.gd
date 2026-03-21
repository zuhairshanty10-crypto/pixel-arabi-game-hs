extends Node

const SAVE_PATH = "user://pixel_arabi_save.json"

func _ready() -> void:
	load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_game()

func save_game() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")

	var save_dict = {
		"game_progress": {
			"deaths_total": GameManager.deaths_total,
			"level_data": GameManager.level_data,
			"is_hardcore_mode": GameManager.is_hardcore_mode,
			"hardcore_lives": GameManager.hardcore_lives,
			"hardcore_attempts_left": GameManager.hardcore_attempts_left
		},
		"settings": {
			"music_vol": db_to_linear(AudioServer.get_bus_volume_db(music_bus)),
			"sfx_vol": db_to_linear(AudioServer.get_bus_volume_db(sfx_bus)),
			"fps_limit": Engine.max_fps,
			"language": Localization.current_language if Localization else "en"
		}
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_dict)
		file.store_line(json_string)
		file.close()
		print("Game saved successfully to ", FileAccess.get_open_error())

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return # No save file yet
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			
			if "game_progress" in data:
				var prog = data["game_progress"]
				if "deaths_total" in prog: GameManager.deaths_total = int(prog["deaths_total"])
				if "level_data" in prog: GameManager.level_data = prog["level_data"]
				if "is_hardcore_mode" in prog: GameManager.is_hardcore_mode = bool(prog["is_hardcore_mode"])
				if "hardcore_lives" in prog: GameManager.hardcore_lives = int(prog["hardcore_lives"])
				if "hardcore_attempts_left" in prog: GameManager.hardcore_attempts_left = int(prog["hardcore_attempts_left"])
				
			if "settings" in data:
				var stgs = data["settings"]
				var music_bus = AudioServer.get_bus_index("Music")
				var sfx_bus = AudioServer.get_bus_index("SFX")
						
				if "music_vol" in stgs:
					AudioServer.set_bus_volume_db(music_bus, linear_to_db(stgs["music_vol"]))
					if stgs["music_vol"] <= 0.01: AudioServer.set_bus_mute(music_bus, true)
					else: AudioServer.set_bus_mute(music_bus, false)

				if "sfx_vol" in stgs:
					AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(stgs["sfx_vol"]))
					if stgs["sfx_vol"] <= 0.01: AudioServer.set_bus_mute(sfx_bus, true)
					else: AudioServer.set_bus_mute(sfx_bus, false)

				if "fps_limit" in stgs:
					Engine.max_fps = int(stgs["fps_limit"])
				if "language" in stgs and Localization:
					Localization.current_language = stgs["language"]
