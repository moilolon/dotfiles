# Draws the README cover (1600x1000, dark) into assets/cover.png, from shapes.
# Run from the repository root: powershell -NoProfile -File assets/draw-cover.ps1
Add-Type -AssemblyName System.Drawing

$assets = Split-Path -Parent $MyInvocation.MyCommand.Path

function Get-Color([string]$hex, [int]$alpha = 255) {
  $c = [System.Drawing.ColorTranslator]::FromHtml($hex)
  return [System.Drawing.Color]::FromArgb($alpha, $c.R, $c.G, $c.B)
}

$ground = Get-Color '#1E222A'
$frame = Get-Color '#181B22'
$sheet = Get-Color '#2C313C'
$line = Get-Color '#565E6E'

function New-RoundedPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Fill-Rounded($g, $color, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $brush = New-Object System.Drawing.SolidBrush $color
  $path = New-RoundedPath $x $y $w $h $r
  $g.FillPath($brush, $path)
  $brush.Dispose(); $path.Dispose()
}

function Fill-Gradient($g, $from, $to, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.PointF $x, $y), (New-Object System.Drawing.PointF ($x + $w), ($y + $h)), $from, $to)
  $path = New-RoundedPath $x $y $w $h $r
  $g.FillPath($brush, $path)
  $brush.Dispose(); $path.Dispose()
}

function Write-Text($g, [string]$text, [string]$font, [float]$size, $color, [float]$x, [float]$y) {
  $f = New-Object System.Drawing.Font($font, $size)
  $b = New-Object System.Drawing.SolidBrush $color
  $g.DrawString($text, $f, $b, $x, $y)
  $f.Dispose(); $b.Dispose()
}

function Draw-Lines($g, [float]$x, [float]$y, [float]$w, [float[]]$fractions, [float]$gap) {
  foreach ($fraction in $fractions) {
    Fill-Rounded $g $line $x $y ($w * $fraction) 8 4
    $y += $gap
  }
}

# The common cover: dark ground with the accent's glow, the icon, the name and three lines on
# the left; the window on the right, where each repo draws its own picture.
function New-Cover([string]$accent, [string]$accentDark, [string]$title, [string[]]$text) {
  $bitmap = New-Object System.Drawing.Bitmap 1600, 1000
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.Clear($ground)
  $glow = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point 0, 0), (New-Object System.Drawing.Point 1600, 1000), (Get-Color $accent 70), (Get-Color $accent 0))
  $g.FillRectangle($glow, 0, 0, 1600, 1000)
  $glow.Dispose()
  Fill-Gradient $g (Get-Color $accent) (Get-Color $accentDark) 120 250 120 120 26
  Write-Text $g $title 'Segoe UI Semibold' 60 (Get-Color '#ECEFF4') 112 400
  for ($i = 0; $i -lt $text.Count; $i++) {
    Write-Text $g $text[$i] 'Segoe UI' 28 (Get-Color '#A0A8B6') 120 (520 + $i * 46)
  }
  Fill-Rounded $g $frame 900 90 580 820 28
  for ($i = 0; $i -lt 3; $i++) { Fill-Rounded $g $line (936 + $i * 40) 122 22 22 11 }
  return @($bitmap, $g)
}

function Save-Cover($canvas) {
  $canvas[1].Dispose()
  $canvas[0].Save((Join-Path $assets 'cover.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas[0].Dispose()
  Write-Output 'cover.png written'
}

$canvas = New-Cover '#7F5AF0' '#3B2A80' 'dotfiles' @('A two-line, powerline-style prompt', 'for Git Bash on Windows: time, user,', 'folder and git branch at a glance.')
$g = $canvas[1]

# The icon: a terminal prompt.
$font = New-Object System.Drawing.Font('Consolas', 34, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush (Get-Color '#ECEFF4')
$size = $g.MeasureString('>_', $font)
$g.DrawString('>_', $font, $brush, (180 - $size.Width / 2), (310 - $size.Height / 2))
$font.Dispose(); $brush.Dispose()

# The prompt's segments, in the colours of bash/prompt.sh (256-colour 239, 121, 230 and 110).
$mono = New-Object System.Drawing.Font('Consolas', 16)
$segments = @{ time = @('#4E4E4E', '#EEEEEE'); user = @('#87FFAF', '#000000'); path = @('#FFFFD7', '#000000'); git = @('#87AFD7', '#000000') }
function Draw-Prompt($g, [float]$y, [object[]]$parts, [string]$command) {
  $x = 930
  $h = 36
  for ($i = 0; $i -lt $parts.Count; $i++) {
    $colors = $segments[$parts[$i][0]]
    $text = ' ' + $parts[$i][1] + ' '
    $w = $g.MeasureString($text, $mono).Width
    $bg = New-Object System.Drawing.SolidBrush (Get-Color $colors[0])
    $g.FillRectangle($bg, $x, $y, $w, $h)
    $g.FillPolygon($bg, [System.Drawing.PointF[]]@((New-Object System.Drawing.PointF ($x + $w), $y), (New-Object System.Drawing.PointF ($x + $w + 14), ($y + $h / 2)), (New-Object System.Drawing.PointF ($x + $w), ($y + $h))))
    $fg = New-Object System.Drawing.SolidBrush (Get-Color $colors[1])
    $g.DrawString($text, $mono, $fg, $x, ($y + 5))
    $bg.Dispose(); $fg.Dispose()
    $x += $w + 14
  }
  $muted = New-Object System.Drawing.SolidBrush (Get-Color '#A0A8B6')
  $white = New-Object System.Drawing.SolidBrush (Get-Color '#ECEFF4')
  $g.DrawString('└─', $mono, $muted, 930, ($y + 50))
  $g.DrawString('$ ' + $command, $mono, $white, 970, ($y + 50))
  $muted.Dispose(); $white.Dispose()
}
Fill-Rounded $g (Get-Color '#0C0C0C') 910 166 560 720 18
Draw-Prompt $g 196 @(@('time', '09:41'), @('user', 'moi@devbox'), @('path', '~')) 'cd dev/dotfiles'
Draw-Prompt $g 336 @(@('time', '09:41'), @('user', 'moi@devbox'), @('path', 'dotfiles'), @('git', 'main')) 'git log -1'
$yellow = New-Object System.Drawing.SolidBrush (Get-Color '#C19C00')
$white = New-Object System.Drawing.SolidBrush (Get-Color '#CCCCCC')
$g.DrawString('ec48721', $mono, $yellow, 930, 430)
$g.DrawString('Restore the git icon', $mono, $white, 1024, 430)
$yellow.Dispose(); $white.Dispose()
Draw-Prompt $g 516 @(@('time', '09:42'), @('user', 'moi@devbox'), @('path', 'portfolio'), @('git', 'develop')) ''
Fill-Rounded $g (Get-Color '#ECEFF4') 994 570 12 24 2
$mono.Dispose()

Save-Cover $canvas
