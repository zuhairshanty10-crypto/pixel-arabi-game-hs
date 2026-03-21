from PIL import Image

def find_visible_frames():
    img_path = r'c:\Users\User\Desktop\pixel arabi game hs\assets\island2\traps\Arrow_Trap\Arrow Trap - Level 1.png'
    try:
        img = Image.open(img_path)
        img = img.convert('RGBA')
        
        hframes = 51
        frame_w = img.width // hframes
        frame_h = img.height
        
        visible_frames = []
        
        for f in range(hframes):
            start_x = f * frame_w
            has_pixels = False
            
            # Check a grid to speed it up
            for y in range(0, frame_h, 2):
                for x in range(0, frame_w, 2):
                    r, g, b, a = img.getpixel((start_x + x, y))
                    if a > 10:
                        has_pixels = True
                        break
                if has_pixels:
                    break
                    
            if has_pixels:
                visible_frames.append(f)
                
        print("VISIBLE FRAMES:", visible_frames)
    except Exception as e:
        print("Error:", e)

find_visible_frames()