Add-Type -AssemblyName System.Drawing
 $img = [System.Drawing.Bitmap]::FromFile('c:\Users\User\Desktop\pixel arabi game hs\assets\player\Idle.png')
 $frameW = 128
 $frameH = 128
 
 $minY = 999
 $maxY = 0
 $minX = 999
 $maxX = 0
 
 # Just look at the first frame (0 to 127)
 for ($y = 0; $y -lt $frameH; $y++) {
     for ($x = 0; $x -lt $frameW; $x++) {
         if ($img.GetPixel($x, $y).A -gt 10) {
             if ($y -lt $minY) { $minY = $y }
             if ($y -gt $maxY) { $maxY = $y }
             if ($x -lt $minX) { $minX = $x }
             if ($x -gt $maxX) { $maxX = $x }
         }
     }
 }
 Write-Output "Character Bounding Box in 128x128 frame:"
 Write-Output "MinY (top): $minY"
 Write-Output "MaxY (bottom): $maxY"
 Write-Output "MinX (left): $minX"
 Write-Output "MaxX (right): $maxX"
 Write-Output "Height: $($maxY - $minY + 1)"
 Write-Output "Width: $($maxX - $minX + 1)"
 $img.Dispose()