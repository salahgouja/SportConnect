Add-Type -AssemblyName System.Drawing

function Create-LogoAsset {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$CanvasSize,
        [float]$ScaleFactor,
        [System.Drawing.Color]$TargetColor,
        [System.Drawing.Color]$BackgroundColor = [System.Drawing.Color]::Transparent
    )

    if (-not (Test-Path $InputPath)) {
        Write-Host "Input file not found: $InputPath"
        return
    }

    $sourceImg = [System.Drawing.Bitmap]::FromFile((Resolve-Path $InputPath).Path)
    
    # 1. Extract the white logo shape and recolor it.
    # The source icon has white rounded-corner canvas pixels too, so ignore
    # tiny white components while keeping the large silhouette pieces.
    $whiteMask = New-Object 'bool[,]' $sourceImg.Width,$sourceImg.Height
    $visited = New-Object 'bool[,]' $sourceImg.Width,$sourceImg.Height
    $components = New-Object System.Collections.Generic.List[object]

    for ($y = 0; $y -lt $sourceImg.Height; $y++) {
        for ($x = 0; $x -lt $sourceImg.Width; $x++) {
            $px = $sourceImg.GetPixel($x, $y)
            if ($px.R -gt 240 -and $px.G -gt 240 -and $px.B -gt 240) {
                $whiteMask[$x, $y] = $true
            }
        }
    }

    for ($y = 0; $y -lt $sourceImg.Height; $y++) {
        for ($x = 0; $x -lt $sourceImg.Width; $x++) {
            if ($visited[$x, $y] -or -not $whiteMask[$x, $y]) {
                continue
            }

            $queue = New-Object System.Collections.Generic.Queue[object]
            $pixels = New-Object System.Collections.Generic.List[object]
            $queue.Enqueue([int[]]@($x, $y))
            $visited[$x, $y] = $true

            while ($queue.Count -gt 0) {
                $point = $queue.Dequeue()
                $cx = $point[0]
                $cy = $point[1]
                $pixels.Add([int[]]@($cx, $cy)) | Out-Null

                foreach ($delta in @([int[]]@(-1, 0), [int[]]@(1, 0), [int[]]@(0, -1), [int[]]@(0, 1))) {
                    $nx = $cx + $delta[0]
                    $ny = $cy + $delta[1]

                    if (
                        $nx -lt 0 -or
                        $ny -lt 0 -or
                        $nx -ge $sourceImg.Width -or
                        $ny -ge $sourceImg.Height -or
                        $visited[$nx, $ny] -or
                        -not $whiteMask[$nx, $ny]
                    ) {
                        continue
                    }

                    $visited[$nx, $ny] = $true
                    $queue.Enqueue([int[]]@($nx, $ny))
                }
            }

            $components.Add($pixels) | Out-Null
        }
    }

    $processedSource = New-Object System.Drawing.Bitmap($sourceImg.Width, $sourceImg.Height)
    $minX, $minY = $sourceImg.Width, $sourceImg.Height
    $maxX, $maxY = 0, 0
    $hasContent = $false

    foreach ($component in $components) {
        if ($component.Count -lt 180) {
            continue
        }

        foreach ($point in $component) {
            $x = $point[0]
            $y = $point[1]
            $processedSource.SetPixel($x, $y, $TargetColor)
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
            $hasContent = $true
        }
    }

    for ($y = 0; $y -lt $sourceImg.Height; $y++) {
        for ($x = 0; $x -lt $sourceImg.Width; $x++) {
            if (-not $hasContent -or $processedSource.GetPixel($x, $y).A -eq 0) {
                $processedSource.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
            }
        }
    }

    if (-not $hasContent) {
        Write-Host "No white pixels detected in $InputPath"
        $sourceImg.Dispose()
        $processedSource.Dispose()
        return
    }

    # 2. Crop to bounds
    $contentWidth = $maxX - $minX + 1
    $contentHeight = $maxY - $minY + 1
    $rect = New-Object System.Drawing.Rectangle($minX, $minY, $contentWidth, $contentHeight)
    $croppedLogo = $processedSource.Clone($rect, $processedSource.PixelFormat)

    # 3. Create destination canvas
    $destBitmap = New-Object System.Drawing.Bitmap($CanvasSize, $CanvasSize)
    $g = [System.Drawing.Graphics]::FromImage($destBitmap)
    $g.Clear($BackgroundColor)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

    # 4. Calculate scaling
    $targetDim = $CanvasSize * $ScaleFactor
    $aspectRatio = $contentWidth / $contentHeight
    
    if ($aspectRatio -gt 1) {
        $drawWidth = $targetDim
        $drawHeight = $targetDim / $aspectRatio
    } else {
        $drawHeight = $targetDim
        $drawWidth = $targetDim * $aspectRatio
    }

    $destX = ($CanvasSize - $drawWidth) / 2
    $destY = ($CanvasSize - $drawHeight) / 2

    # 5. Draw
    $g.DrawImage($croppedLogo, [float]$destX, [float]$destY, [float]$drawWidth, [float]$drawHeight)

    # 6. Save
    $destBitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Cleanup
    $g.Dispose()
    $destBitmap.Dispose()
    $croppedLogo.Dispose()
    $processedSource.Dispose()
    $sourceImg.Dispose()

    Write-Host "Created $OutputPath : $($CanvasSize)x$($CanvasSize)"
}

$brandGreen = [System.Drawing.ColorTranslator]::FromHtml("#45C83C")
$white = [System.Drawing.Color]::White
$inputIcon = "assets/icons/app_icon_source.png"

# Ensure directories exist
New-Item -ItemType Directory -Force -Path "assets/icons" | Out-Null
New-Item -ItemType Directory -Force -Path "assets/images" | Out-Null

# Keep a copy of the original rounded-corner source before replacing app_icon.png
# with the generated light-mode icon.
if (-not (Test-Path $inputIcon)) {
    Copy-Item -Path "assets/icons/app_icon.png" -Destination $inputIcon
}

# Generate files
Create-LogoAsset -InputPath $inputIcon -OutputPath "assets/icons/app_icon_foreground.png" -CanvasSize 1024 -ScaleFactor 0.58 -TargetColor $brandGreen
Create-LogoAsset -InputPath $inputIcon -OutputPath "assets/icons/app_icon_light.png" -CanvasSize 1024 -ScaleFactor 0.58 -TargetColor $brandGreen -BackgroundColor $white
Create-LogoAsset -InputPath $inputIcon -OutputPath "assets/icons/app_icon.png" -CanvasSize 1024 -ScaleFactor 0.58 -TargetColor $brandGreen -BackgroundColor $white
Create-LogoAsset -InputPath $inputIcon -OutputPath "assets/icons/app_icon_ios.png" -CanvasSize 1024 -ScaleFactor 0.58 -TargetColor $brandGreen -BackgroundColor $white
Create-LogoAsset -InputPath $inputIcon -OutputPath "assets/images/splash_logo.png" -CanvasSize 1024 -ScaleFactor 0.36 -TargetColor $brandGreen
Create-LogoAsset -InputPath $inputIcon -OutputPath "assets/images/splash_logo_dark.png" -CanvasSize 1024 -ScaleFactor 0.36 -TargetColor $brandGreen
Create-LogoAsset -InputPath $inputIcon -OutputPath "assets/images/splash_logo_android12.png" -CanvasSize 1152 -ScaleFactor 0.30 -TargetColor $brandGreen
Create-LogoAsset -InputPath $inputIcon -OutputPath "assets/images/splash_logo_android12_dark.png" -CanvasSize 1152 -ScaleFactor 0.30 -TargetColor $brandGreen
