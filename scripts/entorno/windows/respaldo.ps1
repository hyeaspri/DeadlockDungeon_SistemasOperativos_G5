# =====================================================================
# DEADLOCK DUNGEON - respaldo.ps1   (Windows / PowerShell)
# ---------------------------------------------------------------------
# Almacenamiento y respaldo de los escenarios del juego:
#   - Comprime los escenarios exportados por el juego en un ZIP con fecha
#   - Verifica el respaldo (cantidad de archivos dentro del ZIP)
#   - Conserva solo los N respaldos mas recientes (rotacion)
#   - -ProgramarTarea : crea una tarea programada diaria (automatizacion)
#   - -Restaurar <zip>: recupera los escenarios desde un respaldo
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\respaldo.ps1
#   powershell -ExecutionPolicy Bypass -File .\respaldo.ps1 -ProgramarTarea
#   powershell -ExecutionPolicy Bypass -File .\respaldo.ps1 -Restaurar "C:\DeadlockDungeon\respaldos\respaldo_....zip"
# =====================================================================

param(
    [string]$Origen  = "$env:LOCALAPPDATA\Deadlock_Dungeon",
    [string]$Ruta    = "C:\DeadlockDungeon",
    [int]$Conservar  = 7,
    [switch]$ProgramarTarea,
    [string]$Restaurar = ""
)

$destino = "$Ruta\respaldos"
New-Item -ItemType Directory -Path $destino -Force | Out-Null
New-Item -ItemType Directory -Path "$Ruta\escenarios" -Force | Out-Null
New-Item -ItemType Directory -Path "$Ruta\logs" -Force | Out-Null
$log = "$Ruta\logs\respaldos.log"

function Registrar([string]$texto, [string]$color = "White") {
    $linea = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $texto
    Write-Host $linea -ForegroundColor $color
    Add-Content -Path $log -Value $linea
}

Write-Host ("=" * 66)
Write-Host " DEADLOCK DUNGEON - Respaldo de escenarios"
Write-Host ("=" * 66)

# ---------------- Restauracion (recuperacion ante fallos) ----------------
if ($Restaurar -ne "") {
    if (-not (Test-Path -LiteralPath $Restaurar)) {
        Registrar "ERROR: no existe el respaldo $Restaurar" "Red"; exit 1
    }
    New-Item -ItemType Directory -Path $Origen -Force | Out-Null
    Expand-Archive -LiteralPath $Restaurar -DestinationPath $Origen -Force
    $n = (Get-ChildItem $Origen -Filter "escenario_*.txt").Count
    Registrar "RESTAURADO: $Restaurar -> $Origen ($n escenarios disponibles)" "Green"
    exit 0
}

# ---------------- Respaldo ----------------
if (-not (Test-Path $Origen)) {
    Registrar "No existe la carpeta de escenarios $Origen (juega al menos un nivel primero)." "Yellow"; exit 1
}
$archivos = Get-ChildItem -Path $Origen -Filter "escenario_*.txt"
if ($archivos.Count -eq 0) {
    Registrar "No hay escenarios para respaldar en $Origen" "Yellow"; exit 0
}
$zip = Join-Path $destino ("respaldo_{0}.zip" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
Compress-Archive -Path ($archivos.FullName) -DestinationPath $zip -Force

# Copia de los escenarios a C:\DeadlockDungeon\escenarios (para revision)
Copy-Item -Path ($archivos.FullName) -Destination "$Ruta\escenarios" -Force -ErrorAction SilentlyContinue

# Verificacion del respaldo
Add-Type -AssemblyName System.IO.Compression.FileSystem
$dentro = [System.IO.Compression.ZipFile]::OpenRead($zip)
$cantidad = $dentro.Entries.Count
$dentro.Dispose()
$tam = (Get-Item $zip).Length / 1KB
if ($cantidad -eq $archivos.Count) {
    Registrar ("RESPALDO OK: {0} ({1} archivos, {2:N1} KB)" -f $zip, $cantidad, $tam) "Green"
} else {
    Registrar ("RESPALDO CON ERROR: se esperaban {0} archivos y el ZIP tiene {1}" -f $archivos.Count, $cantidad) "Red"
}

# Rotacion: conservar solo los N mas recientes
$viejos = Get-ChildItem $destino -Filter "respaldo_*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -Skip $Conservar
foreach ($v in $viejos) { Remove-Item $v.FullName -Force; Registrar "Respaldo antiguo eliminado (rotacion): $($v.Name)" }

Write-Host ""
Write-Host " Respaldos disponibles:"
Get-ChildItem $destino -Filter "respaldo_*.zip" | Sort-Object LastWriteTime -Descending |
    ForEach-Object { Write-Host (" {0}   {1:N1} KB   {2}" -f $_.Name, ($_.Length/1KB), $_.LastWriteTime) }
$disco = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
Write-Host (" Espacio libre en C: {0:N1} GB" -f ($disco.FreeSpace/1GB))

# ---------------- Tarea programada (automatizacion) ----------------
if ($ProgramarTarea) {
    $nombreTarea = "DeadlockDungeon_Respaldo"
    # La tarea ejecuta una copia del script guardada en C:\DeadlockDungeon\scripts
    New-Item -ItemType Directory -Path "$Ruta\scripts" -Force | Out-Null
    Copy-Item -Path $PSCommandPath -Destination "$Ruta\scripts\respaldo.ps1" -Force
    $scriptTarea = "$Ruta\scripts\respaldo.ps1"
    $accion  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ("-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"{0}`"" -f $scriptTarea)
    $disparo = New-ScheduledTaskTrigger -Daily -At "20:00"
    Register-ScheduledTask -TaskName $nombreTarea -Action $accion -Trigger $disparo `
        -Description "Respaldo diario de los escenarios de Deadlock Dungeon" -Force | Out-Null
    $t = Get-ScheduledTask -TaskName $nombreTarea
    Registrar ("Tarea programada '{0}' creada: todos los dias a las 20:00 (estado: {1})" -f $nombreTarea, $t.State) "Green"
}
Write-Host ("=" * 66)
Write-Host " Registro: $log"
Write-Host ("=" * 66)
