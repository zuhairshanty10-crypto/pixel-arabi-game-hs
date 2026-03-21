extends Node

# Autoload to handle background music and global sound effects.

@onready var music_player = $MusicPlayer

# Preload some common sounds if we want, or we let scenes pass streams.
# We'll assign the BGM stream via the editor or code here.

var menu_theme = preload("res://assets/sounds/Menu_Theme.mp3")
var island1_theme = preload("res://assets/music/Pixel Arabi - Menu Theme12.mp3")
var island2_theme = preload("res://assets/sounds/Island2_Theme.mp3")
var island4_theme = preload("res://assets/island4/music/Dark_ambient_loopable.mp3")

func _ready() -> void:
	# Start playing the main theme right away
	play_music(menu_theme)

func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return # Already playing this music
		
	music_player.stream = stream
	music_player.play()

func play_menu_music() -> void:
	play_music(menu_theme)

func play_island1_music() -> void:
	play_music(island1_theme)

func play_island2_music() -> void:
	play_music(island2_theme)

func play_island4_music() -> void:
	play_music(island4_theme)

func stop_music() -> void:
	music_player.stop()

# Helper to play one-shot 2D or UI sound effects loosely if needed
func play_sfx(stream: AudioStream) -> void:
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(func(): sfx_player.queue_free())
