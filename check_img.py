from PIL import Image
try:
    with Image.open("assets/island1/Tileset.png") as img:
        print(f"Dimensions: {img.size}")
except Exception as e:
    print(f"Error: {e}")
