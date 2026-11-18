# =====================================================================
# DEADLOCK DUNGEON - monitorear.ps1   (Windows / PowerShell)
# ---------------------------------------------------------------------
# Monitorea el sistema y el PROCESO REAL del juego:
#   - CPU y memoria del equipo, espacio en disco y tiempo encendido
#   - Proceso del juego (PID, % CPU, memoria, hilos, prioridad)
#   - Los 5 procesos que mas memoria usan
#   - Estado de servicios de Windows relacionados con el proyecto
#   - Guarda las muestras en logs\monitoreo_<fecha>.csv
#
# No requiere administrador.
# Uso (con el juego abierto):
#   powershell -ExecutionPolicy Bypass -File .\monitorear.ps1
#   powershell -ExecutionPolicy Bypass -File .\monitorear.ps1 -Muestras 6 -Intervalo 5
# =====================================================================

param(
    [string]$Ruta = "C:\DeadlockDungeon",
    [int]$Muestras = 6,
    [int]$Intervalo = 5
)

# Nombres posibles del proceso del juego:
#   Deadlock_Dungeon = ejecutable exportado   |   Runner = ejecucion desde el IDE de GameMaker
$nombresJuego = @("Deadlock_Dungeon", "Runner")

$carpetaLogs = if (Test-Path "$Ruta\logs") { "$Ruta\logs" } else { $PSScriptRoot }
$csv = Join-Path $carpetaLogs ("monitoreo_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$nucleos = [Environment]::ProcessorCount

function Linea { Write-Host ("-" * 66) }

Write-Host ("=" * 66)
Write-Host " DEADLOCK DUNGEON - Monitoreo del sistema y del proceso del juego"
Write-Host ("=" * 66)

# ---------------- Informacion general ----------------
$os   = Get-CimInstance Win32_OperatingSystem
$cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
$disco = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$encendido = (Get-Date) - $os.LastBootUpTime
Write-Host (" Equipo      : {0}" -f $env:COMPUTERNAME)
Write-Host (" Sistema     : {0} (build {1})" -f $os.Caption, $os.BuildNumber)
Write-Host (" Procesador  : {0} ({1} nucleos logicos)" -f $cpu.Name.Trim(), $nucleos)
Write-Host (" RAM total   : {0:N1} GB" -f ($os.TotalVisibleMemorySize / 1MB))
Write-Host (" Disco C:    : {0:N1} GB libres de {1:N1} GB ({2:N0}% usado)" -f ($disco.FreeSpace/1GB), ($disco.Size/1GB), (100 - $disco.FreeSpace*100/$disco.Size))
Write-Host (" Encendido   : {0} dias, {1} h, {2} min" -f $encendido.Days, $encendido.Hours, $encendido.Minutes)
Linea

# ---------------- Proceso del juego ----------------
$juego = Get-Process -Name $nombresJuego -ErrorAction SilentlyContinue | Select-Object -First 1
if ($juego) {
    Write-Host (" Proceso del juego encontrado: {0}.exe  (PID {1})" -f $juego.ProcessName, $juego.Id) -ForegroundColor Green
    Write-Host (" Inicio: {0}   Prioridad: {1}   Hilos: {2}" -f $juego.StartTime, $juego.PriorityClass, $juego.Threads.Count)
} else {
    Write-Host " El juego NO esta en ejecucion. Abre Deadlock Dungeon para medir su proceso." -ForegroundColor Yellow
}
Linea

# ---------------- Muestras ----------------
Write-Host (" Tomando {0} muestras cada {1} s ..." -f $Muestras, $Intervalo)
Write-Host (" {0,-9} {1,8} {2,10} {3,12} {4,12} {5,10}" -f "Hora", "CPU eq.%", "RAM eq.%", "Juego CPU%", "Juego RAM MB", "Disco C:%")
$registros = @()
for ($i = 1; $i -le $Muestras; $i++) {
    $antes = if ($juego) { (Get-Process -Id $juego.Id -ErrorAction SilentlyContinue).TotalProcessorTime.TotalMilliseconds } else { 0 }
    Start-Sleep -Seconds $Intervalo
    $p = if ($juego) { Get-Process -Id $juego.Id -ErrorAction SilentlyContinue } else { $null }
    $cpuJuego = 0; $ramJuego = 0
    if ($p) {
        $cpuJuego = [math]::Round(($p.TotalProcessorTime.TotalMilliseconds - $antes) / ($Intervalo * 1000 * $nucleos) * 100, 1)
        $ramJuego = [math]::Round($p.WorkingSet64 / 1MB, 1)
    }
    $os = Get-CimInstance Win32_OperatingSystem
    $cpuEquipo = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $ramEquipo = [math]::Round(100 - $os.FreePhysicalMemory * 100 / $os.TotalVisibleMemorySize, 1)
    $disco = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $discoUso = [math]::Round(100 - $disco.FreeSpace * 100 / $disco.Size, 1)
    $hora = Get-Date -Format "HH:mm:ss"
    Write-Host (" {0,-9} {1,8} {2,10} {3,12} {4,12} {5,10}" -f $hora, $cpuEquipo, $ramEquipo, $cpuJuego, $ramJuego, $discoUso)
    $registros += [pscustomobject]@{
        Hora = $hora; CPU_Equipo = $cpuEquipo; RAM_Equipo = $ramEquipo
        Juego_PID = $(if ($p) { $p.Id } else { "" }); Juego_CPU = $cpuJuego; Juego_RAM_MB = $ramJuego; Disco_C = $discoUso
    }
}
$registros | Export-Csv -Path $csv -NoTypeInformation -Encoding UTF8
Linea

# ---------------- Top 5 procesos por memoria ----------------
Write-Host " Los 5 procesos que mas memoria usan:"
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 |
    ForEach-Object { Write-Host (" {0,-28} PID {1,-7} {2,8:N1} MB" -f $_.ProcessName, $_.Id, ($_.WorkingSet64/1MB)) }
Linea

# ---------------- Servicios ----------------
Write-Host " Servicios de Windows relacionados con el proyecto:"
$servicios = @(
    @{ N = "Audiosrv";  D = "Audio de Windows (musica y sonidos del juego)" },
    @{ N = "Schedule";  D = "Programador de tareas (respaldo automatico)" },
    @{ N = "EventLog";  D = "Registro de eventos de Windows" },
    @{ N = "WinDefend"; D = "Antivirus Microsoft Defender" }
)
foreach ($s in $servicios) {
    $svc = Get-Service -Name $s.N -ErrorAction SilentlyContinue
    $estado = if ($svc) { $svc.Status } else { "No encontrado" }
    $color = if ($estado -eq "Running") { "Green" } else { "Yellow" }
    Write-Host (" {0,-10} {1,-10} {2}" -f $s.N, $estado, $s.D) -ForegroundColor $color
}
Write-Host ("=" * 66)
Write-Host " Muestras guardadas en: $csv" -ForegroundColor Green
Write-Host ("=" * 66)
