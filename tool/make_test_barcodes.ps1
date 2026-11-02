# Erzeugt EAN-13-Barcodes echter Produkte als PNG, z. B. fuer die virtuelle
# Kamera-Szene des Android-Emulators. Prueft jeden Code bei Open Food Facts.
#
#   powershell -ExecutionPolicy Bypass -File tool\make_test_barcodes.ps1

param([string]$OutDir = (Join-Path $PSScriptRoot 'test_barcodes'))

Add-Type -AssemblyName System.Drawing

$codes = @('3017620422003', '5449000000996', '8076800195057', '4000417025005', '20724696', '4001686301265', '3046920022651')

$L = '0001101','0011001','0010011','0111101','0100011','0110001','0101111','0111011','0110111','0001011'
$G = '0100111','0110011','0011011','0100001','0011101','0111001','0000101','0010001','0001001','0010111'
$R = '1110010','1100110','1101100','1000010','1011100','1001110','1010000','1000100','1001000','1110100'
$parity = 'LLLLLL','LLGLGG','LLGGLG','LLGGGL','LGLLGG','LGGLLG','LGGGLL','LGLGLG','LGLGGL','LGGLGL'

function Test-Check([string]$code) {
  $d = $code.ToCharArray() | ForEach-Object { [int][string]$_ }
  $n = $d.Length
  $sum = 0
  for ($i = 0; $i -lt $n - 1; $i++) { $w = if ((($n - 2 - $i) % 2) -eq 0) { 3 } else { 1 }; $sum += $d[$i] * $w }
  return ((10 - ($sum % 10)) % 10) -eq $d[$n - 1]
}

function Get-Modules([string]$code) {
  $d = $code.ToCharArray() | ForEach-Object { [int][string]$_ }
  if ($code.Length -eq 8) {
    $m = '101'
    for ($i = 0; $i -lt 4; $i++) { $m += $L[$d[$i]] }
    $m += '01010'
    for ($i = 4; $i -lt 8; $i++) { $m += $R[$d[$i]] }
    return $m + '101'
  }
  $m = '101'
  $p = $parity[$d[0]]
  for ($i = 1; $i -le 6; $i++) { $m += if ($p[$i - 1] -eq 'L') { $L[$d[$i]] } else { $G[$d[$i]] } }
  $m += '01010'
  for ($i = 7; $i -le 12; $i++) { $m += $R[$d[$i]] }
  return $m + '101'
}

New-Item -ItemType Directory -Force $OutDir | Out-Null
$headers = @{ 'User-Agent' = 'TopFlop/1.0 (test barcode generator)' }

foreach ($code in $codes) {
  if (-not (Test-Check $code)) { Write-Output "skip $code (Pruefziffer falsch)"; continue }
  try {
    $res = Invoke-RestMethod "https://world.openfoodfacts.org/api/v2/product/$code.json?fields=product_name,brands" -Headers $headers -TimeoutSec 15
  } catch { Write-Output "skip $code (keine Verbindung)"; continue }
  if ($res.status -ne 1 -or -not $res.product.product_name) { Write-Output "skip $code (nicht bei OFF)"; continue }
  $label = ("{0} - {1}" -f $res.product.brands, $res.product.product_name).Trim(' -')

  $modules = Get-Modules $code
  $unit = 8; $quiet = 12; $barH = 260
  $w = ($modules.Length + 2 * $quiet) * $unit
  $bmp = New-Object System.Drawing.Bitmap $w, ($barH + 150)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear([System.Drawing.Color]::White)
  for ($i = 0; $i -lt $modules.Length; $i++) {
    if ($modules[$i] -eq '1') { $g.FillRectangle([System.Drawing.Brushes]::Black, ($quiet + $i) * $unit, 30, $unit, $barH) }
  }
  $g.TextRenderingHint = 'AntiAlias'
  $font = New-Object System.Drawing.Font('Consolas', 30)
  $small = New-Object System.Drawing.Font('Segoe UI', 22)
  $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment = 'Center'
  $g.DrawString($code, $font, [System.Drawing.Brushes]::Black, (New-Object System.Drawing.RectangleF 0, ($barH + 38), $w, 40), $fmt)
  $g.DrawString($label, $small, [System.Drawing.Brushes]::DimGray, (New-Object System.Drawing.RectangleF 0, ($barH + 90), $w, 40), $fmt)
  $file = Join-Path $OutDir "$code.png"
  $bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output "ok   $code  $label"
}
