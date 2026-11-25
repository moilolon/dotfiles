# Draws the README cover (assets/cover.png, 1600x1000), the icon (assets/icon.png, 256x256, which
# Orca shows as the project's icon) and the GitHub social preview (assets/social-preview.png,
# 1280x640, uploaded by hand in Settings), all dark and from shapes.
# Run from the repository root: powershell -NoProfile -File assets/draw-images.ps1
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

function New-Canvas([int]$w, [int]$h) {
  $bitmap = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  return @($bitmap, $g)
}

# The icon: the accent's gradient square with the repo's symbol, drawn where the cover puts it
# (120,250, 120 px). $glyph draws the symbol in those coordinates.
function Draw-Icon($g, $cover, [scriptblock]$glyph) {
  Fill-Gradient $g (Get-Color $cover.Accent) (Get-Color $cover.AccentDark) 120 250 120 120 26
  & $glyph $g
}

# The cover, 1600 px wide plus $extra on each side: the ground and the glow fill it all, the
# content stays in the middle 1600x1000.
function Draw-Cover($g, $cover, [int]$extra) {
  $width = 1600 + 2 * $extra
  $g.Clear($ground)
  $glow = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point 0, 0), (New-Object System.Drawing.Point $width, 1000), (Get-Color $cover.Accent 70), (Get-Color $cover.Accent 0))
  $g.FillRectangle($glow, 0, 0, $width, 1000)
  $glow.Dispose()
  $g.TranslateTransform($extra, 0)
  Draw-Icon $g $cover $cover.Glyph
  Write-Text $g $cover.Title 'Segoe UI Semibold' 60 (Get-Color '#ECEFF4') 112 400
  for ($i = 0; $i -lt $cover.Text.Count; $i++) {
    Write-Text $g $cover.Text[$i] 'Segoe UI' 28 (Get-Color '#A0A8B6') 120 (520 + $i * 46)
  }
  Fill-Rounded $g $frame 900 90 580 820 28
  for ($i = 0; $i -lt 3; $i++) { Fill-Rounded $g $line (936 + $i * 40) 122 22 22 11 }
  & $cover.Picture $g
  $g.ResetTransform()
}

function Save-Images($cover) {
  $canvas = New-Canvas 1600 1000
  Draw-Cover $canvas[1] $cover 0
  $canvas[1].Dispose()
  $canvas[0].Save((Join-Path $assets 'cover.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas[0].Dispose()

  # GitHub's preview is 2:1: the cover widened to 2000x1000, then scaled to 1280x640.
  $wide = New-Canvas 2000 1000
  Draw-Cover $wide[1] $cover 200
  $wide[1].Dispose()
  $social = New-Canvas 1280 640
  $social[1].DrawImage($wide[0], 0, 0, 1280, 640)
  $social[1].Dispose(); $wide[0].Dispose()
  $social[0].Save((Join-Path $assets 'social-preview.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $social[0].Dispose()

  # The icon, the cover's 120 px square drawn at 240 px on a transparent 256x256.
  $icon = New-Canvas 256 256
  $icon[1].Clear([System.Drawing.Color]::Transparent)
  $icon[1].Transform = New-Object System.Drawing.Drawing2D.Matrix(2, 0, 0, 2, -232, -492)
  Draw-Icon $icon[1] $cover $cover.Glyph
  $icon[1].Dispose()
  $icon[0].Save((Join-Path $assets 'icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $icon[0].Dispose()

  Write-Output 'cover.png, icon.png and social-preview.png written'
}

$cover = @{
  Accent = '#7F5AF0'
  AccentDark = '#3B2A80'
  Title = 'dotfiles'
  Text = @('A two-line, powerline-style prompt', 'for Git Bash on Windows: time, user,', 'folder and git branch at a glance.')
}

$cover.Glyph = {
  param($g)
  # The icon: a terminal prompt.
  $font = New-Object System.Drawing.Font('Consolas', 34, [System.Drawing.FontStyle]::Bold)
  $brush = New-Object System.Drawing.SolidBrush (Get-Color '#ECEFF4')
  $size = $g.MeasureString('>_', $font)
  $g.DrawString('>_', $font, $brush, (180 - $size.Width / 2), (310 - $size.Height / 2))
  $font.Dispose(); $brush.Dispose()
}

$cover.Picture = {
  param($g)
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
}

Save-Images $cover
