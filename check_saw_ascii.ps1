Add-Type -AssemblyName System.Drawing
 $img = [System.Drawing.Bitmap]::FromFile('c:\Users\User\Desktop\pixel arabi game hs\assets\island2\traps\Saw_Trap\Saw Trap - Level 1.png')
 $frameW = 64
 $frameH = 64
 $output = ''
 for ($y = 0; $y -lt $frameH; $y += 2) {
     $line = ''
     for ($x = 0; $x -lt $frameW; $x += 2) {
         if ($img.GetPixel($x, $y).A -gt 50) { $line += '#' } else { $line += '.' }
     }
     $output += $line + "
"
 }
 $img.Dispose()
 Write-Output $output