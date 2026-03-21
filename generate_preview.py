import os

folder = r'C:\Users\User\Desktop\craftpix-net-775352-game-user-interface-pixel-art\3 Icons\Icon with back'
files = [f for f in os.listdir(folder) if f.startswith('Icon_') and f.endswith('.png')]
files.sort(key=lambda x: int(x.split('_')[1].split('.')[0]))

html_content = '''<html>
<body style="background: #222; color: white; display: flex; flex-wrap: wrap; gap: 5px;">
'''

for f in files:
    path = os.path.join(folder, f).replace('\\', '/')
    html_content += f'<div style="text-align:center; margin: 5px;"><img src="file:///{path}" width="80" height="80"><br>{f}</div>\n'

html_content += '</body></html>'

with open(r'c:\Users\User\Desktop\pixel arabi game hs\preview.html', 'w', encoding='utf-8') as fh:
    fh.write(html_content)
