# =====================================================================
# DEADLOCK DUNGEON - analizar.ps1  (Windows / PowerShell)
# Analiza un escenario de procesos y recursos exportado por el juego:
#   - Muestra recursos totales, asignados y disponibles.
#   - Calcula la matriz de Necesidad (Maximo - Asignado).
#   - Ejecuta el algoritmo de seguridad (banquero) para:
#       * encontrar una secuencia segura, o
#       * detectar los procesos en interbloqueo y la espera circular.
#   - Compara su resultado con el que reporto el juego.
#
# Uso:   .\analizar.ps1 <archivo_escenario.txt>
# Ej.:   .\analizar.ps1 escenarios\escenario_nivel2_interbloqueo.txt
#
# Si Windows bloquea la ejecucion de scripts, usar:
#   powershell -ExecutionPolicy Bypass -File .\analizar.ps1 <archivo>
# =====================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$Archivo
)

if (-not (Test-Path -LiteralPath $Archivo)) {
    Write-Host "Error: no se encontro el archivo '$Archivo'"
    exit 1
}

$nivel    = "?"
$juego    = "(no indicado)"
$recursos = @()
$total    = @()
$procesos = @()   # lista de objetos: Nombre, Asignado, Maximo, Estado

# ----------------------- Lectura del archivo -------------------------
foreach ($linea in Get-Content -LiteralPath $Archivo) {
    $linea = $linea.Trim()
    if ($linea -eq "" -or $linea.StartsWith("#")) { continue }

    $campos = $linea.Split(";")
    switch ($campos[0]) {
        "NIVEL"    { $nivel = $campos[1] }
        "RECURSOS" { $recursos = $campos[1].Split(",") }
        "TOTAL"    { $total = @($campos[1].Split(",") | ForEach-Object { [int]$_ }) }
        "JUEGO"    { $juego = $campos[1] }
        "PROCESO"  {
            $estado = "ACTIVO"
            if ($campos.Count -ge 5) { $estado = $campos[4] }
            $procesos += [pscustomobject]@{
                Nombre   = $campos[1]
                Asignado = @($campos[2].Split(",") | ForEach-Object { [int]$_ })
                Maximo   = @($campos[3].Split(",") | ForEach-Object { [int]$_ })
                Estado   = $estado
            }
        }
    }
}

$nr = $recursos.Count
$np = $procesos.Count
if ($nr -eq 0 -or $np -eq 0) {
    Write-Host "Error: el archivo no tiene RECURSOS o PROCESOS validos."
    exit 1
}

$sep = "--------------------------------------------------------------"
Write-Host "=============================================================="
Write-Host " DEADLOCK DUNGEON - Analisis de escenario (PowerShell / Windows)"
Write-Host "=============================================================="
Write-Host " Archivo : $Archivo"
Write-Host " Nivel   : $nivel"
Write-Host " Fecha   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host " Sistema : $([System.Environment]::OSVersion.VersionString)"
Write-Host $sep

# ----------------------- Disponibles ---------------------------------
$disp = @()
for ($r = 0; $r -lt $nr; $r++) {
    $usado = 0
    foreach ($p in $procesos) { $usado += $p.Asignado[$r] }
    $disp += ($total[$r] - $usado)
}

Write-Host (" {0,-12}{1,8} {2,10} {3,12}" -f "Recurso", "Total", "Asignado", "Disponible")
for ($r = 0; $r -lt $nr; $r++) {
    Write-Host (" {0,-12}{1,8} {2,10} {3,12}" -f $recursos[$r], $total[$r], ($total[$r] - $disp[$r]), $disp[$r])
}
Write-Host $sep

# ----------------------- Matrices por proceso ------------------------
Write-Host (" {0,-12} {1,-11} {2,-12} {3,-12} {4,-12}" -f "Proceso", "Estado", "Asignado", "Maximo", "Necesidad")
foreach ($p in $procesos) {
    $nec = @()
    for ($r = 0; $r -lt $nr; $r++) {
        if ($p.Estado -eq "TERMINADO") { $nec += 0 } else { $nec += ($p.Maximo[$r] - $p.Asignado[$r]) }
    }
    Write-Host (" {0,-12} {1,-11} {2,-12} {3,-12} {4,-12}" -f $p.Nombre, $p.Estado, ($p.Asignado -join " "), ($p.Maximo -join " "), ($nec -join " "))
}
Write-Host $sep

# ----------------------- Algoritmo de seguridad ----------------------
$trabajo = @($disp)
$fin = @()
foreach ($p in $procesos) { $fin += ($p.Estado -eq "TERMINADO") }

$secuencia = @()
$paso = 1
$avance = $true
Write-Host " Algoritmo de seguridad (Trabajo inicial = Disponible = $($trabajo -join ' '))"
while ($avance) {
    $avance = $false
    for ($i = 0; $i -lt $np; $i++) {
        if ($fin[$i]) { continue }
        $p = $procesos[$i]
        $puede = $true
        for ($r = 0; $r -lt $nr; $r++) {
            if (($p.Maximo[$r] - $p.Asignado[$r]) -gt $trabajo[$r]) { $puede = $false }
        }
        if ($puede) {
            for ($r = 0; $r -lt $nr; $r++) { $trabajo[$r] += $p.Asignado[$r] }
            $fin[$i] = $true
            $secuencia += $p.Nombre
            Write-Host "   Paso ${paso}: $($p.Nombre) puede terminar -> libera recursos. Trabajo = $($trabajo -join ' ')"
            $paso++
            $avance = $true
        }
    }
}

$bloqueados = @()
for ($i = 0; $i -lt $np; $i++) { if (-not $fin[$i]) { $bloqueados += $i } }
Write-Host $sep

# ----------------------- Resultado -----------------------------------
if ($bloqueados.Count -eq 0) {
    $resultado = "SEGURO"
    Write-Host " RESULTADO: ESTADO SEGURO (no hay interbloqueo)" -ForegroundColor Green
    if ($secuencia.Count -gt 0) {
        Write-Host " Secuencia segura: $($secuencia -join ' -> ')"
    } else {
        Write-Host " Todos los procesos ya terminaron."
    }
}
else {
    $resultado = "INTERBLOQUEO"
    Write-Host " RESULTADO: INTERBLOQUEO DETECTADO (estado no seguro)" -ForegroundColor Red
    Write-Host " Espera circular:"
    foreach ($i in $bloqueados) {
        $p = $procesos[$i]
        $tiene = @()
        $espera = @()
        for ($r = 0; $r -lt $nr; $r++) {
            if ($p.Asignado[$r] -gt 0) { $tiene += $recursos[$r] }
            if (($p.Maximo[$r] - $p.Asignado[$r]) -gt 0) {
                $duenio = "nadie"
                foreach ($q in $procesos) { if ($q.Asignado[$r] -gt 0) { $duenio = $q.Nombre } }
                $espera += "$($recursos[$r])(lo tiene $duenio)"
            }
        }
        if ($tiene.Count -eq 0) { $tiene = @("nada") }
        Write-Host "   - $($p.Nombre) tiene [ $($tiene -join ' ') ] y espera [ $($espera -join ' ') ]"
    }
    Write-Host " Solucion sugerida: expropiar un recurso (recuperacion) o asignar"
    Write-Host " todos los recursos a un proceso primero (prevencion)."
}

# ----------------------- Comparacion con el juego --------------------
Write-Host $sep
Write-Host " Resultado reportado por el juego : $juego"
Write-Host " Resultado del script             : $resultado"
if (($juego -eq "COMPLETADO" -and $resultado -eq "SEGURO") -or ($juego -eq $resultado)) {
    Write-Host " Coinciden: SI"
} else {
    Write-Host " Coinciden: NO (revisar el escenario)"
}
Write-Host "=============================================================="
