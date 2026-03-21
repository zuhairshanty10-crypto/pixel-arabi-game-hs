import re

file_path = r'c:\Users\User\Desktop\pixel arabi game hs\scenes\player\Player.tscn'

with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Add ExtResource
last_ext_idx = text.rfind('[ext_resource')
end_of_last_ext = text.find(']', last_ext_idx) + 1

# Generate new IDs
ext_crouch = '[ext_resource type="Texture2D" uid="uid://crouch_new" path="res://assets/player/Sit down.png" id="11_crouch"]'
ext_roll = '[ext_resource type="Texture2D" uid="uid://roll_new" path="res://assets/player/Roll.png" id="12_roll"]'

new_exts = f'\n{ext_crouch}\n{ext_roll}'

text = text[:end_of_last_ext] + new_exts + text[end_of_last_ext:]


# 2. Add AtlasTextures
# Find start of SpriteFrames
sprite_frames_idx = text.find('[sub_resource type="SpriteFrames"')
if sprite_frames_idx == -1:
    print("Cannot find SpriteFrames definition.")
    exit(1)

atlas_textures = []

# Sit down (6 frames)
for i in range(6):
    atlas_textures.append(f'''[sub_resource type="AtlasTexture" id="AtlasTexture_crouch_{i}"]\natlas = ExtResource("11_crouch")\nregion = Rect2({i*128}, 0, 128, 128)\n''')

# Roll (7 frames)
for i in range(7):
    atlas_textures.append(f'''[sub_resource type="AtlasTexture" id="AtlasTexture_roll_{i}"]\natlas = ExtResource("12_roll")\nregion = Rect2({i*128}, 0, 128, 128)\n''')

new_atlas = '\n\n'.join(atlas_textures) + '\n\n'
text = text[:sprite_frames_idx] + new_atlas + text[sprite_frames_idx:]


# 3. Add to SpriteFrames array
# Find the end of the animations array
run_anim_end = text.find('"name": &"run",')
if run_anim_end == -1:
    print("Cannot find run animation in SpriteFrames.")
    exit(1)

end_of_run_dict = text.find('}', run_anim_end) + 1

# Craft new dictionaries
# Crouch
crouch_frames = ',\n'.join([f'{{"duration": 1.0, "texture": SubResource("AtlasTexture_crouch_{i}")}}' for i in range(6)])
crouch_dict = f''', {{
"frames": [{crouch_frames}],
"loop": true,
"name": &"crouch",
"speed": 8.0
}}'''

# Roll
roll_frames = ',\n'.join([f'{{"duration": 1.0, "texture": SubResource("AtlasTexture_roll_{i}")}}' for i in range(7)])
roll_dict = f''', {{
"frames": [{roll_frames}],
"loop": false,
"name": &"roll",
"speed": 12.0
}}'''

text = text[:end_of_run_dict] + crouch_dict + roll_dict + text[end_of_run_dict:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("SUCCESS")
