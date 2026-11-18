# Registro de pruebas – Deadlock Dungeon (versión final)

Este registro separa lo **probado** de lo **pendiente por probar**. No se registra ningún resultado que no se haya comprobado.

---

## A. Pruebas de los scripts de análisis (realizadas)

Entorno: Linux, Bash 5. PowerShell 7.4 (multiplataforma) ejecutado en Linux.
Las salidas completas están en `pruebas/resultados_scripts/`.

| # | Escenario | Esperado | Bash | PowerShell | ¿Coincide con el juego? |
|---|---|---|---|---|---|
| S1 | `escenario_nivel1_ejemplo.txt` (todo libre) | SEGURO, secuencia Caballero -> Mago | SEGURO, Caballero -> Mago ✅ | SEGURO, Caballero -> Mago ✅ | Sí |
| S2 | `escenario_nivel2_interbloqueo.txt` (cada uno tiene un recurso) | INTERBLOQUEO, espera circular | INTERBLOQUEO + espera circular ✅ | INTERBLOQUEO + espera circular ✅ | Sí |
| S3 | `escenario_nivel3_seguro.txt` (Caballero tiene ambos) | SEGURO, Caballero -> Mago | SEGURO, Caballero -> Mago ✅ | SEGURO, Caballero -> Mago ✅ | Sí |
| S4 | Escenario con finales de línea de Windows (CRLF) | Se lee igual que S2 | INTERBLOQUEO ✅ | INTERBLOQUEO ✅ | Sí |
| S5 | Nivel completado (ambos TERMINADO) | SEGURO, "todos terminaron" | ✅ | ✅ | Sí |
| S6 | Sin argumentos / archivo inexistente | Mensaje de uso o error | Muestra uso / error ✅ | Pide el parámetro / error ✅ | – |

**Pruebas en el computador del equipo (Windows 11, 14/11/2026):**

| # | Prueba | Resultado | Captura |
|---|---|---|---|
| W1 | `analizar.ps1` en **Windows PowerShell 5.1** con el escenario del nivel 2 exportado por el juego | INTERBLOQUEO, espera circular, "Coinciden: SI" ✅ | `S2_powershell_nivel2_interbloqueo.png` |
| W2 | `analizar.ps1` con el escenario del nivel 3 exportado por el juego (Caballero ya terminado) | ESTADO SEGURO, secuencia "Mago", "Coinciden: SI" ✅ | `S3_powershell_nivel3_seguro.png` |
| W3 | `analizar.sh` en **Git Bash (MINGW64)** con el escenario del nivel 2 | INTERBLOQUEO, "Coinciden: SI" ✅ | `S4_bash_nivel2_interbloqueo.png` |

---

## B. Prueba de la lógica del juego fuera de GameMaker (realizada)

El código GML de `scr_deadlock.gml` y `obj_control_Create.gml` se ejecutó en Node.js (`pruebas/simulacion_logica.js`), reemplazando las funciones de GameMaker por equivalentes simples. Esto prueba **la lógica**, no la parte gráfica.
Salida completa: `pruebas/resultados_scripts/simulacion_logica_juego.txt`.

| # | Acción | Esperado | Resultado |
|---|---|---|---|
| L1 | Nivel 1: dar el Escudo al Caballero | Solicitud rechazada (no lo necesita) | ✅ Rechazada |
| L2 | Nivel 1: Llave→Caballero, Escudo→Mago, EJECUTAR | Ambos salen, +100 | ✅ superado, 100 pts |
| L3 | Nivel 2: EJECUTAR al inicio | INTERBLOQUEO con explicación de la espera circular | ✅ |
| L4 | Nivel 2: expropiar el Escudo, dárselo al Caballero, EJECUTAR | Caballero sale, sugiere secuencia "Mago" | ✅ |
| L5 | Nivel 2: dar ambos al Mago, EJECUTAR | Nivel superado (+70 por 1 expropiación y 1 bloqueo) | ✅ 70 pts |
| L6 | Nivel 3: Llave→Caballero, Escudo→Mago | Estado NO SEGURO antes de ejecutar | ✅ |
| L7 | Nivel 3: EJECUTAR en ese estado | Derrota por interbloqueo | ✅ |
| L8 | Nivel 3: ambos al Caballero, EJECUTAR, luego ambos al Mago, EJECUTAR | Nivel superado, +100 | ✅ |
| L9 | Archivos exportados | Formato correcto y legible por los scripts | ✅ |
| L10 | Pregunta N1: responder la opción correcta | +20 puntos, aciertos = 1 | ✅ |
| L11 | Responder dos veces la misma pregunta | El segundo clic se ignora | ✅ |
| L12 | Pregunta N2: responder una opción incorrecta | No suma puntos | ✅ |
| L13 | Pregunta N3 correcta y CONTINUAR | Pantalla de fin, aciertos 2/3 | ✅ |
| L14 | Sonidos | Se reproducen música, clic, asignar, error, bloqueo y victoria | ✅ (llamadas verificadas en la simulación) |

---

## C. Pruebas dentro de GameMaker

| # | Prueba | Resultado | Evidencia |
|---|---|---|---|
| G1 | El juego abre en el menú principal | OK | `G1_menu_principal.png` |
| G2 | ENTER inicia el Nivel 1 (estado SEGURO, secuencia Caballero -> Mago) | OK | `G2_nivel1_inicio.png` |
| G3 | Asignar Llave al Caballero y EJECUTAR: el Caballero termina, libera recursos y el juego sugiere la secuencia segura (Mago) | OK | `G3_nivel1_caballero_termina.png` |
| G4 | Nivel 1 se completa con EJECUTAR (+100 puntos) | OK | `G4_nivel1_superado.png` |
| G5 | Nivel 2 muestra el estado NO SEGURO (interbloqueo) | OK | `A1_version_inicial_nivel2_figuras.png`, `escenario_nivel2_interbloqueo.txt` |
| G6 | Nivel 2: expropiar (2 expropiaciones) y resolver (+60 puntos) | OK | `G6a_nivel2_tras_expropiar.png`, `G6b_nivel2_superado.png` |
| G7 | Nivel 3: asignación cruzada provoca derrota | | |
| G8 | Nivel 3 se completa y aparece la pantalla de VICTORIA (320 / 360, 3 / 3 preguntas) | OK | `G8_victoria_final.png` |
| G9 | El juego exporta los escenarios a `%LOCALAPPDATA%\Deadlock_Dungeon` | OK | `S1_archivos_exportados_por_el_juego.png` |
| G10 | Los archivos exportados se analizan con `analizar.ps1` y `analizar.sh` | OK | `S2`, `S3`, `S4` |
| G11 | Suena la música y la tecla M la pausa | | |
| G12 | Al superar un nivel aparece la pregunta; la respuesta correcta se marca en verde (+20) y la incorrecta en rojo, con su explicación | OK | `G12a_pregunta_nivel1.png`, `G12b_pregunta_nivel2.png`, `G12c_pregunta_nivel3_correcta.png`, `G12d_pregunta_nivel3_incorrecta.png` |

Configuración y desarrollo en GameMaker:

| Evidencia | Captura |
|---|---|
| Script `scr_deadlock` creado con el código | `03_script_scr_deadlock.png` |
| Habitación `rm_nivel` (configuración inicial 1366×768, luego cambiada a 1280×660) | `04_habitacion_configuracion_inicial.png` |
| Activos del proyecto (objeto, habitación, script, 6 sprites, 6 sonidos), habitación 1280×660 y compilación exitosa ("SUCCESS: Run Program Complete") | `05_activos_y_compilacion_exitosa.png` |
| Sprite pixel art importado (`spr_mago`) | `06_sprite_mago_importado.png` |
| Sonido importado (`snd_asignar`) | `07_sonido_importado.png` |
| Antes: primera versión con figuras geométricas | `A1_version_inicial_nivel2_figuras.png` |
| Después: menú y niveles con pixel art | `G1_menu_principal.png`, `G2_nivel1_inicio.png` |

---

## E. Pruebas de la versión final (17/11/2026)

### E.1 Juego en GameMaker (IDE v2026.1.0.27, runtime 2026.1.0.28)

| # | Prueba | Resultado | Evidencia |
|---|---|---|---|
| F1 | Nivel 3 – regla de orden: dar el Escudo al Mago sin la Llave es rechazado y se explica la prevención | OK | `G17_nivel3_regla_orden.png` |
| F2 | Nivel 4 – dar la Antorcha al Arquero cambia el estado a NO SEGURO (Caballero -> Mago -> Arquero bloqueados) | OK | `G13_nivel4_no_seguro.png` |
| F3 | Nivel 4 – EJECUTAR en ese estado detecta la espera circular de tres procesos y termina el nivel en derrota | OK | `G14_nivel4_espera_circular_tres.png` |
| F4 | Nivel 4 – con la Antorcha al Mago el estado sigue SEGURO; el Mago termina, libera sus recursos y sale por la puerta | OK | `G15_nivel4_mago_sale.png` |
| F5 | Pregunta del nivel 4 (algoritmo del banquero) | OK | `G12e_pregunta_nivel4.png` |
| F6 | Pantalla de victoria tras los 4 niveles | OK: 460 / 480 puntos, 4 / 4 preguntas | `G16_victoria_final.png` |

### E.2 Scripts de análisis con 3 procesos y 3 recursos

| # | Prueba | Resultado | Evidencia |
|---|---|---|---|
| F7 | `analizar.ps1` (PowerShell 5.1) con `escenario_nivel4_interbloqueo.txt` | INTERBLOQUEO, espera circular de 3, "Coinciden: SI" | `S5_powershell_nivel4.png` |
| F8 | `analizar.sh` (Git Bash) con `escenario_nivel4_inicio.txt` | SEGURO, secuencia Mago -> Caballero -> Arquero, "Coinciden: SI" | `S6_bash_nivel4.png` |

### E.3 Entorno: monitoreo y respaldo (Windows 11 Pro)

| # | Prueba | Resultado | Evidencia |
|---|---|---|---|
| F9 | `monitorear.ps1` con el juego abierto | Runner.exe PID 23884, prioridad High, 10 hilos, CPU 18,1–18,6 %, RAM 123,5 MB; servicios Audiosrv, Schedule, EventLog y WinDefend en ejecución | `H01_monitoreo.png` |
| F10 | Proceso del juego en el Administrador de tareas | Runner.exe en ejecución (PID 23884) | `H02_proceso_del_juego.png` |
| F11 | `respaldo.ps1 -ProgramarTarea` | RESPALDO OK (10 archivos, 2,8 KB) y tarea `DeadlockDungeon_Respaldo` creada (estado Ready) | `H03_respaldo.png` |
| F12 | Tarea en el Programador de tareas | OK: `DeadlockDungeon_Respaldo`, estado Listo, todos los días a las 8:00 p. m., próxima ejecución 18/11/2026 | `H04_tarea_programada.png` |
| F13 | Restauración de un escenario eliminado (`-Restaurar`) | OK: RESTAURADO desde `respaldo_20261117_211428.zip` (10 escenarios disponibles) | `H05_restauracion.png` |

### E.4 Entorno en Linux (Ubuntu 24.04 LTS)

Salidas en `pruebas/resultados_entorno_linux/`.

| # | Prueba | Resultado |
|---|---|---|
| F14 | `monitorear.sh` (3 muestras) | CPU, RAM, disco y procesos medidos y guardados en CSV |
| F15 | `respaldo.sh` | RESPALDO OK (5 archivos) |
| F16 | Se borró `escenario_nivel4_interbloqueo.txt` y se restauró con `respaldo.sh --restaurar` | Archivo recuperado (5 escenarios) |
| F17 | `respaldo.sh --programar` | Línea de cron generada (cron no instalado en el entorno de prueba) |

### E.5 Lógica (simulación)
`pruebas/simulacion_logica.js` incluye ahora el nivel 4 (estado inicial seguro, estado no seguro al dar la Antorcha al Arquero, derrota por espera circular de 3 y victoria con la secuencia segura) y la regla de orden del nivel 3. Todas las verificaciones pasan (`resultados_scripts/simulacion_logica_juego.txt`).

## D. Errores encontrados y correcciones

| Fecha | Error | Corrección |
|---|---|---|
| 2026-11-13 | Al ejecutar en GameMaker: `Variable obj_control.estado_juego not set before reading it` (Create, línea 8) | El código del evento Step estaba pegado en el evento Create. Se pegó cada archivo en su evento correspondiente |
| 2026-11-14 | La primera versión usaba figuras geométricas (poco atractiva) | Se crearon sprites pixel art originales y música/sonidos (ver `A1_...` vs `G1_...`) |
| 2026-11-13 | El botón EJECUTAR se salía de la pantalla del portátil (habitación 1366×768) | Se cambió la habitación a 1280×660 y se reorganizó la interfaz |
| 2026-11-13 | En la simulación faltaba `string_lower` en las funciones simuladas | Se agregó al simulador (el código GML no cambió) |
| 2026-11-17 | Nivel 3 muy parecido al nivel 2 | Se rediseñó como nivel de PREVENCIÓN con regla de orden de recursos |
| 2026-11-17 | En el nivel 4, un recurso libre quedaba sobre la cabeza del Arquero y parecía suyo | Se movieron las posiciones de los recursos libres |
| 2026-11-17 | `analizar.ps1` no se encontraba al ejecutarlo desde `scripts\escenarios` | Se ejecuta desde la carpeta `scripts` (`cd ..`) |
| 2026-11-17 | Git Bash se abrió en la carpeta del usuario | Se navegó a la carpeta con `cd "/d/Descargas/.../scripts"` |
