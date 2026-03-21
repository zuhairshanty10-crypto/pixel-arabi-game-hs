Add-Type -AssemblyName System.Drawing
 $img = [System.Drawing.Bitmap]::FromFile('c:\Users\User\Desktop\pixel arabi game hs\assets\island2\traps\Magic_trap\Magic trap - Level 1.png')
 $hframes = 25
 $frameW = $img.Width / $hframes
 $frameH = $img.Height
 $visible = @()
 for ($f = 0; $f -lt $hframes; $f++) {
     $hasPixels = $false
     for ($y = 0; $y -lt $frameH; $y+=2) {
         for ($x = 0; $x -lt $frameW; $x+=2) {
             if ($img.GetPixel($f * $frameW + $x, $y).A -gt 10) { $hasPixels = $true; break }
         }
         if ($hasPixels) { break }
     }
     if ($hasPixels) { $visible += $f }
 }
 $img.Dispose()
 Write-Output 'Magic Visible Frames:'
 Write-Output ($visible -join ', ')