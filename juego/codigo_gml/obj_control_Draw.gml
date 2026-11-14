/// obj_control - Evento DRAW
/// =====================================================================
/// Dibuja la mazmorra (pixel art), los procesos, los recursos y los
/// mensajes. Necesita estos sprites: spr_fondo, spr_caballero,
/// spr_mago, spr_llave, spr_escudo, spr_puerta.
/// Habitacion: 1280 x 660.
/// (Los textos no llevan tildes porque la fuente por defecto puede
///  no mostrarlas.)
/// =====================================================================

var _w = room_width;
var _h = room_height;
var _oro = make_colour_rgb(235, 190, 60);
var _panel = make_colour_rgb(20, 14, 24);
var _spr_proc = [spr_caballero, spr_mago];
var _spr_rec  = [spr_llave, spr_escudo];

// --------------------------- FONDO -----------------------------------
draw_sprite(spr_fondo, 0, 0, 0);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --------------------------- MENU ------------------------------------
if (estado_juego == "menu") {
    draw_set_alpha(0.55);
    draw_set_colour(_panel);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);

    texto_sombra(_w / 2, 120, "DEADLOCK DUNGEON", _oro, 4);
    texto_sombra(_w / 2, 185, "La mazmorra de los recursos", c_white, 2);

    // Personajes y recursos (los pies quedan en y = 390)
    draw_sprite(spr_caballero, 0, _w / 2 - 210 - sprite_get_width(spr_caballero) / 2, 390 - sprite_get_height(spr_caballero));
    draw_sprite(spr_llave,     0, _w / 2 - 70 - sprite_get_width(spr_llave) / 2, 330 - sprite_get_height(spr_llave) / 2);
    draw_sprite(spr_escudo,    0, _w / 2 + 70 - sprite_get_width(spr_escudo) / 2, 330 - sprite_get_height(spr_escudo) / 2);
    draw_sprite(spr_mago,      0, _w / 2 + 210 - sprite_get_width(spr_mago) / 2, 390 - sprite_get_height(spr_mago));

    texto_sombra(_w / 2, 430, "Proyecto de Sistemas Operativos - Interbloqueos (Deadlocks)", c_white, 1.2);
    texto_sombra(_w / 2, 460, "Caballero y Mago = procesos     Llave y Escudo = recursos compartidos", c_ltgray, 1.2);
    texto_sombra(_w / 2, 530, "Presiona ENTER o haz clic para comenzar", c_lime, 1.6);
    texto_sombra(_w / 2, 580, "M = musica on / off", c_gray, 1);
    texto_sombra(_w / 2, 620, "UMB - Grupo 1 - Heidy Valeria Asprilla Rubiano y Daniela Rodriguez Reyes", c_ltgray, 1);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

// --------------------------- FIN -------------------------------------
if (estado_juego == "fin") {
    draw_set_alpha(0.55);
    draw_set_colour(_panel);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);

    draw_sprite(spr_puerta, 0, _w / 2 - sprite_get_width(spr_puerta) / 2, 60);
    draw_sprite(spr_caballero, 0, _w / 2 - 170 - sprite_get_width(spr_caballero) / 2, 180 - sprite_get_height(spr_caballero));
    draw_sprite(spr_mago, 0, _w / 2 + 170 - sprite_get_width(spr_mago) / 2, 180 - sprite_get_height(spr_mago));

    texto_sombra(_w / 2, 260, "VICTORIA!", c_lime, 4);
    texto_sombra(_w / 2, 330, "Ambos procesos salieron de la mazmorra sin interbloqueo.", c_white, 1.5);
    texto_sombra(_w / 2, 380, "Puntuacion final: " + string(puntos) + " / 360", _oro, 2);
    texto_sombra(_w / 2, 420, "Preguntas acertadas: " + string(aciertos) + " / 3", c_white, 1.3);
    texto_sombra(_w / 2, 470, "Presiona R o ENTER para volver al menu", c_ltgray, 1.3);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

// --------------------------- PREGUNTA --------------------------------
if (estado_juego == "pregunta") {
    var _preg = preguntas[nivel - 1];

    draw_set_alpha(0.75);
    draw_set_colour(_panel);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);

    texto_sombra(_w / 2, 60, "PREGUNTA DEL NIVEL " + string(nivel), _oro, 2.5);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
    draw_text_ext(_w / 2, 120, _preg.texto, 24, 1000);

    // Opciones
    for (var i = 0; i < 3; i++) {
        var _oy = opc_y0 + i * opc_sep;
        var _fondo = make_colour_rgb(45, 32, 50);
        if (respuesta == -1) {
            if (point_in_rectangle(mouse_x, mouse_y, opc_x1, _oy, opc_x2, _oy + opc_alto)) {
                _fondo = make_colour_rgb(80, 58, 90);
            }
        } else {
            if (i == _preg.correcta) {
                _fondo = make_colour_rgb(40, 120, 50);
            } else if (i == respuesta) {
                _fondo = make_colour_rgb(150, 40, 35);
            }
        }
        draw_set_colour(_fondo);
        draw_rectangle(opc_x1, _oy, opc_x2, _oy + opc_alto, false);
        draw_set_colour(_oro);
        draw_rectangle(opc_x1, _oy, opc_x2, _oy + opc_alto, true);
        draw_set_valign(fa_middle);
        texto_sombra(_w / 2, _oy + opc_alto / 2, string(i + 1) + ")  " + _preg.opciones[i], c_white, 1.2);
    }

    // Resultado de la respuesta
    draw_set_valign(fa_top);
    if (respuesta == -1) {
        texto_sombra(_w / 2, 480, "Haz clic en una opcion o presiona 1, 2 o 3", c_ltgray, 1.2);
    } else {
        if (respuesta == _preg.correcta) {
            texto_sombra(_w / 2, 475, "CORRECTO!  +20 puntos", c_lime, 1.8);
        } else {
            texto_sombra(_w / 2, 475, "INCORRECTO", c_red, 1.8);
        }
        draw_set_colour(c_white);
        draw_text_ext(_w / 2, 520, _preg.explicacion, 20, 1000);

        // Boton CONTINUAR
        draw_set_colour(make_colour_rgb(110, 35, 30));
        draw_rectangle(boton_x1, boton_y1, boton_x2, boton_y2, false);
        draw_set_colour(_oro);
        draw_rectangle(boton_x1, boton_y1, boton_x2, boton_y2, true);
        draw_rectangle(boton_x1 + 3, boton_y1 + 3, boton_x2 - 3, boton_y2 - 3, true);
        draw_set_valign(fa_middle);
        texto_sombra((boton_x1 + boton_x2) / 2, (boton_y1 + boton_y2) / 2, "CONTINUAR", _oro, 1.3);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

// --------------------------- PUERTA DE SALIDA ------------------------
draw_sprite(spr_puerta, 0, _w / 2 - sprite_get_width(spr_puerta) / 2, 10);
texto_sombra(_w / 2, 136, "SALIDA", _oro, 1);

// --------------------------- PANELES SUPERIORES ----------------------
draw_set_alpha(0.7);
draw_set_colour(_panel);
draw_rectangle(10, 8, 440, 88, false);
draw_rectangle(_w - 470, 8, _w - 10, 88, false);
draw_rectangle(_w / 2 - 380, 150, _w / 2 + 380, 205, false);
draw_set_alpha(1);
draw_set_colour(_oro);
draw_rectangle(10, 8, 440, 88, true);
draw_rectangle(_w - 470, 8, _w - 10, 88, true);

// Nivel y puntos (izquierda)
draw_set_halign(fa_left);
draw_set_valign(fa_top);
texto_sombra(22, 16, titulo_nivel, _oro, 1);
texto_sombra(22, 40, "Puntos: " + string(puntos), c_white, 1);
texto_sombra(22, 62, "Expropiaciones: " + string(expropiaciones) + "   Interbloqueos: " + string(bloqueos), c_white, 1);

// Estado del sistema (derecha) - algoritmo de seguridad
draw_set_halign(fa_right);
var _disp = so_disponibles(asignado, total, num_proc, num_rec);
texto_sombra(_w - 22, 16, "Disponibles: Llave=" + string(_disp[0]) + "  Escudo=" + string(_disp[1]), c_white, 1);
if (analisis.seguro) {
    texto_sombra(_w - 22, 40, "Estado del sistema: SEGURO", c_lime, 1);
    texto_sombra(_w - 22, 62, "Secuencia segura: " + so_texto_secuencia(analisis.secuencia, nombres_proc), c_lime, 1);
} else {
    texto_sombra(_w - 22, 40, "Estado del sistema: NO SEGURO (interbloqueo)", c_red, 1);
    texto_sombra(_w - 22, 62, "Procesos bloqueados: " + so_texto_secuencia(analisis.bloqueados, nombres_proc), c_red, 1);
}

// Descripcion del nivel
draw_set_halign(fa_center);
draw_set_colour(c_ltgray);
draw_text(_w / 2, 156, desc_nivel);

// --------------------------- RECURSOS LIBRES -------------------------
draw_set_valign(fa_middle);
texto_sombra(_w / 2, libre_y[0] - 40, "Recursos libres", c_ltgray, 1);

// --------------------------- PROCESOS --------------------------------
for (var p = 0; p < num_proc; p++) {
    var _px = proc_x[p];
    var _py = proc_y[p];
    var _alfa = 1;
    if (terminado[p]) _alfa = 0.35;

    // Sombra en el piso y sprite del personaje
    draw_set_alpha(0.4 * _alfa);
    draw_set_colour(c_black);
    draw_ellipse(_px - 45, _py + 55, _px + 45, _py + 75, false);
    draw_set_alpha(1);
    // Los pies del personaje quedan en _py + 62
    var _spr = _spr_proc[p];
    draw_sprite_ext(_spr, 0, _px - sprite_get_width(_spr) / 2, _py + 62 - sprite_get_height(_spr), 1, 1, 0, c_white, _alfa);

    // Nombre y datos del proceso
    texto_sombra(_px, _py + 82, nombres_proc[p] + " (P" + string(p) + ")", c_white, 1.2);

    var _nec = "";
    for (var r = 0; r < num_rec; r++) {
        if (maximo[p][r] > 0) {
            if (_nec != "") _nec += ", ";
            _nec += nombres_rec[r];
        }
    }
    texto_sombra(_px, _py + 102, "Necesita: " + _nec, c_ltgray, 1);

    var _estado_p = "ESPERANDO";
    var _col_estado = c_orange;
    if (terminado[p]) {
        _estado_p = "TERMINADO (salio)";
        _col_estado = c_lime;
    } else {
        var _completo = true;
        for (var r = 0; r < num_rec; r++) {
            if (asignado[p][r] < maximo[p][r]) _completo = false;
        }
        if (_completo) {
            _estado_p = "LISTO para ejecutar";
            _col_estado = c_aqua;
        }
    }
    texto_sombra(_px, _py + 120, "Estado: " + _estado_p, _col_estado, 1);
}

// --------------------------- RECURSOS --------------------------------
for (var r = 0; r < num_rec; r++) {
    var _pos = pos_recurso(r);
    if (seleccionado == r) {
        draw_set_alpha(0.5);
        draw_set_colour(c_lime);
        draw_circle(_pos[0], _pos[1], 38, false);
        draw_set_alpha(1);
    }
    var _sr = _spr_rec[r];
    draw_sprite(_sr, 0, _pos[0] - sprite_get_width(_sr) / 2, _pos[1] - sprite_get_height(_sr) / 2);
}

// --------------------------- MENSAJES --------------------------------
draw_set_alpha(0.85);
draw_set_colour(_panel);
draw_rectangle(40, 478, _w - 40, 580, false);
draw_set_alpha(1);
draw_set_colour(_oro);
draw_rectangle(40, 478, _w - 40, 580, true);
draw_rectangle(43, 481, _w - 43, 577, true);

draw_set_valign(fa_top);
if (estado_juego == "derrota") {
    draw_set_colour(c_red);
} else if (estado_juego == "superado") {
    draw_set_colour(c_lime);
} else {
    draw_set_colour(c_white);
}
draw_text_ext(_w / 2, 488, mensaje, 18, _w - 120);

// --------------------------- BOTON -----------------------------------
var _texto_boton = "EJECUTAR";
if (estado_juego == "superado") _texto_boton = "SIGUIENTE";
if (estado_juego == "derrota") _texto_boton = "REINTENTAR";

var _encima = point_in_rectangle(mouse_x, mouse_y, boton_x1, boton_y1, boton_x2, boton_y2);
if (_encima) {
    draw_set_colour(make_colour_rgb(150, 50, 40));
} else {
    draw_set_colour(make_colour_rgb(110, 35, 30));
}
draw_rectangle(boton_x1, boton_y1, boton_x2, boton_y2, false);
draw_set_colour(_oro);
draw_rectangle(boton_x1, boton_y1, boton_x2, boton_y2, true);
draw_rectangle(boton_x1 + 3, boton_y1 + 3, boton_x2 - 3, boton_y2 - 3, true);
draw_set_valign(fa_middle);
texto_sombra((boton_x1 + boton_x2) / 2, (boton_y1 + boton_y2) / 2, _texto_boton, _oro, 1.3);

// --------------------------- PIE DE PAGINA ---------------------------
draw_set_valign(fa_top);
draw_set_halign(fa_right);
texto_sombra(_w - 20, 638, "R = reiniciar nivel   M = musica", c_ltgray, 1);
if (ruta_export != "") {
    draw_set_halign(fa_left);
    texto_sombra(20, 638, "Escenario exportado: " + ruta_export, c_ltgray, 1);
}

// Restablecer alineacion
draw_set_halign(fa_left);
draw_set_valign(fa_top);
