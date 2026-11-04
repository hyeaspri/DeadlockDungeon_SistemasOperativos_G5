# DeadlockDungeon_SistemasOperativos_G5
# Deadlock Dungeon: La mazmorra de los recursos

**Proyecto:** Sistemas Operativos  
**Grupo:** 5
**Integrantes:**
- Heidy Valeria Asprilla Rubiano
- Daniela Rodriguez Reyes

---

## 1. Levantamiento de información: necesidad y problemática

En los sistemas operativos, varios procesos pueden necesitar utilizar los mismos recursos para realizar sus actividades. Sin embargo, cuando estos recursos se asignan de manera inadecuada, pueden presentarse situaciones conocidas como interbloqueos o *Deadlocks*.

Este concepto puede resultar difícil de comprender al principio, especialmente cuando se estudia únicamente desde la teoría. Por esta razón, surge la necesidad de desarrollar una herramienta interactiva que permita representar estas situaciones de una manera más visual y práctica.

El proyecto busca solucionar esta dificultad mediante un juego en el que los participantes puedan experimentar cómo se asignan los recursos, cómo se generan los interbloqueos y qué alternativas existen para evitarlos.

## 2. Descripción del proyecto

**Deadlock Dungeon** es un juego web educativo en el que dos personajes, un caballero y un mago, deben superar diferentes niveles dentro de una mazmorra utilizando recursos compartidos, como llaves y escudos.

Durante el juego, el usuario deberá asignar y liberar recursos para permitir que los personajes completen sus objetivos y puedan avanzar.

El juego contará con tres niveles:

1. **La primera misión:** introduce la asignación de recursos entre los personajes.
2. **El intercambio imposible:** presenta una situación en la que los personajes quedan esperando recursos que están en posesión del otro, generando un interbloqueo.
3. **La salida segura:** permite encontrar una secuencia adecuada para asignar y liberar los recursos, evitando que los personajes queden bloqueados.

El proyecto utilizará scripts de Bash y PowerShell para analizar los escenarios de asignación de recursos. De esta manera, el juego permitirá aplicar conceptos de Sistemas Operativos mediante situaciones simuladas e interactivas.

## 3. Estructura del prototipo

El proyecto estará organizado en diferentes carpetas, cada una encargada de una parte específica del funcionamiento del juego.

### Estructura de carpetas

```text
Deadlock-Dungeon/
│
├── frontend/
│   ├── index.html
│   ├── css/
│   │   └── estilos.css
│   └── js/
│       ├── juego.js
│       └── deadlock.js
│
├── scripts/
│   ├── analizar.sh
│   └── analizar.ps1
│
├── backend/
│   └── servidor.js
│
├── database/
│   └── deadlock.db
│
├── documentacion/
│   └── descripcion.md
│
└── README.md
```

### 3.1. Frontend

Esta parte contiene los elementos visuales y las funciones con las que interactuará el jugador.

- **index.html:** contiene la estructura principal del juego.
- **estilos.css:** define los colores, diseños, personajes y apariencia de los escenarios.
- **juego.js:** controla las interacciones del usuario, los personajes y el avance entre niveles.
- **deadlock.js:** contiene la lógica del juego relacionada con la asignación de recursos y la identificación de interbloqueos.

### 3.2. Comandos

Los comandos serán una parte fundamental del proyecto, ya que permitirán analizar los escenarios de asignación de recursos utilizando diferentes entornos.

Se implementarán los siguientes scripts:

- **analizar.sh (Bash):** realizará el análisis de los recursos y procesos en un entorno Linux.
- **analizar.ps1 (PowerShell):** realizará el mismo análisis en un entorno Windows.

Ambos scripts permitirán evaluar si los procesos pueden continuar ejecutándose o si existe una situación de interbloqueo. También se utilizarán para identificar posibles secuencias seguras de ejecución.

El backend será el encargado de comunicarse con estos scripts y enviar sus resultados al juego para que el usuario pueda visualizar el análisis realizado.

### 3.3. Base de datos

Se utilizará SQLite para almacenar la información necesaria del juego, como los niveles, procesos, recursos, asignaciones y resultados.

La base de datos contará inicialmente con las siguientes tablas:

| Tabla | Descripción |
|---|---|
| Niveles | Almacena los niveles disponibles y su dificultad. |
| Procesos | Registra los personajes y sus estados durante el juego. |
| Recursos | Guarda los recursos disponibles, como llaves y escudos. |
| Asignaciones | Registra los recursos que tiene asignados cada proceso. |
| Resultados | Almacena los resultados obtenidos por el jugador en cada nivel. |

### 3.4. Modelo relacional

El modelo relacional permitirá organizar la información y establecer las relaciones entre las diferentes tablas de la base de datos.

Las relaciones principales serán:

- **Niveles - Procesos:** un nivel puede contener varios procesos.
- **Niveles - Recursos:** un nivel puede disponer de diferentes recursos.
- **Procesos - Asignaciones:** un proceso puede tener varias asignaciones.
- **Recursos - Asignaciones:** un recurso puede aparecer en diferentes asignaciones.
- **Niveles - Resultados:** cada nivel puede registrar diferentes resultados de los jugadores.

La tabla **Asignaciones** permitirá relacionar los procesos con los recursos, facilitando el seguimiento de los recursos que utiliza cada personaje durante el juego.

## 4. Tecnologías

Para el desarrollo del prototipo se utilizarán las siguientes tecnologías y herramientas:

| Tecnología | Uso dentro del proyecto |
|---|---|
| HTML5 | Crear la estructura de las pantallas del juego. |
| CSS3 | Diseñar la apariencia visual y los escenarios. |
| JavaScript | Controlar las interacciones y la lógica del juego. |
| Node.js | Desarrollar el backend y conectar los componentes. |
| Bash | Ejecutar el análisis de recursos en Linux. |
| PowerShell | Ejecutar el análisis de recursos en Windows. |
| CMD | Utilizar comandos básicos de Windows para la ejecución y gestión del proyecto. |
| SQLite | Almacenar la información del juego. |
| Visual Studio Code | Escribir y organizar el código fuente. |
| Git y GitHub | Gestionar las versiones y compartir el proyecto. |

---

**Deadlock Dungeon** busca convertir el aprendizaje de los interbloqueos en una experiencia práctica, en la que los usuarios puedan comprender cómo se comportan los procesos cuando comparten recursos y cómo pueden evitar situaciones de bloqueo.
