
import os

tres_path = r"c:\Users\User\Desktop\pixel arabi game hs\resources\tilesets\island1_tileset.tres"
texture_path = "res://assets/island1/Tileset.png"

header = f"""[gd_resource type="TileSet" load_steps=3 format=3]

[ext_resource type="Texture2D" path="{texture_path}" id="1_tex"]

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_xx"]
texture = ExtResource("1_tex")
"""

with open(tres_path, "w", encoding="utf-8") as f:
    f.write(header)
    for y in range(16):
        for x in range(16):
            f.write(f"{x}:{y}/0 = 0\n")
    
    f.write("""
[resource]
sources/0 = SubResource("TileSetAtlasSource_xx")
""")

print(f"Created {tres_path}")
