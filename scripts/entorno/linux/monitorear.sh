#!/usr/bin/env bash
# =====================================================================
# DEADLOCK DUNGEON - monitorear.sh   (Linux / Bash)
# Monitorea CPU, memoria, disco, tiempo encendido y los procesos que mas
# recursos usan; guarda las muestras en CSV.
# Uso: bash monitorear.sh [muestras] [intervalo]
# =====================================================================
MUESTRAS="${1:-5}"; INTERVALO="${2:-2}"
RUTA="/opt/deadlock-dungeon"
DIR="$RUTA/logs"; mkdir -p "$DIR" 2>/dev/null; [ -w "$DIR" ] || DIR="$(dirname "$0")"
CSV="$DIR/monitoreo_$(date +%Y%m%d_%H%M%S).csv"
echo "=================================================================="
echo " DEADLOCK DUNGEON - Monitoreo del sistema (Linux)"
echo "=================================================================="
echo " Equipo     : $(hostname)"
echo " Sistema    : $(. /etc/os-release; echo "$PRETTY_NAME")"
echo " Nucleos    : $(nproc)"
echo " Memoria    : $(free -h | awk '/Mem:/ {print $3 " usados de " $2}')"
echo " Disco /    : $(df -h / | awk 'NR==2 {print $4 " libres de " $2 " (" $5 " usado)"}')"
echo " Encendido  : $(uptime -p 2>/dev/null || cat /proc/uptime)"
echo "------------------------------------------------------------------"
cpu_uso() {  # % de CPU usado entre dos lecturas de /proc/stat
  read -r _ a b c d e f g _ < /proc/stat; t1=$((a+b+c+d+e+f+g)); i1=$((d+e))
  sleep "$INTERVALO"
  read -r _ a b c d e f g _ < /proc/stat; t2=$((a+b+c+d+e+f+g)); i2=$((d+e))
  echo $(( (100 * ((t2-t1) - (i2-i1))) / (t2-t1 > 0 ? t2-t1 : 1) ))
}
echo "Hora,CPU_%,RAM_%,Disco_%,Procesos" > "$CSV"
printf " %-9s %6s %6s %8s %10s\n" "Hora" "CPU%" "RAM%" "Disco%" "Procesos"
for ((i=1; i<=MUESTRAS; i++)); do
  cpu=$(cpu_uso)
  ram=$(free | awk '/Mem:/ {printf "%.1f", $3*100/$2}')
  disco=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
  procs=$(ps -e --no-headers | wc -l)
  hora=$(date +%H:%M:%S)
  printf " %-9s %6s %6s %8s %10s\n" "$hora" "$cpu" "$ram" "$disco" "$procs"
  echo "$hora,$cpu,$ram,$disco,$procs" >> "$CSV"
done
echo "------------------------------------------------------------------"
echo " Los 5 procesos que mas memoria usan:"
ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -6
echo "=================================================================="
echo " Muestras guardadas en: $CSV"
