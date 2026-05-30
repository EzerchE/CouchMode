# Generates the app icon and README images from a single minimal gamepad design.
# Outputs:
#   build\CouchMode.ico  (multi-size, embedded into the exe)
#   assets\logo.png         (256px transparent)
#   assets\banner.png       (README hero image)
#
# The same gamepad geometry is mirrored in CouchMode.cs (MakeIcon) so the
# tray icon matches this exe icon.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$root = $PSScriptRoot

$Blue   = [System.Drawing.Color]::FromArgb(255, 1, 119, 235)   # base brand blue (#0177EB)
$Gray   = [System.Drawing.Color]::FromArgb(255, 110, 110, 110)
$White  = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)

function New-RoundRect([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

# Draws a couch filling the canvas (no background square) in the given colour.
# This is the app/tray icon: it stays legible at tiny tray sizes.
function New-GamepadBitmap([int]$S, [System.Drawing.Color]$fill) {
    $bmp = New-Object System.Drawing.Bitmap($S, $S)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    $k = $S / 32.0

    $bFill = New-Object System.Drawing.SolidBrush($fill)
    $back = New-RoundRect (6*$k)  (8*$k)  (20*$k) (10*$k) (4*$k)   # backrest
    $armL = New-RoundRect (2*$k)  (12*$k) (7*$k)  (12*$k) (3.5*$k) # left arm
    $armR = New-RoundRect (23*$k) (12*$k) (7*$k)  (12*$k) (3.5*$k) # right arm
    $seat = New-RoundRect (4*$k)  (16*$k) (24*$k) (8*$k)  (3*$k)   # seat
    $g.FillPath($bFill, $back)
    $g.FillPath($bFill, $armL)
    $g.FillPath($bFill, $armR)
    $g.FillPath($bFill, $seat)
    $g.FillRectangle($bFill, 5*$k, 23*$k, 3*$k, 3.5*$k)           # left leg
    $g.FillRectangle($bFill, 24*$k, 23*$k, 3*$k, 3.5*$k)          # right leg
    $back.Dispose(); $armL.Dispose(); $armR.Dispose(); $seat.Dispose()
    $bFill.Dispose(); $g.Dispose()
    return $bmp
}

# Draws the showcase tile: a blue gradient rounded square with a white couch.
# Used for the README/Store promo image, not the app icon.
function New-CouchTile([int]$S) {
    $bmp = New-Object System.Drawing.Bitmap($S, $S)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    $k = $S / 32.0

    $lighter = [System.Drawing.Color]::FromArgb(255,
        [Math]::Min(255, $Blue.R + 60), [Math]::Min(255, $Blue.G + 60), [Math]::Min(255, $Blue.B + 60))
    $square = New-RoundRect (1*$k) (1*$k) (30*$k) (30*$k) (7*$k)
    $rect = New-Object System.Drawing.RectangleF (0,0,$S,$S)
    $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $lighter, $Blue, 45.0)
    $g.FillPath($grad, $square)
    $grad.Dispose(); $square.Dispose()

    $bFill = New-Object System.Drawing.SolidBrush($White)
    $back = New-RoundRect (9*$k)  (11.5*$k) (14*$k) (6.5*$k) (3*$k)
    $armL = New-RoundRect (7*$k)  (13.5*$k) (4*$k)  (8.5*$k) (2*$k)
    $armR = New-RoundRect (21*$k) (13.5*$k) (4*$k)  (8.5*$k) (2*$k)
    $seat = New-RoundRect (8*$k)  (16.5*$k) (16*$k) (5.5*$k) (2*$k)
    $g.FillPath($bFill, $back)
    $g.FillPath($bFill, $armL)
    $g.FillPath($bFill, $armR)
    $g.FillPath($bFill, $seat)
    $g.FillRectangle($bFill, 8.5*$k, 21.5*$k, 2.5*$k, 2.5*$k)
    $g.FillRectangle($bFill, 21*$k,  21.5*$k, 2.5*$k, 2.5*$k)
    $back.Dispose(); $armL.Dispose(); $armR.Dispose(); $seat.Dispose()
    $bFill.Dispose(); $g.Dispose()
    return $bmp
}

function Get-PngBytes([System.Drawing.Bitmap]$bmp) {
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    return $ms.ToArray()
}

# Build a PNG-compressed .ico (valid on Windows Vista+; fine for Windows 11).
function Write-Ico([string]$path, [int[]]$sizes) {
    $pngs = @()
    foreach ($s in $sizes) {
        $b = New-GamepadBitmap $s $Blue
        $pngs += ,(Get-PngBytes $b)
        $b.Dispose()
    }
    $fs = New-Object System.IO.FileStream($path, [System.IO.FileMode]::Create)
    $bw = New-Object System.IO.BinaryWriter($fs)
    $bw.Write([UInt16]0); $bw.Write([UInt16]1); $bw.Write([UInt16]$sizes.Count)  # ICONDIR
    $offset = 6 + (16 * $sizes.Count)
    for ($i = 0; $i -lt $sizes.Count; $i++) {
        $s = $sizes[$i]; $len = $pngs[$i].Length
        $bw.Write([byte]($s -band 0xFF))   # width (0 = 256)
        $bw.Write([byte]($s -band 0xFF))   # height
        $bw.Write([byte]0)                 # colours
        $bw.Write([byte]0)                 # reserved
        $bw.Write([UInt16]1)               # planes
        $bw.Write([UInt16]32)              # bitcount
        $bw.Write([UInt32]$len)            # bytes in resource
        $bw.Write([UInt32]$offset)         # offset
        $offset += $len
    }
    foreach ($p in $pngs) { $bw.Write([byte[]]$p) }
    $bw.Flush(); $bw.Close(); $fs.Close()
}

# --- Outputs ---
New-Item -ItemType Directory -Force -Path (Join-Path $root "build") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $root "assets") | Out-Null

Write-Ico (Join-Path $root "build\CouchMode.ico") @(256, 128, 64, 48, 32, 16)
Write-Host "Wrote build\CouchMode.ico" -ForegroundColor Green

# Promo tile (rounded square) for README / Store, not the app icon.
$logo = New-CouchTile 256
$logo.Save((Join-Path $root "assets\logo.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$logo.Dispose()
Write-Host "Wrote assets\logo.png" -ForegroundColor Green

# Banner: dark background, gamepad on the left, title + tagline on the right.
$bw_ = 760; $bh = 240
$banner = New-Object System.Drawing.Bitmap($bw_, $bh)
$bg = [System.Drawing.Graphics]::FromImage($banner)
$bg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$bg.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$bg.Clear([System.Drawing.Color]::FromArgb(255, 14, 14, 14))

$icon = New-CouchTile 160
$bg.DrawImage($icon, 48, 40, 160, 160)
$icon.Dispose()

$titleFont = New-Object System.Drawing.Font("Segoe UI", 34, [System.Drawing.FontStyle]::Bold)
$tagFont   = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Regular)
$wBrush = New-Object System.Drawing.SolidBrush($White)
$gBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 170, 170, 170))
$bg.DrawString("CouchMode", $titleFont, $wBrush, 240, 78)
$bg.DrawString([char]0x2192 + " controller on = Xbox mode  ·  off = desktop", $tagFont, $gBrush, 244, 134)

$banner.Save((Join-Path $root "assets\banner.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$titleFont.Dispose(); $tagFont.Dispose(); $wBrush.Dispose(); $gBrush.Dispose(); $bg.Dispose(); $banner.Dispose()
Write-Host "Wrote assets\banner.png" -ForegroundColor Green
