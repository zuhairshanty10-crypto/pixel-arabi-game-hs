Add-Type -AssemblyName System.Drawing
 $img = [System.Drawing.Bitmap]::FromFile('c:\Users\User\Desktop\pixel arabi game hs\assets\island2\traps\Saw_Trap\Saw Trap - Level 1.png')
 $hframes = 16
 $frameW = $img.Width / $hframes
 $frameH = $img.Height
 Write-Output 'Frame Size:'
 Write-Output "Width: $frameW, Height: $frameH"
 $img.Dispose()