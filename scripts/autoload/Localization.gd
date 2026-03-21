extends Node

## Simple localization system for English/Arabic

signal language_changed

var current_language: String = "en"

# All translatable strings
var translations: Dictionary = {
	"start_game": {"en": "Start Game", "ar": "ابدأ اللعب"},
	"hardcore": {"en": "Hardcore", "ar": "هاردكور"},
	"how_to_play": {"en": "How to Play", "ar": "كيف تلعب"},
	"about_us": {"en": "About Us", "ar": "من نحن"},
	"settings": {"en": "Settings", "ar": "الإعدادات"},
	"exit": {"en": "Exit", "ar": "خروج"},
	"back": {"en": "Back", "ar": "رجوع"},
	"master_vol": {"en": "Master Volume", "ar": "الصوت العام"},
	"music_vol": {"en": "Music Volume", "ar": "صوت الموسيقى"},
	"sfx_vol": {"en": "SFX Volume", "ar": "المؤثرات الصوتية"},
	"fps_limit": {"en": "FPS Limit", "ar": "حد الإطارات"},
	"language": {"en": "Language", "ar": "اللغة"},
	
	"settings_title": {"en": "Settings", "ar": "الإعدادات"},
	"how_to_play_title": {"en": "How to Play", "ar": "كيف تلعب"},
	"about_us_title": {"en": "About Us", "ar": "من نحن"},
	"hardcore_title": {"en": "Hardcore", "ar": "هاردكور"},
	
	"how_to_play_desc": {
		"en": "Welcome to Pixel Arabi!\nA rage-inducing troll platformer!\nYour goal: reach the door at the end\nof each level... but beware!\nDon't trust anything you see.\nFloors may vanish, ceilings may fall,\nand even the doors might run away!",
		"ar": "مرحباً بك في بكسل عربي!\nلعبة منصات وفخاخ مستفزة!\nهدفك: الوصول إلى الباب\nفي نهاية كل مرحلة... لكن احذر!\nلا تثق بأي شيء تراه.\nالأرضيات قد تختفي والأسقف قد تسقط\nوحتى الأبواب قد تهرب منك!"
	},
	"about_us_desc": {
		"en": "A game proudly developed by\nPixel Arabi\n\nManaged by:\nZuhair Shanty\nIbrahim Murad",
		"ar": "لعبة من تطوير\nبكسل عربي\n\nبإدارة:\nزهير شنطي\nإبراهيم مراد"
	},
	"hardcore_desc": {
		"en": "This mode is for legends only!\nYou have 5 lives per attempt.\nLose all 5 and you restart from 1-1.\nEach player gets 5 total attempts.\nBeat the game before they run out\nand win $100!",
		"ar": "هذا الوضع للمحترفين فقط!\nعندك 5 ارواح بكل محاولة.\nاذا خسرتهم كلهم ترجع للبداية.\nعندك 5 محاولات بالمجمل.\nخلص اللعبة قبل ما يخلصوا\nواربح 100 دولار!"
	},
	
	"island_1": {"en": "Forest Island", "ar": "جزيرة الغابة"},
	"island_2": {"en": "Snow Island", "ar": "جزيرة الثلج"},
	"island_3": {"en": "Magic Island", "ar": "جزيرة السحر"},
	"island_4": {"en": "Enemies Island", "ar": "جزيرة الأعداء"},
	"island_5": {"en": "Replay Island", "ar": "جزيرة الإعادة"},
	"select_island": {"en": "Select Island", "ar": "اختر الجزيرة"},
	"select_level": {"en": "Select Level", "ar": "اختر المرحلة"},
	"level": {"en": "Level", "ar": "المرحلة"}
}

func get_text(key: String) -> String:
	if translations.has(key):
		var t = translations[key]
		if t.has(current_language):
			return t[current_language]
		elif t.has("en"):
			return t["en"]
	return key

func set_language(lang: String) -> void:
	current_language = lang
	language_changed.emit()
	if SaveManager:
		SaveManager.save_game()
