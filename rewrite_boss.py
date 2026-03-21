import json

file_path = 'c:/Users/User/Desktop/pixel arabi game hs/scripts/enemies/Boss.gd'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()
    
new_lines = []
skip = False
for i, line in enumerate(lines):
    new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
