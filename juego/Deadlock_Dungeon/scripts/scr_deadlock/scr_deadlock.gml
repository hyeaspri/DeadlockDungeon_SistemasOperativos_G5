/// scr_deadlock
/// -------------------------------------------------------------------
/// DEADLOCK DUNGEON - Componente de Sistemas Operativos
/// Funciones para:
///   - Calcular los recursos disponibles (vector Disponible).
///   - Detectar interbloqueos y estados seguros usando el
///     algoritmo de seguridad del banquero (version reducida).
///   - Saber que proceso tiene cada recurso.
///   - Construir la explicacion de la espera circular.
///
/// Matrices que se usan (igual que en la teoria de SO):
///   asignado[p][r] : unidades del recurso r que tiene el proceso p
///   maximo[p][r]   : unidades del recurso r que p necesita en total
///   necesidad      : maximo - asignado
///   total[r]       : unidades que existen del recurso r
/// -------------------------------------------------------------------


/// @function so_disponibles(asignado, total, np, nr)
/// @description Devuelve un arreglo con las unidades libres de cada recurso.
function so_disponibles(_asignado, _total, _np, _nr) {
    var _disp = array_create(_nr, 0);
    for (var r = 0; r < _nr; r++) {
        var _usado = 0;
        for (var p = 0; p < _np; p++) {
            _usado += _asignado[p][r];
        }
        _disp[r] = _total[r] - _usado;
    }
    return _disp;
}


/// @function so_analizar(asignado, maximo, total, terminado, np, nr)
/// @description Algoritmo de seguridad / deteccion de interbloqueo.
///   1. Trabajo = Disponible
///   2. Buscar un proceso no terminado cuya Necesidad <= Trabajo
///   3. Si existe: puede terminar, libera sus recursos (Trabajo += Asignado)
///      y se agrega a la secuencia segura. Repetir.
///   4. Si al final quedan procesos sin terminar, esos procesos estan
///      en interbloqueo (estado NO seguro).
/// @returns struct { seguro, secuencia, bloqueados }
function so_analizar(_asignado, _maximo, _total, _terminado, _np, _nr) {
    var _trabajo = so_disponibles(_asignado, _total, _np, _nr);
    var _fin = array_create(_np, false);
    for (var p = 0; p < _np; p++) {
        _fin[p] = _terminado[p];
    }

    var _secuencia = [];
    var _avance = true;

    while (_avance) {
        _avance = false;
        for (var p = 0; p < _np; p++) {
            if (!_fin[p]) {
                var _puede = true;
                for (var r = 0; r < _nr; r++) {
                    var _necesita = _maximo[p][r] - _asignado[p][r];
                    if (_necesita > _trabajo[r]) {
                        _puede = false;
                    }
                }
                if (_puede) {
                    for (var r = 0; r < _nr; r++) {
                        _trabajo[r] += _asignado[p][r];
                    }
                    _fin[p] = true;
                    array_push(_secuencia, p);
                    _avance = true;
                }
            }
        }
    }

    var _bloqueados = [];
    for (var p = 0; p < _np; p++) {
        if (!_fin[p]) {
            array_push(_bloqueados, p);
        }
    }

    return {
        seguro: (array_length(_bloqueados) == 0),
        secuencia: _secuencia,
        bloqueados: _bloqueados
    };
}


/// @function so_quien_tiene(asignado, r, np)
/// @description Devuelve el indice del proceso que tiene el recurso r, o -1 si esta libre.
function so_quien_tiene(_asignado, _r, _np) {
    for (var p = 0; p < _np; p++) {
        if (_asignado[p][_r] > 0) {
            return p;
        }
    }
    return -1;
}


/// @function so_texto_secuencia(secuencia, nombres)
/// @description Convierte la secuencia [0, 1] en el texto "Caballero -> Mago".
function so_texto_secuencia(_secuencia, _nombres) {
    var _txt = "";
    for (var i = 0; i < array_length(_secuencia); i++) {
        if (i > 0) {
            _txt += " -> ";
        }
        _txt += _nombres[_secuencia[i]];
    }
    return _txt;
}


/// @function so_explicar_espera(asignado, maximo, bloqueados, nombres_proc, nombres_rec, np, nr)
/// @description Construye el texto que explica la espera circular de los procesos bloqueados.
function so_explicar_espera(_asignado, _maximo, _bloqueados, _nombres_proc, _nombres_rec, _np, _nr) {
    var _txt = "";
    for (var i = 0; i < array_length(_bloqueados); i++) {
        var p = _bloqueados[i];
        var _tiene = "";
        var _espera = "";
        for (var r = 0; r < _nr; r++) {
            if (_asignado[p][r] > 0) {
                if (_tiene != "") _tiene += ", ";
                _tiene += _nombres_rec[r];
            }
            if (_maximo[p][r] - _asignado[p][r] > 0) {
                var q = so_quien_tiene(_asignado, r, _np);
                if (_espera != "") _espera += ", ";
                if (q >= 0) {
                    _espera += _nombres_rec[r] + " (lo tiene " + _nombres_proc[q] + ")";
                } else {
                    _espera += _nombres_rec[r];
                }
            }
        }
        if (_tiene == "") _tiene = "nada";
        _txt += _nombres_proc[p] + " tiene " + _tiene + " y espera " + _espera + ".\n";
    }
    return _txt;
}
