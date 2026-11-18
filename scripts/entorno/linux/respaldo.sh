#!/usr/bin/env bash
# =====================================================================
# DEADLOCK DUNGEON - respaldo.sh   (Linux / Bash)
# Respaldo comprimido (tar.gz) de los escenarios, verificacion, rotacion
# y restauracion.  Uso:
#   bash respaldo.sh                     -> crea un respaldo
#   bash respaldo.sh --restaurar ARCHIVO -> restaura un respaldo
#   bash respaldo.sh --programar         -> muestra/instala la linea de cron diaria
# =====================================================================
RUTA="${RUTA:-/opt/deadlock-dungeon}"
ORIGEN="${ORIGEN:-$RUTA/escenarios}"
DESTINO="$RUTA/respaldos"; CONSERVAR=7
LOG="$RUTA/logs/respaldos.log"
mkdir -p "$DESTINO" "$RUTA/logs"
r() { echo "[$(date '+%F %T')] $*" | tee -a "$LOG"; }

if [ "$1" = "--restaurar" ]; then
  [ -f "$2" ] || { r "ERROR: no existe $2"; exit 1; }
  tar -xzf "$2" -C "$ORIGEN" && r "RESTAURADO: $2 -> $ORIGEN ($(ls "$ORIGEN"/escenario_*.txt 2>/dev/null | wc -l) escenarios)"
  exit 0
fi
if [ "$1" = "--programar" ]; then
  mkdir -p "$RUTA/scripts" && cp "$0" "$RUTA/scripts/respaldo.sh"
  LINEA="0 20 * * * bash $RUTA/scripts/respaldo.sh"
  if command -v crontab >/dev/null; then
    ( crontab -l 2>/dev/null | grep -v respaldo.sh; echo "$LINEA" ) | crontab - && r "Tarea cron instalada: $LINEA"
  else
    r "crontab no esta instalado. Linea para cron: $LINEA"
  fi
  exit 0
fi

n=$(ls "$ORIGEN"/escenario_*.txt 2>/dev/null | wc -l)
[ "$n" -gt 0 ] || { r "No hay escenarios en $ORIGEN"; exit 0; }
ARCH="$DESTINO/respaldo_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$ARCH" -C "$ORIGEN" $(cd "$ORIGEN" && ls escenario_*.txt)
dentro=$(tar -tzf "$ARCH" | wc -l)
if [ "$dentro" -eq "$n" ]; then r "RESPALDO OK: $ARCH ($dentro archivos, $(du -h "$ARCH" | cut -f1))"
else r "RESPALDO CON ERROR: esperados $n, en el archivo $dentro"; fi
ls -1t "$DESTINO"/respaldo_*.tar.gz | tail -n +$((CONSERVAR+1)) | while read -r v; do rm -f "$v"; r "Rotacion: eliminado $(basename "$v")"; done
echo " Respaldos disponibles:"; ls -lh "$DESTINO" | tail -n +2
echo " Espacio libre en /: $(df -h / | awk 'NR==2 {print $4}')"
