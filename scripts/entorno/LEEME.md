# Scripts del entorno de ejecución – Deadlock Dungeon

| Windows (PowerShell) | Linux (Bash) | Función |
|---|---|---|
| `monitorear.ps1` | `monitorear.sh` | Mide CPU, RAM y disco del equipo y el **proceso real del juego** (PID, % CPU, memoria, hilos). Muestra los procesos que más memoria usan y el estado de los servicios relacionados. Guarda las muestras en CSV |
| `respaldo.ps1` | `respaldo.sh` | Comprime los escenarios exportados por el juego, verifica el respaldo, conserva los 7 más recientes, permite **restaurar** (`-Restaurar` / `--restaurar`) y crea una **tarea programada** diaria (`-ProgramarTarea` / `--programar` con cron) |

Ninguno requiere administrador. Los registros quedan en `C:\DeadlockDungeon\logs` (Windows) o `/opt/deadlock-dungeon/logs` (Linux).

**Relación con Sistemas Operativos:** dentro del juego, el Caballero, el Mago y el Arquero son procesos *simulados*; fuera del juego, `Deadlock_Dungeon.exe` (o `Runner.exe` desde el IDE) es un proceso *real* que el sistema operativo planifica y al que asigna CPU y memoria. El monitoreo conecta las dos miradas. El respaldo aplica la automatización y la gestión de almacenamiento.

Las salidas de las pruebas en Linux (Ubuntu 24.04) están en `pruebas/resultados_entorno_linux/`.
