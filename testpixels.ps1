Add-Type -AssemblyName System.Drawing
$imgPath = "c:\Users\User\Desktop\pixel arabi game hs\assets\island2\traps\Arrow_Trap\Arrow Trap - Level 1.png"
$img = [System.Drawing.Bitmap]::FromFile($imgPath)
$hframes = 51
$frameSettings = @()
$frameW = $img.Width / $hframes
$frameH = $img.Height

for ($f = 0; $f -lt $hframes; $f++) {
    $startX = $f * $frameW
    $hasPixels = $false
    
    # Check a few central row/cols just to see if it's completely transparent
    for ($y = 0; $y -lt $frameH; $y += 2) {
        for ($x = 0; $x -lt $frameW; $x += 2) {
            $pixel = $img.GetPixel($startX + $x, $y)
            if ($pixel.A -gt 10) {
                $hasPixels = $true
                break
            }
        }
        if ($hasPixels) { break }
    }
    
    if ($hasPixels) {
        $frameSettings += $f
    }
}
$img.Dispose()
Write-Output "Visible frames:"
Write-Output ($frameSettings -join ", ")