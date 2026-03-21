import base64
import struct

def decode_tile_data(data_b64):
    data = base64.b64decode(data_b64)
    # Header: 8 bytes (version, flags, etc)
    # Tiles: 12 bytes each (x, y, source_id, atlas_x, atlas_y, alternative_id)
    tiles = []
    for i in range(8, len(data), 12):
        chunk = data[i:i+12]
        if len(chunk) < 12: break
        # x, y (i16), source_id (i16), atlas_x, atlas_y (i16), alternative_id (i16)
        x, y, source, atlas_x, atlas_y, alt = struct.unpack("<hhhhhh", chunk)
        tiles.append({"pos": (x, y), "source": source, "atlas": (atlas_x, atlas_y)})
    return tiles

with open(r"scenes\levels\Level_01.tscn", "r", encoding="utf-8") as f:
    content = f.read()

import re
layers = re.findall(r'\[node name="(.*?)" type="TileMapLayer".*?tile_map_data = PackedByteArray\( (.*?) \)', content, re.DOTALL)

for name, data in layers:
    print(f"--- Layer: {name} ---")
    tiles = decode_tile_data(data.replace("\n", "").replace(" ", ""))
    for t in tiles[:20]:
        print(t)
