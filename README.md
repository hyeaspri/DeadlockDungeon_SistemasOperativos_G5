# Deadlock Dungeon: La mazmorra de los recursos

**Proyecto:** Sistemas Operativos  
**Grupo:** 5  
**Estado:** Planeación y estructuración inicial.

### Integrantes

- Heidy Valeria Asprilla Rubiano.
- Daniela Rodriguez Reyes.

---

## 1. Descripción general

Deadlock Dungeon es un juego web educativo que busca enseñar de una manera práctica cómo funcionan los interbloqueos (*Deadlocks*) en los sistemas operativos.

El juego tendrá dos personajes principales: un caballero y un mago, quienes deberán superar diferentes niveles dentro de una mazmorra utilizando recursos compartidos, como llaves y escudos.

Durante las partidas, el jugador tendrá que asignar y liberar recursos para que los personajes puedan cumplir sus objetivos. A través de estas situaciones se representarán los bloqueos que pueden ocurrir cuando varios procesos necesitan recursos que están siendo utilizados por otros.

El proyecto combinará una interfaz web interactiva con scripts desarrollados en Bash y PowerShell, encargados de analizar los escenarios de asignación de recursos.

## 2. Problemática

En los sistemas operativos, diferentes procesos pueden necesitar los mismos recursos para realizar sus actividades. Cuando estos recursos se asignan de manera inadecuada, pueden producirse interbloqueos, situaciones en las que los procesos quedan esperando recursos que no pueden obtener y ninguno logra continuar.

Este concepto puede resultar difícil de comprender cuando se estudia únicamente desde la teoría. Por eso, se propone desarrollar una herramienta interactiva que permita representar estas situaciones mediante personajes, recursos y escenarios de juego.

## 3. Justificación

La creación de Deadlock Dungeon busca facilitar la comprensión de los interbloqueos mediante una experiencia en la que el usuario pueda interactuar directamente con diferentes situaciones de asignación de recursos.

En lugar de limitarse a observar ejemplos, el jugador podrá experimentar qué sucede cuando dos personajes necesitan recursos que están en posesión del otro, identificar cuándo se produce un bloqueo y encontrar alternativas para solucionarlo.

Además, el uso de Bash y PowerShell permitirá aplicar conceptos de Sistemas Operativos mediante el análisis de escenarios simulados, relacionando la parte práctica del juego con los conocimientos vistos en clase.

## 4. Objetivos

### 4.1. Objetivo general

Desarrollar un juego web educativo que permita comprender y analizar los interbloqueos en los sistemas operativos mediante la simulación de procesos, asignación de recursos y ejecución de scripts en Bash y PowerShell.

### 4.2. Objetivos específicos

- Diseñar una interfaz web interactiva que permita representar los personajes, recursos y escenarios del juego.
- Implementar diferentes niveles que representen situaciones de asignación de recursos e interbloqueos.
- Desarrollar scripts en Bash y PowerShell para analizar los escenarios y determinar si existe un bloqueo o una secuencia segura de ejecución.
- Integrar los scripts con el juego mediante un backend desarrollado en Node.js.
- Almacenar la información de los niveles, recursos, asignaciones y resultados mediante una base de datos SQLite.

## 5. Alcance inicial del producto

El prototipo estará enfocado en la simulación de interbloqueos mediante un juego web. Inicialmente contará con dos personajes, recursos compartidos y tres niveles con diferentes situaciones.

Los niveles propuestos son:

1. **La primera misión:** el jugador aprenderá cómo se asignan los recursos entre los personajes.
2. **El intercambio imposible:** se presentará una situación en la que los personajes quedan esperando los recursos que tiene el otro, generando un interbloqueo.
3. **La salida segura:** el jugador deberá encontrar una forma adecuada de organizar la asignación de recursos para permitir que ambos personajes puedan terminar.

El proyecto se limitará a escenarios controlados dentro del juego. No administrará procesos ni recursos reales del sistema operativo.

## 6. Usuarios o beneficiarios

El proyecto está dirigido principalmente a estudiantes que estén aprendiendo conceptos de Sistemas Operativos, especialmente el funcionamiento de los procesos, los recursos compartidos y los interbloqueos.

También podrá ser utilizado como herramienta de apoyo para docentes que deseen explicar estos conceptos mediante ejemplos visuales e interactivos.

## 7. Funcionalidades principales

El juego contará inicialmente con las siguientes funcionalidades:

- **Selección y desarrollo de niveles:** permitirá avanzar por diferentes escenarios de la mazmorra.
- **Interacción con personajes:** el jugador podrá observar las necesidades de recursos del caballero y el mago.
- **Asignación de recursos:** permitirá entregar recursos a los personajes según las condiciones de cada nivel.
- **Liberación de recursos:** permitirá liberar recursos para que puedan ser utilizados por otros procesos.
- **Identificación de Deadlock:** analizará situaciones en las que los personajes quedan bloqueados esperando recursos.
- **Análisis de secuencias seguras:** permitirá identificar si existe un orden de ejecución que permita finalizar los procesos.
- **Visualización de resultados:** mostrará al jugador el resultado de sus decisiones y el comportamiento de los recursos.

## 8. Arquitectura y estructura general

El proyecto estará organizado en diferentes componentes que trabajarán de manera conjunta.

### 8.1. Arquitectura inicial

La solución tendrá los siguientes componentes:

- **Frontend:** será la parte visual con la que interactuará el jugador. Se desarrollará con HTML, CSS y JavaScript.
- **Backend:** estará desarrollado en Node.js y se encargará de comunicar el frontend con los scripts y la base de datos.
- **Scripts:** Bash y PowerShell realizarán el análisis de los escenarios de asignación de recursos.
- **Base de datos:** SQLite almacenará la información necesaria para el funcionamiento del juego.

El funcionamiento general será el siguiente:

```text
              JUGADOR
                 |
                 v
              FRONTEND
          HTML - CSS - JS
                 |
                 v
              BACKEND
               Node.js
                 |
          +------+------+
          |             |
          v             v
        BASH         POWERSHELL
       Linux          Windows
          |             |
          +------+------+
                 |
                 v
         ANÁLISIS DE RECURSOS
                 |
                 v
          RESULTADO DEL JUEGO

              BACKEND
                 |
                 v
           BASE DE DATOS
              SQLite
```

### 8.2. Estructura de carpetas y archivos

La organización inicial del repositorio será la siguiente:

```text
Deadlock-Dungeon/
│
├── README.md
│
├── documentacion/
│   ├── descripcion_proyecto.pdf
│   ├── requerimientos.pdf
│   ├── arquitectura_inicial.pdf
│   ├── tecnologias_herramientas.pdf
│   │
│   └── diagramas/
│       ├── estructura_producto.png
│       └── arquitectura_sistema.png
│
├── frontend/
│   ├── index.html
│   ├── css/
│   │   └── estilos.css
│   └── js/
│       ├── juego.js
│       └── deadlock.js
│
├── backend/
│   └── servidor.js
│
├── scripts/
│   ├── analizar.sh
│   └── analizar.ps1
│
├── database/
│   └── deadlock.db
│
├── recursos/
│   └── imagenes/
│
├── pruebas/
│
└── LICENSE
```

### 8.3. Descripción de los componentes

| Componente | Función |
|---|---|
| frontend | Contiene la interfaz y las interacciones del juego. |
| backend | Conecta los componentes y procesa las solicitudes. |
| scripts | Contiene los análisis realizados con Bash y PowerShell. |
| database | Almacena la información del juego. |
| documentacion | Guarda los documentos y diagramas técnicos. |
| recursos | Contiene imágenes y elementos gráficos. |
| pruebas | Se utilizará para organizar las pruebas del prototipo. |

## 9. Base de datos y modelo relacional

Se propone utilizar SQLite para almacenar la información del juego.

Inicialmente se contemplan las siguientes tablas:

| Tabla | Descripción |
|---|---|
| Niveles | Almacena los niveles disponibles y su dificultad. |
| Procesos | Registra los personajes y sus estados. |
| Recursos | Guarda los recursos disponibles, como llaves y escudos. |
| Asignaciones | Registra los recursos que tiene asignados cada proceso. |
| Resultados | Almacena los resultados obtenidos en cada nivel. |

### Relaciones principales

- Un nivel puede tener varios procesos.
- Un nivel puede contener diferentes recursos.
- Un proceso puede tener varias asignaciones.
- Un recurso puede estar relacionado con diferentes asignaciones a lo largo del juego.
- Un nivel puede registrar diferentes resultados.

La tabla Asignaciones permitirá relacionar los procesos con los recursos, facilitando el seguimiento de los elementos que utiliza cada personaje.

## 10. Relación con los conceptos de Sistemas Operativos

Deadlock Dungeon estará relacionado directamente con los siguientes conceptos:

- **Procesos:** estarán representados por los personajes del juego, el caballero y el mago.
- **Recursos compartidos:** estarán representados por elementos como las llaves y los escudos.
- **Asignación de recursos:** se representará cuando un personaje obtenga un recurso para cumplir su objetivo.
- **Interbloqueo (Deadlock):** ocurrirá cuando los personajes queden esperando recursos que están siendo utilizados por el otro.
- **Espera circular:** se presentará cuando cada personaje espere un recurso que tiene el otro.
- **Estado seguro:** se analizará cuando exista una secuencia de ejecución que permita que todos los procesos terminen.
- **Prevención y solución de bloqueos:** se trabajará mediante la organización y liberación adecuada de los recursos.

Los scripts permitirán analizar estos escenarios simulados y relacionar la experiencia del juego con los conceptos estudiados en Sistemas Operativos.

## 11. Tecnologías y herramientas

Para el desarrollo del proyecto se contemplan las siguientes tecnologías:

| Tecnología o herramienta | Uso dentro del proyecto |
|---|---|
| HTML5 | Crear la estructura de las pantallas del juego. |
| CSS3 | Diseñar la apariencia visual y los escenarios. |
| JavaScript | Controlar las interacciones y la lógica del juego. |
| Node.js | Desarrollar el backend y conectar los componentes. |
| Bash | Ejecutar los análisis mediante scripts en Linux. |
| PowerShell | Ejecutar los análisis mediante scripts en Windows. |
| CMD | Utilizar comandos básicos para la gestión del proyecto en Windows. |
| SQLite | Almacenar la información del juego. |
| Visual Studio Code | Editar y organizar el código fuente. |
| Git | Controlar las versiones del proyecto. |
| GitHub | Alojar el repositorio y registrar los avances. |

## 12. Requisitos iniciales de ejecución

### Hardware

- Computador de escritorio o portátil.
- Procesador de doble núcleo o superior.
- Memoria RAM de 4 GB como mínimo.
- Espacio disponible para almacenar el proyecto y sus herramientas.

### Software

- Sistema operativo Windows o Linux.
- Navegador web actualizado.
- Visual Studio Code.
- Node.js y npm.
- Git.
- PowerShell para la ejecución de scripts en Windows.
- Bash para la ejecución de scripts en Linux.
- SQLite para la gestión de la base de datos.

### Entorno de ejecución

El juego se ejecutará desde un navegador web y utilizará Node.js para iniciar el servidor local. Los scripts se ejecutarán según el entorno disponible, utilizando PowerShell en Windows o Bash en Linux.

## 13. Estado actual del proyecto

Actualmente, Deadlock Dungeon se encuentra en la fase de planeación y estructuración inicial. Se ha definido la idea principal, los personajes, los recursos, los niveles y las tecnologías que se utilizarán para desarrollar el prototipo.

### Próximos avances

- Crear la interfaz principal del juego.
- Diseñar los escenarios y personajes.
- Implementar la lógica de asignación y liberación de recursos.
- Desarrollar los scripts de análisis en Bash y PowerShell.
- Conectar los scripts con el backend mediante Node.js.
- Implementar la base de datos SQLite.
- Realizar pruebas de funcionamiento y verificar la detección de interbloqueos.

---

**Deadlock Dungeon: La mazmorra de los recursos**

*Un juego para comprender los interbloqueos a través de la interacción y la simulación.*
