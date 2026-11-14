#!/usr/bin/env bash
# =====================================================================
# DEADLOCK DUNGEON - analizar.sh  (Linux / Bash)
# Analiza un escenario de procesos y recursos exportado por el juego:
#   - Muestra recursos totales, asignados y disponibles.
#   - Calcula la matriz de Necesidad (Maximo - Asignado).
#   - Ejecuta el algoritmo de seguridad (banquero) para:
#       * encontrar una secuencia segura, o
#       * detectar los procesos en interbloqueo y la espera circular.
#   - Compara su resultado con el que reporto el juego.
#
# Uso:   ./analizar.sh <archivo_escenario.txt>
# Ej.:   ./analizar.sh escenarios/escenario_nivel2_interbloqueo.txt
#
# Formato del archivo (separado por ';' y ','):
#   NIVEL;2
#   RECURSOS;Llave,Escudo
#   TOTAL;1,1
#   PROCESO;Caballero;1,0;1,1;ACTIVO     (nombre;asignado;maximo;estado)
#   JUEGO;INTERBLOQUEO
# =====================================================================

if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_escenario.txt>"
    exit 1
fi

ARCHIVO="$1"
if [ ! -f "$ARCHIVO" ]; then
    echo "Error: no se encontro el archivo '$ARCHIVO'"
    exit 1
fi

NIVEL="?"
JUEGO="(no indicado)"
RECURSOS=()
TOTAL=()
PROC_NOMBRE=()
PROC_ESTADO=()
declare -A ASIG
declare -A MAXI
NP=0

# ----------------------- Lectura del archivo -------------------------
while IFS= read -r linea || [ -n "$linea" ]; do
    linea="${linea//$'\r'/}"                 # quitar fin de linea de Windows
    [ -z "$linea" ] && continue
    [[ "$linea" == \#* ]] && continue

    IFS=';' read -r -a campos <<< "$linea"
    case "${campos[0]}" in
        NIVEL)    NIVEL="${campos[1]}" ;;
        RECURSOS) IFS=',' read -r -a RECURSOS <<< "${campos[1]}" ;;
        TOTAL)    IFS=',' read -r -a TOTAL <<< "${campos[1]}" ;;
        JUEGO)    JUEGO="${campos[1]}" ;;
        PROCESO)
            PROC_NOMBRE[$NP]="${campos[1]}"
            PROC_ESTADO[$NP]="${campos[4]:-ACTIVO}"
            IFS=',' read -r -a a <<< "${campos[2]}"
            IFS=',' read -r -a m <<< "${campos[3]}"
            for ((r=0; r<${#a[@]}; r++)); do
                ASIG[$NP,$r]="${a[$r]}"
                MAXI[$NP,$r]="${m[$r]}"
            done
            NP=$((NP+1))
            ;;
    esac
done < "$ARCHIVO"

NR=${#RECURSOS[@]}
if [ "$NR" -eq 0 ] || [ "$NP" -eq 0 ]; then
    echo "Error: el archivo no tiene RECURSOS o PROCESOS validos."
    exit 1
fi

echo "=============================================================="
echo " DEADLOCK DUNGEON - Analisis de escenario (Bash / Linux)"
echo "=============================================================="
echo " Archivo : $ARCHIVO"
echo " Nivel   : $NIVEL"
echo " Fecha   : $(date '+%Y-%m-%d %H:%M:%S')"
echo " Sistema : $(uname -s) $(uname -r)"
echo "--------------------------------------------------------------"

# ----------------------- Disponibles ---------------------------------
DISP=()
for ((r=0; r<NR; r++)); do
    usado=0
    for ((p=0; p<NP; p++)); do
        usado=$((usado + ASIG[$p,$r]))
    done
    DISP[$r]=$((TOTAL[$r] - usado))
done

printf " %-12s" "Recurso"; printf "%8s %10s %12s\n" "Total" "Asignado" "Disponible"
for ((r=0; r<NR; r++)); do
    printf " %-12s%8s %10s %12s\n" "${RECURSOS[$r]}" "${TOTAL[$r]}" "$((TOTAL[$r]-DISP[$r]))" "${DISP[$r]}"
done
echo "--------------------------------------------------------------"

# ----------------------- Matrices por proceso ------------------------
printf " %-12s %-11s %-12s %-12s %-12s\n" "Proceso" "Estado" "Asignado" "Maximo" "Necesidad"
for ((p=0; p<NP; p++)); do
    sa=""; sm=""; sn=""
    for ((r=0; r<NR; r++)); do
        sa+="${ASIG[$p,$r]} "
        sm+="${MAXI[$p,$r]} "
        if [ "${PROC_ESTADO[$p]}" = "TERMINADO" ]; then
            sn+="0 "
        else
            sn+="$((MAXI[$p,$r] - ASIG[$p,$r])) "
        fi
    done
    printf " %-12s %-11s %-12s %-12s %-12s\n" "${PROC_NOMBRE[$p]}" "${PROC_ESTADO[$p]}" "$sa" "$sm" "$sn"
done
echo "--------------------------------------------------------------"

# ----------------------- Algoritmo de seguridad ----------------------
TRABAJO=("${DISP[@]}")
FIN=()
for ((p=0; p<NP; p++)); do
    if [ "${PROC_ESTADO[$p]}" = "TERMINADO" ]; then FIN[$p]=1; else FIN[$p]=0; fi
done

SECUENCIA=()
paso=1
avance=1
echo " Algoritmo de seguridad (Trabajo inicial = Disponible = ${TRABAJO[*]})"
while [ $avance -eq 1 ]; do
    avance=0
    for ((p=0; p<NP; p++)); do
        [ "${FIN[$p]}" -eq 1 ] && continue
        puede=1
        for ((r=0; r<NR; r++)); do
            nec=$((MAXI[$p,$r] - ASIG[$p,$r]))
            [ $nec -gt ${TRABAJO[$r]} ] && puede=0
        done
        if [ $puede -eq 1 ]; then
            for ((r=0; r<NR; r++)); do
                TRABAJO[$r]=$((TRABAJO[$r] + ASIG[$p,$r]))
            done
            FIN[$p]=1
            SECUENCIA+=("${PROC_NOMBRE[$p]}")
            echo "   Paso $paso: ${PROC_NOMBRE[$p]} puede terminar -> libera recursos. Trabajo = ${TRABAJO[*]}"
            paso=$((paso+1))
            avance=1
        fi
    done
done

BLOQUEADOS=()
for ((p=0; p<NP; p++)); do
    [ "${FIN[$p]}" -eq 0 ] && BLOQUEADOS+=("$p")
done
echo "--------------------------------------------------------------"

# ----------------------- Resultado -----------------------------------
if [ ${#BLOQUEADOS[@]} -eq 0 ]; then
    RESULTADO="SEGURO"
    echo " RESULTADO: ESTADO SEGURO (no hay interbloqueo)"
    if [ ${#SECUENCIA[@]} -gt 0 ]; then
        sec=$(printf "%s -> " "${SECUENCIA[@]}"); sec="${sec% -> }"
        echo " Secuencia segura: $sec"
    else
        echo " Todos los procesos ya terminaron."
    fi
else
    RESULTADO="INTERBLOQUEO"
    echo " RESULTADO: INTERBLOQUEO DETECTADO (estado no seguro)"
    echo " Espera circular:"
    for p in "${BLOQUEADOS[@]}"; do
        tiene=""; espera=""
        for ((r=0; r<NR; r++)); do
            if [ "${ASIG[$p,$r]}" -gt 0 ]; then tiene+="${RECURSOS[$r]} "; fi
            if [ $((MAXI[$p,$r] - ASIG[$p,$r])) -gt 0 ]; then
                duenio="nadie"
                for ((q=0; q<NP; q++)); do
                    [ "${ASIG[$q,$r]}" -gt 0 ] && duenio="${PROC_NOMBRE[$q]}"
                done
                espera+="${RECURSOS[$r]}(lo tiene $duenio) "
            fi
        done
        echo "   - ${PROC_NOMBRE[$p]} tiene [ ${tiene:-nada }] y espera [ $espera]"
    done
    echo " Solucion sugerida: expropiar un recurso (recuperacion) o asignar"
    echo " todos los recursos a un proceso primero (prevencion)."
fi

# ----------------------- Comparacion con el juego --------------------
echo "--------------------------------------------------------------"
echo " Resultado reportado por el juego : $JUEGO"
echo " Resultado del script             : $RESULTADO"
if [ "$JUEGO" = "COMPLETADO" ] && [ "$RESULTADO" = "SEGURO" ]; then
    echo " Coinciden: SI (nivel completado = estado seguro)"
elif [ "$JUEGO" = "$RESULTADO" ]; then
    echo " Coinciden: SI"
else
    echo " Coinciden: NO (revisar el escenario)"
fi
echo "=============================================================="
