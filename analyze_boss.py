from PIL import Image
import os

files = ["boss_analysis_Idle.png", "boss_analysis_Attack3.png", "boss_analysis_Attack5.png", "boss_analysis_Attack7_body.png", "boss_analysis_Special.png"]

for f in files:
    if not os.path.exists(f): continue
    img = Image.open(f).convert("RGBA")
    w, h = img.size
    
    # check bottom corners to see if hands are there
    left_hand_area = img.crop((0, int(h*0.6), int(w*0.3), h))
    right_hand_area = img.crop((int(w*0.7), int(h*0.6), w, h))
    
    left_pixels = sum(1 for p in left_hand_area.getdata() if p[3] > 0)
    right_pixels = sum(1 for p in right_hand_area.getdata() if p[3] > 0)
    
    print(f"{f}: Left corner alpha={left_pixels}, Right corner alpha={right_pixels}")
