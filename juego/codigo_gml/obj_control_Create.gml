/// obj_control - Evento CREATE
/// =====================================================================
/// Variables del juego y funciones de cada nivel.
/// Procesos: 0 = Caballero, 1 = Mago, 2 = Arquero (nivel 4)
/// Recursos: 0 = Llave,     1 = Escudo, 2 = Antorcha (nivel 4)
/// =====================================================================

nombres_proc = ["Caballero", "Mago", "Arquero"];
nombres_rec  = ["Llave", "Escudo", "Antorcha"];
num_proc = 2;          // procesos del nivel actual (se ajusta en cargar_nivel)
num_rec  = 2;          // recursos del nivel actual
total    = [1, 1];     // unidades de cada recurso
num_niveles = 4;

nivel        = 0;
puntos       = 0;
estado_juego = "menu";   // "menu", "jugando", "superado", "derrota", "fin"
seleccionado = -1;       // recurso seleccionado con el mouse (-1 = ninguno)
mensaje      = "";
ruta_export  = "";
expropiaciones = 0;
bloqueos       = 0;

asignado  = [[0, 0], [0, 0]];
maximo    = [[0, 0], [0, 0]];
terminado = [false, false];

// Animacion de salida (posicion y transparencia de cada personaje)
anim_x    = [0, 0, 0];
anim_y    = [0, 0, 0];
anim_alfa = [1, 1, 1];

titulo_nivel = "";
desc_nivel   = "";

// ---------------------------------------------------------------------
// Preguntas entre niveles (refuerzan los conceptos de SO)
// ---------------------------------------------------------------------
preguntas = [
    {
        texto: "En el Nivel 1 le diste la Llave al Caballero.\nQue concepto de Sistemas Operativos representa esa accion?",
        opciones: [
            "La asignacion de un recurso a un proceso",
            "La creacion de un nuevo proceso",
            "La liberacion de memoria RAM"
        ],
        correcta: 0,
        explicacion: "El jugador actua como el sistema operativo: decide que proceso (Caballero) recibe cada recurso (Llave)."
    },
    {
        texto: "En el Nivel 2 el Caballero y el Mago quedaron bloqueados.\nQue condicion provoco el interbloqueo?",
        opciones: [
            "Habia demasiados recursos libres en la mazmorra",
            "Espera circular: cada uno retenia un recurso y esperaba el que tenia el otro",
            "Los procesos terminaron demasiado rapido"
        ],
        correcta: 1,
        explicacion: "Se cumplieron las 4 condiciones de Coffman: exclusion mutua, retencion y espera, no expropiacion y espera circular."
    },
    {
        texto: "En el Nivel 3 habia que pedir siempre la Llave antes que el Escudo.\nQue condicion de Coffman rompe esa regla de orden?",
        opciones: [
            "La exclusion mutua",
            "La espera circular",
            "La no expropiacion"
        ],
        correcta: 1,
        explicacion: "Con un orden fijo de recursos nadie puede retener el Escudo mientras espera la Llave, asi que nunca se cierra un ciclo de espera. Eso es PREVENCION del interbloqueo."
    },
    {
        texto: "En el Nivel 4 solo quedaba la Antorcha libre.\nPor que habia que darsela al Mago y no al Arquero?",
        opciones: [
            "Porque el Mago es el proceso mas importante",
            "Porque el Arquero no necesitaba la Antorcha",
            "Porque asi el estado seguia SEGURO: Mago -> Caballero -> Arquero"
        ],
        correcta: 2,
        explicacion: "Darla al Arquero cerraba una espera circular de 3 procesos (Caballero espera al Mago, el Mago al Arquero y el Arquero al Caballero). El banquero solo concede una solicitud si el nuevo estado sigue siendo seguro."
    }
];
respuesta = -1;   // opcion elegida (-1 = sin responder)
aciertos  = 0;

// Botones de las opciones
opc_x1   = room_width / 2 - 460;
opc_x2   = room_width / 2 + 460;
opc_y0   = 250;
opc_alto = 58;
opc_sep  = 72;

// Estado calculado por el algoritmo (se actualiza en Step)
analisis = { seguro: true, secuencia: [], bloqueados: [] };

// Posiciones en pantalla (habitacion de 1280 x 660). Se ajustan en cargar_nivel.
proc_x  = [room_width * 0.22, room_width * 0.78];
proc_y  = [340, 340, 340];
libre_x = [room_width * 0.43, room_width * 0.57];
libre_y = [250, 250, 250];
puerta_x = room_width / 2;
puerta_y = 75;

// Boton principal (EJECUTAR / SIGUIENTE / REINTENTAR)
boton_x1 = room_width / 2 - 110;
boton_y1 = 590;
boton_x2 = room_width / 2 + 110;
boton_y2 = 628;


// ---------------------------------------------------------------------
// Dibujar texto con sombra (para que se lea sobre el fondo)
// ---------------------------------------------------------------------
texto_sombra = function(_x, _y, _txt, _col, _escala) {
    draw_set_colour(c_black);
    draw_text_transformed(_x + 2, _y + 2, _txt, _escala, _escala, 0);
    draw_set_colour(_col);
    draw_text_transformed(_x, _y, _txt, _escala, _escala, 0);
};


// ---------------------------------------------------------------------
// Sonido: reproducir un efecto
// ---------------------------------------------------------------------
sonido = function(_snd) {
    audio_play_sound(_snd, 5, false);
};


// ---------------------------------------------------------------------
// Responder la pregunta del nivel
// ---------------------------------------------------------------------
responder = function(_i) {
    if (respuesta != -1) return;
    respuesta = _i;
    if (_i == preguntas[nivel - 1].correcta) {
        puntos += 20;
        aciertos += 1;
        sonido(snd_victoria);
    } else {
        sonido(snd_error);
    }
};


// ---------------------------------------------------------------------
// Continuar despues de la pregunta (siguiente nivel o fin)
// ---------------------------------------------------------------------
continuar = function() {
    if (respuesta == -1) return;
    respuesta = -1;
    sonido(snd_clic);
    if (nivel < num_niveles) {
        cargar_nivel(nivel + 1);
    } else {
        estado_juego = "fin";
    }
};


// ---------------------------------------------------------------------
// Cargar la configuracion inicial de cada nivel
// ---------------------------------------------------------------------
cargar_nivel = function(_n) {
    nivel = _n;
    estado_juego = "jugando";
    seleccionado = -1;
    expropiaciones = 0;
    bloqueos = 0;

    // Niveles 1 a 3: 2 procesos y 2 recursos.  Nivel 4: 3 procesos y 3 recursos.
    if (_n <= 3) {
        num_proc = 2;
        num_rec  = 2;
        total     = [1, 1];
        terminado = [false, false];
        proc_x  = [room_width * 0.22, room_width * 0.78];
        libre_x = [room_width * 0.43, room_width * 0.57];
        libre_y = [250, 250];
    } else {
        num_proc = 3;
        num_rec  = 3;
        total     = [1, 1, 1];
        terminado = [false, false, false];
        proc_x  = [room_width * 0.17, room_width * 0.83, room_width * 0.50];
        libre_x = [room_width * 0.33, room_width * 0.40, room_width * 0.67];   // libres, lejos de las cabezas
        libre_y = [245, 245, 245];
    }
    for (var p = 0; p < num_proc; p++) {
        anim_x[p] = proc_x[p];
        anim_y[p] = proc_y[p];
        anim_alfa[p] = 1;
    }

    if (_n == 1) {
        titulo_nivel = "Nivel 1: La primera mision";
        desc_nivel = "El Caballero necesita la Llave y el Mago necesita el Escudo.\nHaz clic en un recurso y luego en el personaje. Despues pulsa EJECUTAR.";
        asignado = [[0, 0], [0, 0]];
        maximo   = [[1, 0], [0, 1]];
    }
    else if (_n == 2) {
        titulo_nivel = "Nivel 2: El intercambio imposible";
        desc_nivel = "Ambos necesitan Llave y Escudo, pero cada uno ya tiene uno. Pulsa EJECUTAR.\nPara resolverlo, haz clic en un recurso ocupado para EXPROPIARLO (recuperacion).";
        asignado = [[1, 0], [0, 1]];   // Caballero tiene Llave, Mago tiene Escudo
        maximo   = [[1, 1], [1, 1]];
    }
    else if (_n == 3) {
        titulo_nivel = "Nivel 3: La salida segura (regla del orden)";
        desc_nivel = "PREVENCION: los recursos se piden en orden: primero la LLAVE y despues el ESCUDO.\nAmbos necesitan los dos y no se puede expropiar. Prueba la regla.";
        asignado = [[0, 0], [0, 0]];
        maximo   = [[1, 1], [1, 1]];
    }
    else if (_n == 4) {
        titulo_nivel = "Nivel 4: El circulo de tres";
        desc_nivel = "Tres procesos y tres recursos. Solo queda la Antorcha libre y NO se puede expropiar.\nAntes de asignar, mira si el estado sigue SEGURO (algoritmo del banquero).";
        //            Llave Escudo Antorcha
        asignado = [[1, 0, 0],      // Caballero tiene la Llave
                    [0, 1, 0],      // Mago tiene el Escudo
                    [0, 0, 0]];     // Arquero no tiene nada
        maximo   = [[1, 1, 0],      // Caballero necesita Llave y Escudo
                    [0, 1, 1],      // Mago necesita Escudo y Antorcha
                    [1, 0, 1]];     // Arquero necesita Antorcha y Llave
    }
    mensaje = "Nivel cargado. Observa el estado del sistema arriba a la derecha.";
};


// ---------------------------------------------------------------------
// Asignar el recurso seleccionado a un proceso
// ---------------------------------------------------------------------
asignar = function(_p, _r) {
    if (terminado[_p]) {
        mensaje = nombres_proc[_p] + " ya salio de la mazmorra.";
        return;
    }
    if (maximo[_p][_r] - asignado[_p][_r] <= 0) {
        mensaje = "Solicitud rechazada: " + nombres_proc[_p] + " no necesita " + nombres_rec[_r] + ".";
        sonido(snd_error);
        return;
    }
    // Nivel 3 - PREVENCION por orden de recursos: el Escudo (1) solo se
    // entrega a quien ya tiene la Llave (0). Asi no puede formarse un ciclo.
    if (nivel == 3 && _r == 1 && maximo[_p][0] > 0 && asignado[_p][0] == 0) {
        mensaje = "Solicitud rechazada por la REGLA DE ORDEN: " + nombres_proc[_p] + " debe tener primero la Llave.\nComo todos piden los recursos en el mismo orden, nunca se forma una espera circular.";
        sonido(snd_error);
        return;
    }
    asignado[_p][_r] = 1;
    sonido(snd_asignar);
    mensaje = "Recurso " + nombres_rec[_r] + " asignado a " + nombres_proc[_p] + ".";
};


// ---------------------------------------------------------------------
// Ejecutar: los procesos que tienen todo lo que necesitan terminan,
// salen por la puerta y liberan sus recursos.
// ---------------------------------------------------------------------
ejecutar = function() {
    var _salieron = "";
    var _avance = true;
    while (_avance) {
        _avance = false;
        for (var p = 0; p < num_proc; p++) {
            if (!terminado[p]) {
                var _completo = true;
                for (var r = 0; r < num_rec; r++) {
                    if (asignado[p][r] < maximo[p][r]) {
                        _completo = false;
                    }
                }
                if (_completo) {
                    terminado[p] = true;
                    for (var r = 0; r < num_rec; r++) {
                        asignado[p][r] = 0;   // libera sus recursos
                    }
                    if (_salieron != "") _salieron += " y ";
                    _salieron += nombres_proc[p];
                    _avance = true;
                }
            }
        }
    }

    var _todos = true;
    for (var p = 0; p < num_proc; p++) {
        if (!terminado[p]) _todos = false;
    }

    var _resultado = "";
    if (_todos) {
        var _ganados = max(20, 100 - 20 * expropiaciones - 10 * bloqueos);
        puntos += _ganados;
        estado_juego = "superado";
        _resultado = "COMPLETADO";
        sonido(snd_victoria);
        mensaje = "Todos los procesos terminaron y salieron. +" + string(_ganados) + " puntos.\nPulsa SIGUIENTE para responder la pregunta del nivel.";
    }
    else {
        var _res = so_analizar(asignado, maximo, total, terminado, num_proc, num_rec);
        var _inicio = "";
        if (_salieron != "") _inicio = _salieron + " termino y libero sus recursos.\n";

        if (!_res.seguro) {
            bloqueos += 1;
            _resultado = "INTERBLOQUEO";
            sonido(snd_bloqueo);
            mensaje = _inicio + "INTERBLOQUEO DETECTADO (espera circular):\n"
                + so_explicar_espera(asignado, maximo, _res.bloqueados, nombres_proc, nombres_rec, num_proc, num_rec)
                + "Ninguno puede continuar.";
            if (nivel >= 3) {
                estado_juego = "derrota";
                mensaje += " En este nivel debias PREVENIRLO. Pulsa R para reintentar.";
            } else {
                mensaje += " Expropia un recurso para recuperarte.";
            }
        }
        else {
            _resultado = "SEGURO";
            mensaje = _inicio + "No hay interbloqueo, pero faltan recursos por asignar.\nSecuencia segura sugerida: "
                + so_texto_secuencia(_res.secuencia, nombres_proc);
        }
    }

    exportar_escenario(_resultado);
};


// ---------------------------------------------------------------------
// Exportar el escenario a un archivo de texto para los scripts
// Bash (analizar.sh) y PowerShell (analizar.ps1).
// Formato:  PROCESO;nombre;asignado;maximo;estado
// Archivo:  escenario_nivelN_resultado.txt  (en la carpeta de guardado)
// ---------------------------------------------------------------------
exportar_escenario = function(_resultado) {
    var _nombre = "escenario_nivel" + string(nivel) + "_" + string_lower(_resultado) + ".txt";
    var _f = file_text_open_write(_nombre);

    file_text_write_string(_f, "# Escenario exportado por Deadlock Dungeon");
    file_text_writeln(_f);
    file_text_write_string(_f, "NIVEL;" + string(nivel));
    file_text_writeln(_f);
    var _recs = "";
    var _tot  = "";
    for (var r = 0; r < num_rec; r++) {
        if (r > 0) { _recs += ","; _tot += ","; }
        _recs += nombres_rec[r];
        _tot  += string(total[r]);
    }
    file_text_write_string(_f, "RECURSOS;" + _recs);
    file_text_writeln(_f);
    file_text_write_string(_f, "TOTAL;" + _tot);
    file_text_writeln(_f);

    for (var p = 0; p < num_proc; p++) {
        var _estado = "ACTIVO";
        if (terminado[p]) _estado = "TERMINADO";
        var _asig = "";
        var _maxi = "";
        for (var r = 0; r < num_rec; r++) {
            if (r > 0) { _asig += ","; _maxi += ","; }
            _asig += string(asignado[p][r]);
            _maxi += string(maximo[p][r]);
        }
        var _linea = "PROCESO;" + nombres_proc[p] + ";" + _asig + ";" + _maxi + ";" + _estado;
        file_text_write_string(_f, _linea);
        file_text_writeln(_f);
    }

    file_text_write_string(_f, "JUEGO;" + _resultado);
    file_text_writeln(_f);
    file_text_close(_f);

    ruta_export = game_save_id + _nombre;
    show_debug_message("Escenario exportado en: " + ruta_export);
};


// ---------------------------------------------------------------------
// Posicion en pantalla de un recurso (libre o junto a su dueno)
// ---------------------------------------------------------------------
pos_recurso = function(_r) {
    var _q = so_quien_tiene(asignado, _r, num_proc);
    if (_q == -1) {
        return [libre_x[_r], libre_y[_r]];
    }
    if (num_proc == 2) {
        return [proc_x[_q] - 36 + 72 * _r, proc_y[_q] - 125];   // sobre la cabeza
    }
    return [proc_x[_q] + 80, proc_y[_q] - 80 + 58 * _r];       // al lado (nivel 4)
};


// ---------------------------------------------------------------------
// Musica de fondo (en bucle, volumen bajo). Tecla M = pausar / reanudar
// ---------------------------------------------------------------------
musica = audio_play_sound(snd_musica, 10, true);
audio_sound_gain(musica, 0.35, 0);
