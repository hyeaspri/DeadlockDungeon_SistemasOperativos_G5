// Prueba de la logica del juego fuera de GameMaker (Node.js).
// Ejecuta el codigo GML de scr_deadlock y obj_control_Create con funciones simuladas
// y juega los 3 niveles. Uso (desde la raiz del repo): node pruebas/simulacion_logica.js
const fs=require('fs'),vm=require('vm');
const D=__dirname+'/../juego/codigo_gml/';
const files={}; const sonidos=[];
const ctx={room_width:1366,room_height:768,game_save_id:'C:/Users/x/AppData/Local/Deadlock_Dungeon/',
 array_create:(n,v)=>Array(n).fill(v),array_push:(a,v)=>a.push(v),array_length:a=>a.length,
 string:v=>String(v),string_lower:s=>s.toLowerCase(),max:Math.max,show_debug_message:m=>console.log('   [debug]',m),
 file_text_open_write:n=>{files[n]='';return n},file_text_write_string:(f,s)=>{files[f]+=s},
 file_text_writeln:f=>{files[f]+='\n'},
 audio_play_sound:(snd)=>{sonidos.push(snd);return 1},audio_sound_gain:()=>{},
 snd_musica:'musica',snd_clic:'clic',snd_asignar:'asignar',snd_error:'error',snd_bloqueo:'bloqueo',snd_victoria:'victoria',file_text_close:()=>{},console};
vm.createContext(ctx);
vm.runInContext(fs.readFileSync(D+'scr_deadlock.gml','utf8'),ctx);
vm.runInContext(fs.readFileSync(D+'obj_control_Create.gml','utf8'),ctx);
const run=c=>vm.runInContext(c,ctx);
const show=t=>{console.log('\n## '+t);console.log(' estado:',ctx.estado_juego,'| puntos:',ctx.puntos);console.log(' mensaje:',ctx.mensaje);
 const a=ctx.so_analizar(ctx.asignado,ctx.maximo,ctx.total,ctx.terminado,2,2);console.log(' analisis:',JSON.stringify(a));};
run('cargar_nivel(1)');show('N1 inicio');
run('asignar(0,1)');show('N1 escudo->caballero (debe rechazar)');
run('asignar(0,0)');run('asignar(1,1)');show('N1 asignado');
run('ejecutar()');show('N1 ejecutar');
run('cargar_nivel(2)');show('N2 inicio');
run('ejecutar()');show('N2 ejecutar');
run('asignado[1][1]=0;expropiaciones+=1');run('asignar(0,1)');run('ejecutar()');show('N2 tras expropiar escudo y darlo al caballero');
run('asignar(1,0)');run('asignar(1,1)');run('ejecutar()');show('N2 mago');
run('cargar_nivel(3)');run('asignar(0,0)');show('N3 llave->cab');run('asignar(1,1)');show('N3 escudo->mago');run('ejecutar()');show('N3 ejecutar (derrota)');
run('cargar_nivel(3)');run('asignar(0,0)');run('asignar(0,1)');run('ejecutar()');show('N3 cab primero');run('asignar(1,0)');run('asignar(1,1)');run('ejecutar()');show('N3 fin');

console.log('\n## PREGUNTAS ENTRE NIVELES');
run('puntos=0;aciertos=0;cargar_nivel(1);asignar(0,0);asignar(1,1);ejecutar();estado_juego="pregunta";respuesta=-1;');
run('responder(0)'); console.log(' N1 responde opcion 0 (correcta):', 'puntos='+ctx.puntos, 'aciertos='+ctx.aciertos);
run('responder(1)'); console.log(' N1 segundo clic se ignora:', 'puntos='+ctx.puntos);
run('continuar()'); console.log(' continuar -> nivel', ctx.nivel, ctx.estado_juego);
run('cargar_nivel(2);asignado=[[0,0],[0,0]];asignar(0,0);asignar(0,1);ejecutar();asignar(1,0);asignar(1,1);ejecutar();estado_juego="pregunta";');
const p2=ctx.puntos; run('responder(0)'); console.log(' N2 responde opcion 0 (incorrecta):', 'puntos sin cambio='+(ctx.puntos===p2), 'aciertos='+ctx.aciertos);
run('continuar()'); console.log(' continuar -> nivel', ctx.nivel);
run('asignar(0,0);asignar(0,1);ejecutar();asignar(1,0);asignar(1,1);ejecutar();estado_juego="pregunta";responder(2);continuar();');
console.log(' N3 correcta y continuar ->', ctx.estado_juego, '| puntos', ctx.puntos, '| aciertos', ctx.aciertos+'/3');
console.log(' Sonidos reproducidos:', [...new Set(sonidos)].join(', '));
console.log('\n## ARCHIVOS EXPORTADOS');for(const k in files){console.log('--- '+k);console.log(files[k]);}
