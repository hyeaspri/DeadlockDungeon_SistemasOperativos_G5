/// obj_control - Evento STEP
/// ---------------------------------------------------------------------
/// Se ejecuta en cada fotograma: lee teclado y mouse, y recalcula
/// el estado del sistema (seguro / interbloqueo).
/// ---------------------------------------------------------------------

// ------------------------- MUSICA (tecla M) ---------------------------
if (keyboard_check_pressed(ord("M"))) {
    if (audio_is_paused(musica)) {
        audio_resume_sound(musica);
    } else {
        audio_pause_sound(musica);
    }
}

// ------------------------- MENU PRINCIPAL ----------------------------
if (estado_juego == "menu") {
    if (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
        puntos = 0;
        aciertos = 0;
        sonido(snd_clic);
        cargar_nivel(1);
    }
    exit;
}

// ------------------------- FIN DEL JUEGO -----------------------------
if (estado_juego == "fin") {
    if (keyboard_check_pressed(ord("R")) || keyboard_check_pressed(vk_enter)) {
        estado_juego = "menu";
    }
    exit;
}

// ------------------- PREGUNTA ENTRE NIVELES --------------------------
if (estado_juego == "pregunta") {
    if (respuesta == -1) {
        // Responder con las teclas 1, 2, 3 o con clic en una opcion
        for (var i = 0; i < 3; i++) {
            if (keyboard_check_pressed(ord(string(i + 1)))) {
                responder(i);
            }
            if (respuesta == -1 && mouse_check_button_pressed(mb_left)) {
                var _oy = opc_y0 + i * opc_sep;
                if (point_in_rectangle(mouse_x, mouse_y, opc_x1, _oy, opc_x2, _oy + opc_alto)) {
                    responder(i);
                }
            }
        }
    }
    else {
        // Continuar con ENTER o con el boton CONTINUAR
        if (keyboard_check_pressed(vk_enter)
            || (mouse_check_button_pressed(mb_left) && point_in_rectangle(mouse_x, mouse_y, boton_x1, boton_y1, boton_x2, boton_y2))) {
            continuar();
        }
    }
    exit;
}

// ----------------------- REINICIAR NIVEL (R) -------------------------
if (keyboard_check_pressed(ord("R"))) {
    cargar_nivel(nivel);
    exit;
}

// ------------- Analisis del estado actual (algoritmo SO) -------------
analisis = so_analizar(asignado, maximo, total, terminado, num_proc, num_rec);

// --------------------------- CLIC DEL MOUSE --------------------------
if (mouse_check_button_pressed(mb_left)) {
    var _mx = mouse_x;
    var _my = mouse_y;

    // 1) Boton principal (EJECUTAR / SIGUIENTE / REINTENTAR)
    if (point_in_rectangle(_mx, _my, boton_x1, boton_y1, boton_x2, boton_y2)) {
        sonido(snd_clic);
        if (estado_juego == "jugando") {
            seleccionado = -1;
            ejecutar();
        }
        else if (estado_juego == "superado") {
            // Antes de pasar de nivel, se responde una pregunta
            respuesta = -1;
            estado_juego = "pregunta";
        }
        else if (estado_juego == "derrota") {
            cargar_nivel(nivel);
        }
        exit;
    }

    // Si no se esta jugando, no se permiten mas acciones
    if (estado_juego != "jugando") exit;

    // 2) Clic sobre un recurso
    for (var r = 0; r < num_rec; r++) {
        var _pos = pos_recurso(r);
        if (point_distance(_mx, _my, _pos[0], _pos[1]) < 24) {
            var _dueno = so_quien_tiene(asignado, r, num_proc);
            if (_dueno == -1) {
                // Recurso libre: seleccionarlo (o deseleccionarlo)
                if (seleccionado == r) {
                    seleccionado = -1;
                    mensaje = "Seleccion cancelada.";
                } else {
                    seleccionado = r;
                    sonido(snd_clic);
                    mensaje = nombres_rec[r] + " seleccionado. Ahora haz clic en un personaje.";
                }
            }
            else {
                // Recurso ocupado: expropiar (recuperacion del interbloqueo)
                if (nivel == 3) {
                    sonido(snd_error);
                    mensaje = "Aqui no se permite expropiar. Debes PREVENIR el interbloqueo.\nPulsa R para reiniciar el nivel.";
                } else {
                    asignado[_dueno][r] = 0;
                    expropiaciones += 1;
                    sonido(snd_clic);
                    mensaje = "Recuperacion: se expropio " + nombres_rec[r] + " a " + nombres_proc[_dueno] + ". Ahora esta libre.";
                }
            }
            exit;
        }
    }

    // 3) Clic sobre un personaje (con un recurso seleccionado)
    for (var p = 0; p < num_proc; p++) {
        if (point_in_rectangle(_mx, _my, proc_x[p] - 35, proc_y[p] - 45, proc_x[p] + 35, proc_y[p] + 45)) {
            if (seleccionado == -1) {
                mensaje = "Primero haz clic en un recurso libre.";
            } else {
                asignar(p, seleccionado);
                seleccionado = -1;
            }
            exit;
        }
    }
}
