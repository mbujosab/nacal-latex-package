# nacal.sty — contexto y encargo de auditoría para Claude

Fichero escrito el 10 de octubre de 2026, al final de una conversación con
Marcos sobre otro proyecto (probabilidad en el caso finito, carpeta
`~/SynologyDrive/ReposGH/AndresyMarcos/probabilidadCasoFinito`). Marcos pidió
una auditoría del paquete y que el tema se tratara en una conversación
aparte, en esta carpeta. Léelo entero antes de tocar nada.

## Encargos de otras sesiones (desde el 16/11/2026)

Los encargos de otras sesiones (el libro, el material de clase, etc.) llegan
a la raíz en ficheros `encargo-*.md` y `respuesta-*.md`. Un fichero de esos
nuevo o con cambios sin confirmar en git es un encargo sin tratar.

- Un hook (`.claude/settings.json`) lo comprueba cada vez que Marcos escribe
  y avisa con una línea «ENCARGOS SIN TRATAR». Si el aviso no aparece al
  empezar la sesión, haz la comprobación a mano:
  `git status --short -- 'encargo-*.md' 'respuesta-*.md'`.
- Si hay alguno, léelo, di en pantalla cuál es y de qué repositorio viene,
  resume lo que pide en pocas líneas y pregunta a Marcos qué hacer. No
  cambies nada hasta que responda. Si Marcos ha pedido otra cosa en ese
  mensaje, atiéndela y da el aviso al final.
- Cuando el encargo esté tratado, anota la respuesta al final del fichero y
  confírmalo en git. Mientras no se confirme, el aviso seguirá saliendo.
- Para pedir o responder algo a otro repositorio, escribe allí un fichero
  con uno de esos nombres y no lo confirmes en git: lo confirma quien lo
  recibe. Al libro: `encargo-desde-nacaltex.md` o
  `respuesta-desde-nacaltex.md` en
  `~/SynologyDrive/ReposGH/Docencia/CursoDeAlgebraLineal-SRC/`.
- Las reglas de coordinación entre el libro, el módulo de Python, el
  material de clase, los vídeos y los Notebooks están en
  `coordinacion-entre-repositorios.md` de ese repositorio: el libro manda en
  qué notación se usa y este paquete en cómo se compone. Las cautelas de
  este fichero (banco de pruebas, versiones etiquetadas) siguen mandando aquí.

## Qué es nacal

Paquete de LaTeX escrito por Marcos Bujosa (UCM) con la notación de su libro
de Álgebra Lineal ("Notación Asociativa para un Curso de Álgebra Lineal").
Es el primer y único paquete de LaTeX que ha escrito, y lo hizo, según él,
"con poco conocimiento de los estándares". Hay un paquete hermano,
`nacal-moodle.sty` (otro repositorio), que depende de este.

Dependen de él, según un inventario del 10/10/2026 (ficheros .tex/.org que
cargan nacal, carpetas con más ficheros primero):

- `~/SynologyDrive/ReposGH/Docencia/VideosMates2` (unos 600 ficheros) y
  `videoMath2` (unos 160): los vídeos del curso.
- `qbank-PEconometria` y `qbank-econometria`: bancos de preguntas (salidas
  moodle y AMC).
- `~/SynologyDrive/POM/proyectos/PEctr-Test-*`: exámenes AMC, carpetas por
  fecha (hay varias de septiembre y octubre de 2026, es decir, en uso ahora).
- `CursoAL-SRC`, `CursoDeAlgebraLineal-SRC`, `MatematicasII-SRC`: el libro y
  el material del curso Matemáticas II.
- El proyecto de probabilidad con Andrés (nota3.org, diccionario.org).
- Hay copias sueltas del .sty en `~/texmf/tex/latex/nacal-moodle-latex-package/Ejemplo/`
  y en `~/SynologyDrive/ReposGH/Investigacion/libroProbabilidad/notacion/`.
  Riesgo de divergencia.

`~/CloudStation` es un enlace simbólico a `~/SynologyDrive` (comprobado el 4/11/2026): no hay copias duplicadas.

## Estado del repositorio (10/10/2026)

- Es un repositorio git con 26 commits (2023-01-05 a 2024-08-29). Licencia
  LPPL 1.3. README en org.
- **Fuente de verdad: `NAcAL-Tex.org`** (programación literaria). De él se
  "tanglean" `nacal.ins`, `nacal.dtx`, `makefile` y `.gitignore`. El
  `makefile` corre docstrip (`latex nacal.ins`) para producir `nacal.sty` y
  compila la documentación `nacal.pdf`. **Nunca editar `nacal.sty` ni
  `nacal.dtx` a mano**: cualquier cambio se pierde en el siguiente tangle.
- Árbol de trabajo sucio: `NAcAL-Tex.org`, `nacal.dtx`, `nacal.sty` y
  `nacal.pdf` modificados sin commit (el .org tiene fecha de mayo de 2026,
  los demás de agosto de 2024). `nacal.hd` sin seguimiento. Lo primero es
  averiguar qué cambió y hacer commit o descartar, antes de cualquier
  auditoría; si no, no hay línea base.
- La copia instalada `~/texmf/tex/latex/nacal/nacal.sty` es idéntica a la
  del repositorio (comprobado con diff). Esa es la que usan todos los
  documentos.
- Cifras del .sty: 1931 líneas, 662 `NewDocumentCommand` (xparse), 8
  `newcommand`, 2 `def`, 18 `DeclareMathOperator`, 649 `xspace`, 8
  `MakeLowercase`, 12 usos de macros internos con `@`. No redefine
  comandos estándar de LaTeX (eso lo hacen los documentos, no el paquete).
- Documentación: `nacal.pdf` (1,1 MB) generada del dtx, con secciones por
  tema (conjuntos de números, paréntesis, subíndices, operadores, selector,
  transformaciones elementales, vectores y matrices, productos, sistemas,
  espacios vectoriales, notación funcional, probabilidad, econometría,
  sucesiones).

Conclusión previa: el paquete está mucho mejor hecho de lo que Marcos cree.
Tiene pipeline dtx/docstrip, documentación, git, licencia y usa xparse de
forma consistente. La auditoría no debe empezar por "rehacerlo" sino por
asegurar la línea base y corregir lo concreto.

## Problemas concretos ya detectados

1. `\ProvidesPackage{nacal}[2023/01/05 v1.0 [2023/09/22 v1.3 ...]`: el
   argumento está mal formado (corchete anidado, dos fechas). LaTeX lo
   traga pero `\@ifpackagelater` y las herramientas de versión no funcionan.
   Está así en el dtx (línea 20-22 del dtx), por tanto en el org.
2. `\DeclareSymbolFont{mathx}` aparece dos veces (líneas 1566 y 1569 del
   .sty). Revisar si es un residuo.
3. El paquete declara fuentes de `mathabx` (`matha`, `mathx`) con
   `\DeclareFontFamily`/`\DeclareFontShape` en lugar de cargar el paquete.
   Es frágil y puede chocar con documentos que carguen `mathabx` o
   `mathalpha` (el proyecto de probabilidad carga `mathalpha`).
4. `\DeclareMathAlphabet{\mymathbb}{U}{BOONDOX-ds}` para `\Uno`/`\Cero`:
   nombre genérico `\mymathbb` sin prefijo de espacio de nombres.
5. `\xspace` dentro de `\ensuremath{...}` en casi todos los macros. En
   modo matemático `\xspace` no hace nada útil y en algunos contextos
   (argumentos de otros macros, `\label`, cabeceras) da problemas. Hay
   que decidir una política y aplicarla uniformemente, pero cambiarla
   puede alterar el espaciado en cientos de documentos: solo con el banco
   de pruebas delante.
6. `\vect` usa `\MakeLowercase` sobre su argumento: frágil en argumentos
   móviles (secciones, índices) y sorprendente para el usuario.
7. Semántica inconsistente de los argumentos opcionales en la parte de
   probabilidad: en `\sspi[S]` el opcional es una etiqueta; en
   `\ESP[\sspi]{u}`, `\PRO[\sspi]{u}`, `\norma[\sspi]{u}` es el símbolo
   completo. Detalle en `diccionario.org` del proyecto de probabilidad.
8. Duplicados: `\PSpan` y `\PSpanNew` (dos implementaciones de la
   envolvente probabilizable); el proyecto de probabilidad redefine además
   `\sspi`, `\SPI` y `\PSpan` en su preámbulo porque la versión del
   paquete no le sirve. Señal de que esa sección del paquete está a medio
   diseñar.
9. `\Ind` y `\ind{}` (argumento vacío) se usan indistintamente en los
   documentos; `\ind{}` deja un subíndice vacío.
10. `.gitignore` excluye `makefile` y `NAcAL-Tex.tex`, pero `makefile` se
    genera del org y se usa para construir. Decidir si va en el repo.

## Cautelas (el orden importa)

La regla general: **ningún documento existente debe cambiar de aspecto sin
que Marcos lo haya decidido**. Hay exámenes en curso que usan el paquete.

1. **Línea base antes que nada.** Resolver el árbol sucio del repo (commit
   o descarte, preguntando a Marcos qué son los cambios de mayo de 2026).
   Etiquetar esa versión (`git tag v1.3-baseline` o similar). Guardar una
   copia congelada del `.sty` fuera del árbol de trabajo.
2. **Banco de pruebas de regresión.** Elegir un corpus representativo de
   documentos dependientes (al menos: un capítulo del libro, un vídeo de
   VideosMates2, un banco de preguntas moodle y uno AMC, una figura de
   `figuras/tex`, nota3.org del proyecto de probabilidad, y la propia
   documentación `nacal.pdf`). Compilarlos con el paquete congelado y
   guardar los PDF "dorados". Script que recompila con el paquete candidato
   y compara: texto (`pdftotext` + diff) y píxeles (`pdftoppm` + `compare`
   de ImageMagick, o `diffpdf`). Sin este banco no se cambia una línea.
3. **Fase de solo lectura.** Producir un informe de auditoría (fichero
   `AUDITORIA.md` en esta carpeta) con hallazgos clasificados en:
   (a) errores que corregir sin cambio visible; (b) mejoras de estándares
   sin cambio visible (cabecera, opciones, espacio de nombres, docs);
   (c) cambios de comportamiento deseables, cada uno con su impacto
   estimado sobre el corpus. Marcos decide qué entra.
4. **Compatibilidad hacia atrás por diseño.** Ningún macro existente
   cambia de semántica. Lo nuevo se añade con nombre nuevo, o detrás de
   una opción de paquete (por ejemplo `\usepackage[v2]{nacal}` o
   `[probabilidad]`), de modo que los documentos antiguos compilan igual
   sin tocar nada. Lo que se quiera retirar se marca como obsoleto con
   `\PackageWarning` durante al menos un curso académico antes de quitarlo.
5. **Versionado y registro de cambios.** Arreglar `\ProvidesPackage` con
   fecha y versión reales; `CHANGELOG` en el repo; una etiqueta git por
   versión; reinstalar en `~/texmf` solo versiones etiquetadas; eliminar o
   enlazar las copias sueltas del .sty para que haya una sola.
6. **Trabajar siempre en `NAcAL-Tex.org`**, tanglear, correr el makefile y
   comprobar que el `.sty` regenerado coincide con el esperado antes de
   instalar.
7. **Pedir a Marcos que pruebe** en su flujo real (org-mode con exportación
   a LaTeX, moodle, AMC, manim o lo que usen los vídeos) antes de dar una
   versión por buena. Hay flujos que no se pueden reproducir desde aquí.

## Referencias de estándares para la fase de informe

- `clsguide` y `fntguide` de LaTeX (documentación del kernel) para
  estructura de paquetes y declaración de fuentes.
- `l3doc`/`dtxtut` para dtx; `l3build` si se quiere automatizar pruebas
  (quizá excesivo; un script con make basta).
- `xparse`/`ltcmd` (ya en el kernel) para `NewDocumentCommand`.
- `kvoptions` o `l3keys` para opciones clave-valor si se añaden opciones.
- `xspace`: leer la sección de avisos de su documentación antes de decidir
  la política.

## Cómo trabajar con Marcos

- En español. Es matemático y profesor, no desarrollador de LaTeX; agradece
  explicaciones de por qué una práctica es estándar, no solo el qué.
- Le preocupa romper lo que ya funciona más que la elegancia. Cada
  propuesta debe ir con su riesgo y con cómo se comprueba.
- Antes de proponer cambios en la parte de probabilidad del paquete,
  consultar `diccionario.org` y `CLAUDE.md` del proyecto de probabilidad:
  allí hay decisiones pendientes (A1-A7) que condicionan esos macros.

## Primeros comandos útiles

```
git -C . status
git -C . diff --stat
diff nacal.sty ~/texmf/tex/latex/nacal/nacal.sty
make ficheros            # regenera .sty y nacal.pdf desde .ins/.dtx
grep -c NewDocumentCommand nacal.sty
```

## Banco de pruebas (montado el 4/11/2026)

`pruebas/banco.sh` y `pruebas/muestra.txt` (54 documentos: libro, transparencias
P00-P07, exámenes 2010-2026). Trabaja en `~/temporal/nacal-banco/` sobre una
instantánea de las fuentes; el .sty congelado está en
`~/temporal/nacal-banco/sty/congelado/` y en `../nacal-congelado-v1.3-baseline/`.
Flujo: `banco.sh candidato DIR` (DIR contiene el nacal.sty candidato) y
`banco.sh comparar`; resultado en `~/temporal/nacal-banco/informe/`.
Validado: dos compilaciones con el congelado dan PDF idénticos; 1mu añadido en
`\Mat` se detecta en 53/54 documentos. Tras cambiar las fuentes de los
repositorios: `instantanea`, `preparar`, `dorado`.
Desde el 9/11/2026 el banco lee el libro de probabilidad de la carpeta que
Marcos comparte con Andrés, `~/repos/SynologyDrive/libroProbabilidad`
(sincronizada entre los dos NAS: **solo lectura**, nunca escribir ahí sin que
Marcos lo pida). Documentos `nota basura/nota3` y `nota libro`. La carpeta
`~/SynologyDrive/ReposGH/AndresyMarcos/probabilidadCasoFinito` es una copia
antigua. Referencia completa con la v1.6 en `~/temporal/nacal-banco/ref-v16/`:
para probar un candidato, `banco.sh candidato DIR` y
`banco.sh comparar ref-v16 candidato`.

## Versión instalada (8/11/2026)

En `~/texmf/tex/latex/nacal/` está la **v1.4** (etiqueta `v1.4`): `.sty`,
`.pdf`, `.dtx` e `.ins`. La v1.3 instalada antes está guardada en
`~/temporal/nacal-instalada-v1.3/`. Pruebas antes de instalar: el banco (54
documentos más `libro`), los 87 XML de `nacal-moodle` de `qbank-PEconometria`
(idénticos), las 87 preguntas AMC del qbank y los exámenes AMC
`PEctr-Test-2026-11-06` y `-10-30` (idénticos). Para probar una versión sin instalarla:
`TEXINPUTS=<carpeta del .sty>: make …` (no copiar el `.sty` a los proyectos).

## v1.5: reparto en tres paquetes (instalada el 9/11/2026)

Etiqueta `v1.5`. `nacal.dtx` genera `nacal.sty`, `nacal-probabilidad.sty` y
`nacal-econometria.sty` (guardas de docstrip `package`, `probabilidad` y
`econometria` en el bloque «Implementación» del org). `\usepackage{nacal}`
carga los tres; `[soloAL]` solo álgebra lineal. Propuesta y decisiones en
`REPARTO-paquetes.org` (D1, D2 y D3 aprobados; D2, los nombres, el 9/11, tal como
estaban en la propuesta). Banco (57 documentos, con `ectr print` y `nota3`):
idéntico a la v1.4. Para probarla: `TEXINPUTS=~/temporal/nacal-banco/sty/v15:`.
Instalada el 9/11/2026 en `~/texmf/tex/latex/nacal/` (tres `.sty`, `.pdf`,
`.dtx`, `.ins`); la v1.4 instalada está en `~/temporal/nacal-instalada-v1.4/`.
En instalaciones futuras, copiar siempre los tres `.sty`.
Cuidado: `latex nacal.ins` pregunta antes de sobrescribir; borrar antes los
`.sty` (como hace el makefile) y no lanzarlo sin `</dev/null`.

## v1.6 (instalada el 9/11/2026)

C3 y C4 de `AUDITORIA.md`: `\widebar` sin `\mathop` y «esp» con
`\operatorname`. Cambio visible aprobado por Marcos. Los «esp» escritos a mano
en el libro y en `T06.tex` de MatII también se corrigieron, sin commit en esos
repositorios. La v1.5 instalada está en `~/temporal/nacal-instalada-v1.5/`.

## nacal-moodle (9/11/2026)

Repo `../NAcAL-MoodleTex` (GitHub `nacal-moodle-latex-package`). Los «cambios
sin commit» eran commits de 2023 ya subidos a `master` desde otra copia; la
rama local se puso al día sin tocar ficheros. El fuente `NAcAL-MoodleTex.org`
y el `makefile` estaban excluidos por `.gitignore`: ahora están en git
(etiqueta `v1.1-baseline`). `main` (rama por defecto en GitHub) estaba en la
v1.0: se fusionó `master` en `main`, sin forzar. `~/texmf/tex/latex/nacal-moodle-latex-package/`
es un clon de `main`; actualizado con `git pull --ff-only`, ahora con la v1.1.
Copias congeladas de v1.0 y v1.1 en `~/temporal/nacal-moodle-congelado/`.
Prueba: los 87 XML de `qbank-PEconometria` salen idénticos con v1.0 y v1.1.
Para instalar versiones futuras: commit en `master`, fusionar en `main`, y
`git pull` en el clon de `~/texmf`.
v1.2 (9/11/2026, etiqueta `v1.2`, instalada): los mismos cambios que nacal
v1.6 en las definiciones HTML, y `\EOEpr` llamaba a `\Oepr`, que no existe.
Los 87 XML de `qbank-PEconometria` salen idénticos a la v1.1 (no usan esos
macros). Copia congelada en `~/temporal/nacal-moodle-congelado/v1.2/`.

## probnot: paquete de notación de probabilidad (borrador, 9/11/2026)

Borrador `probnot.sty` (nombre aprobado; no existe en CTAN ni TeX Live) con la
notación de los textos nuevos de probabilidad: preámbulo común + macros de
nacal-probabilidad copiados + 5 de nota3/dimensionFinita/slides; carga
`nacal[soloAL]`. Informe y borrador en la carpeta compartida
`~/repos/SynologyDrive/libroProbabilidad/probnot/` (Marcos lo pidió; es la única
subcarpeta compartida en la que se ha escrito) y en `~/temporal/probnot-borrador/`
(con los guiones). v0.2: `\LP` con `\mathpalette` (aprobado: se reduce en
subíndices, idéntico en texto). base y diccionario salen idénticos; nota3 cambia
la pág. 40 (`\PSpan` en subíndice, corregido); dimensionFinita y slides además
por D5 (`\SPI`) y D7 (`\PSpan` de nacal en slides). libro.org sigue con nacal (D1).
dimensionFinita y slides (en `probabilidadEnRn.zip`) se exportaron con scimax;
se reproducen con `emacs --batch -l exporta.el` (solo ejecuta bloques `latex`).
Cuando la notación esté cerrada, irá a un repositorio propio.
Pendiente: decisiones D1, D3-D5, D7, P1, P2, P4 y nota 5 (Marcos y Andrés).

## Separación de la probabilidad: nacal solo álgebra lineal (desde el 10/11/2026)

Objetivo de Marcos: `nacal` solo con álgebra lineal; cada proyecto aporta su
notación de probabilidad/econometría en un paquete propio, **sin converger**.
Plan por fases en `~/temporal/estrategia-fable/plan.org` (y `.pdf`).
Decidido: paquetes en el repositorio de cada proyecto con enlace simbólico
desde `~/texmf`; Matemáticas II usa el paquete del libro; `nacal-probabilidad`
y `nacal-econometria` quedarán instalados y congelados tras una opción `[v1]`;
`CursoAL-SRC` y `CursoDeAlgebraLineal-SRC.viejo` están abandonados.
Todo se compila en esta máquina; Andrés baja `nacal` de GitHub a su `~/texmf`.

- **Fase 0 (hecha)**: `Econometria-SRC` bajo git (commit inicial, 10/11/2026).
  Banco ampliado a 213 documentos (tipo `suelto`: 152 figuras/prácticas que
  cargan `nacal`); referencia v1.6 en `~/temporal/nacal-banco/ref0/` (dos
  pasadas idénticas; preparar con `CONGELADO=~/temporal/nacal-banco/sty/v16`).
  `pruebas/banco-qbank.sh` para los bancos de preguntas (XML y PDF sobre una
  copia); referencia de `qbank-econometria` en
  `~/temporal/nacal-banco/qbank/qbank-econometria/ref-v16/` (dos generaciones
  idénticas; cada una tarda unos 45 min). La referencia de control de
  `qbank-PEconometria` quedó a medias (falta de memoria): relanzar solo cuando
  Marcos lo diga. Lanzar a la vez el banco y un qbank agota los 15 GB.
- **Fase 1 (hecha)**: `alprobnot.sty` (en `CursoDeAlgebraLineal-SRC/`),
  `ectrnot.sty` y `ectrnot-moodle.sty` (repositorio `../ectrnot`, solo local,
  etiqueta `v1.0`), enlazados desde `~/texmf/tex/latex/{alprobnot,ectrnot}/`.
  Son `.sty` directos (sin org ni dtx), copia literal de la v1.6: los 187 macros
  tienen `\meaning` idéntico salvo el alfabeto interno `\nacal@bb`, renombrado.
  Generados con `~/temporal/estrategia-fable/guiones/crea_paquetes.py`.
  No se pueden cargar junto a `\usepackage{nacal}` sin `soloAL` (dan error claro).
  `\usepackage{ectrnot-moodle}` carga `nacal-moodle[soloAL]` (que avisa de
  opción desconocida, inofensivo hasta la fase 4) y `ectrnot`.
- **Fase 2 (hecha, 10/11/2026)**: `qbank-econometria` migrado a `ectrnot`
  (commit local `d899745`; 39 XML y 114 PDF idénticos a la referencia; hay un
  espejo en una organización de GitHub solo para consulta). `Econometria-SRC`
  migrado (80 ficheros, commit `c5baf1a`; 67 documentos del banco idénticos).
  El libro (commit `ff1d7a9`, 56 ficheros seguidos + 8 sin seguimiento) y
  `MatematicasII-SRC` (commit `61a6ed9`, 6 seguidos + 35 sin seguimiento)
  migrados a `alprobnot`; 144 documentos del banco idénticos. Copia previa de
  los ficheros tocados (los no seguidos no tienen otra) en
  `~/temporal/estrategia-fable/respaldo-fase2/`. Ningún commit subido a
  GitHub: los `push` los hace Marcos. Para probar una migración: segunda raíz
  `BANCO=~/temporal/nacal-banco-migrado` con las fuentes parcheadas, `preparar`
  y `_generar`, y comparar con `ref0`. `qbank-PEconometria` no usa ningún
  macro de probabilidad ni econometría: no se migra, sirve de control.
- **Fase 3 (hecha, 10/11/2026)**: censo en
  `~/temporal/estrategia-fable/censo.org` (datos en `censo/`, guion
  `guiones/censo.py`). Salieron dos proyectos activos fuera del plan, ya
  resueltos con commits locales sin subir:
  `PEconometria` (commit `cbaf0bb`): las figuras de `org-lessons/img/S05-Lecc04`
  cargan `nacal[soloAL]` y definen `\media` y `\dt` en su preámbulo; en
  `S03-Lecc03` se quitó un `\RenewDocumentCommand\sesp` sin uso; 17 figuras
  idénticas (los `.tex` de `tex/`, fuera de git, llevan el mismo cambio).
  `org-pract/CursoAntiguo` (2023) usa probabilidad: resuelto el 11/11/2026
  con `\usepackage[v1]{nacal}` en sus 21 ficheros (commit de PEconometria
  de esa fecha; visto el 20/11, sin compilarlos).
  `qbank` (commit `0e76f41`): los ejemplos cargan `ectrnot-moodle`; es
  provisional, `NOTA-notacion-ejemplos.org` pide decidir cuando se retome.
  Marcos aprobó publicar `ectrnot` en GitHub (lo sube él).
  Vídeos, exámenes AMC y Econometría Aplicada no usan probabilidad. Lo demás
  son copias viejas que se resucitan con `[v1]` (`POM-Econometria-SRC` es una
  versión primitiva y abandonada de `qbank-econometria`). La copia viva de
  probabilidadCasoFinito es `~/repos/SynologyDrive/libroProbabilidad/basura`;
  `probnot` se desarrolla para los documentos de esa carpeta compartida.
  Copias previas en `~/temporal/estrategia-fable/respaldo-fase2/`.
- **Fase 4 (hecha, 11/11/2026)**: `nacal` v2.0 y `nacal-moodle` v2.0, con
  etiqueta `v2.0`, instalados y subidos (`master`; en `nacal-moodle` también
  `main`). `\usepackage{nacal}` es solo álgebra; `[v1]` carga los dos `.sty`
  de la v1.6, congelados en `v1/` (ficheros estáticos: ya no salen del dtx);
  `soloAL` no tiene efecto. En `nacal-moodle`, `[v1]` carga el fichero
  congelado `nacal-moodle-probabilidad.sty`. Instalación de `nacal`: copiar
  `nacal.sty`, `.pdf`, `.dtx`, `.ins` y `v1/*.sty` a `~/texmf/tex/latex/nacal/`.
  La v1.6 instalada está en `~/temporal/nacal-instalada-v1.6/`. Pruebas en
  `CHANGELOG.md`; candidato y resultados en `~/temporal/nacal-v2/` y
  `~/temporal/nacal-banco/` (referencia `ref1`, 230 documentos, fuentes ya
  migradas). No se tocaron `PEctr-Test-2026-11-12` ni `-11-13`.
  La rama `main` de `nacal` en GitHub (por defecto) se puso al día el
  11/11/2026 fusionando `master`, sin forzar; en versiones futuras, fusionar
  `master` en `main` tras etiquetar. Nota para Andrés en
  `~/temporal/estrategia-fable/para-andres.org`; Marcos avisa cuando Andrés
  haya instalado la v2.0 y no esté editando, y entonces se pone `[v1]`.
  Hecho el 11/11/2026 a petición de Marcos: `\usepackage[v1]{nacal}` en 40
  ficheros de la carpeta compartida (42 líneas; copia previa en
  `~/temporal/estrategia-fable/respaldo-fase4/`); `libro` y `nota3` idénticos
  a la referencia v1.6. Sin tocar: `probnot/`, los informes y
  `basura/kalman/kalman4.org` (línea comentada).
  Lo que aquí quedó anotado como pendiente está hecho: `[v1]` en la carpeta
  compartida (11/11), `CursoAntiguo` de PEconometria (11/11) y la fase 5.
- **Banco (superado el 20/11/2026 por `ref2`, ver más abajo)**: la
  referencia era `~/temporal/nacal-banco/ref1`
  (v1.6, 230 documentos, fuentes ya migradas; idéntica a la v2.0 salvo los
  dos documentos del libro de probabilidad, que desde el 11/11 llevan `[v1]`).
  `ref0` es anterior a la migración. Tras cambiar fuentes: `instantanea`,
  `preparar` y nueva referencia.
- **Fase 5 (11/11/2026)**: notas de «documento histórico» en
  `REPARTO-paquetes.org` y `AUDITORIA.md`; `Ejemplo` de `nacal-moodle`
  regenerado. Pendiente: vaciar `~/temporal` cuando Marcos haya
  probado su flujo real.
- **probnot v0.3 (11/11/2026)**: `\SPI` sin opcional no lleva subíndice (D5
  resuelta por Marcos). Corregido en `~/temporal/probnot-borrador/`. En la carpeta compartida hay un diccionario
  (`basura/diccionario.org`) útil para el inventario de conceptos.
- **Inventario de probnot (11/11/2026)**: `~/temporal/probnot-inventario/`
  (`inventario.org`/`.pdf`, guion `inventario.py`): 37 conceptos del
  diccionario compuestos con el preámbulo real de libro, nota3, común,
  dimensionFinita, slides y probnot v0.3, con las definiciones que difieren y
  ocho cuestiones de notación abiertas. El 11/11, a petición de Marcos, se
  llevó la decisión de `\SPI` a la carpeta compartida: `probnot/probnot.sty`
  (v0.3) y `basura/preambulo-comun.org`, `base.tex` y `diccionario.tex`
  (copia previa en `~/temporal/estrategia-fable/respaldo-fase4/spi/`). Sin
  tocar: `nota3` (preámbulo propio) y `basura/kalman/probnot.sty` (la
  actualiza Andrés). Después, también a petición de Marcos: informe de
  `probnot/` al día y `notacion/nacal.sty` borrado (copia en
  `respaldo-fase4/notacion/`; quedan `nacal.dtx`, `.ins`, `.pdf` y `celacanto.*`).
- Los `pre/notacion.tex` de Matemáticas II y Econometría no los carga nadie.
- `NAcAL-MoodleTex/nacal.sty` es un enlace a este repositorio, no una copia.
- **probnot tiene repositorio propio (13/11/2026)**: `../probnot` (GitHub
  `mbujosab/probnot`, privado; etiqueta `v0.3`), con el `.sty`, el informe, el inventario, los
  guiones y su `CLAUDE.md`. Las sesiones sobre `probnot` se abren allí; lo
  de `~/temporal/probnot-borrador/` y `~/temporal/probnot-inventario/` queda
  como copia antigua. Lo que este fichero dice de `probnot` es historia.

## v2.1 (instalada el 16/11/2026)

Sale de `encargo-desde-el-libro.md` (tratado y respondido el 16/11; la
respuesta al libro está en su raíz, `respuesta-desde-nacaltex.md`).
Opción `avisacaja` (avisos en el `.log` cuando el argumento de `\Vect`,
`\Mat`, etc. llega con la caja contraria a la que se imprime) y «Guía rápida»
de sufijos en `nacal.pdf`. Sin cambio visible: banco idéntico a `ref1`
(detalle en `CHANGELOG.md`). Aprobada por Marcos el 16/11: etiqueta
`v2.1`, instalada en `~/texmf/tex/latex/nacal/` (la v2.0 instalada está en
`~/temporal/nacal-instalada-v2.0/`), `master` fusionada en `main` y subida.
Los bancos de preguntas no se pasaron con la v2.1.
La guía se genera con las filas escritas en el `.org`: si se añade una
familia con sufijos, añadir su fila a mano.
`\Matdim` en texto corrido (punto 3 del encargo): el «m×n» ensancha la caja y
baja la línea siguiente; no tiene arreglo sin cambio visible. Sin decidir.

## v2.2 (instalada el 19/11/2026). Velocidad

Marcos preguntó por la lentitud de compilar: es **prioritario** para él.
Causa: `\leftidx` y `\boldsymbol` componen su contenido cinco veces cada uno
y el factor se multiplica al anidar comandos; además cada copia llamaba a
`\MakeUppercase`. La v2.2 guarda el cambio de caja por argumento
(`\nacal@caja`) y quita `\leftidx` de `\RidxE` (deja una composición previa
en caja, necesaria en documentos que agotan las 16 familias matemáticas).
Libro: de 410 s a 38 s por pasada; Econometría: de 866 s a 128 s (sin turbo).
Banco, ciclo completo con pythontex: idéntico a `ref1` (detalle en
`CHANGELOG.md`). Aprobada por Marcos el 19/11: etiqueta `v2.2`,
instalada en `~/texmf/tex/latex/nacal/` (la v2.1 instalada está en
`~/temporal/nacal-instalada-v2.1/`), `master` fusionada en `main` y subida.
Tres exámenes AMC recientes idénticos a la v2.1; los `qbank` no se pasaron.
- Tras instalarla, los documentos con `\py{…}` dentro de comandos de nacal
  necesitan un ciclo completo con pythontex (cambia el número de
  evaluaciones). Para probar cambios de este tipo en el banco no basta
  `generar`: segunda raíz (`BANCO=~/temporal/nacal-banco-B`, con enlaces a
  `fuentes` y `ref1`), `CONGELADO=<sty candidato>`, `preparar`, `generar`,
  `comparar ref1 …`.
- `ref1` ya no reproduce `2026-Quiz2-C` (cambió la salida de Python, no el
  paquete): conviene rehacer la referencia con la versión que se instale.
- Más velocidad, medido el 19/11 (libro, una pasada, sin turbo; v2.2: 38 s).
  Techos con variantes que quitan toda repetición (PDF incorrecto): subíndices
  izquierdos (`\LidxE`, `\LRidxE`) 35 s, un 8 %: no compensa, y ahí el
  `\vphantom` hace falta. `\boldsymbol` 27 s, un 30 %: solo alcanzable
  guardando cajas ya compuestas, con riesgo en documentos que agotan las
  familias; quitar solo su medida previa ganaría unos 2 s. Recomendado a
  Marcos dejarlo aquí; no decidió. Los ~25 s restantes no son de nacal.
- Econometría sigue en el límite de familias (1,8 millones de mensajes
  «frozen version» en el log con la v2.1, 177 000 con la v2.2). Alternativa
  sin adoptar, en `AUDITORIA.md`: tomar el ⟦ ⟧ pequeño de `mathx` en vez de
  `matha` (ahora en `ectrnot` y `alprobnot`); es cambio visible.
- El banco calienta el portátil: lanzarlo con `JOBS=6` como mucho. Marcos
  desactiva el turbo con `echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo`.
- `respuesta-desde-el-libro.md` tratado en la v2.2: `\eleVV` y `\eleMM` ya
  no avisan con `avisacaja`; `\SV` sí. Aviso de pythontex enviado al libro
  en `encargo-desde-nacaltex.md`.


## ectrnot v1.1 y nacal v2.3 (20/11/2026)

- **`ectrnot` v1.1** (commit y etiqueta locales en `../ectrnot`, sin subir;
  instalada por el enlace de `~/texmf`): ⟦ ⟧ de `\Clase`, `\bigtimes`,
  `\Cero` y `\Uno` se componen como texto y no ocupan familias matemáticas.
  Los apuntes de Econometría ya no agotan las 16 familias (0 mensajes
  «frozen version»). 85 documentos del banco y `qbank-econometria` entero,
  idénticos. Cambia `{\Uno}^2` (entre llaves, 0,45 pt) y `\left\ldbrack` da
  error; nadie los usa. La v1.0 está en `~/temporal/ectrnot-instalada-v1.0/`.
  `alprobnot` (el libro) no se ha tocado: allí se usan `\ldbrack` y
  `\bigtimes` directamente y no consta que esté en el límite.
- **`nacal` v2.3** (etiqueta `v2.3`, instalada el 20/11/2026 en
  `~/texmf/tex/latex/nacal/`; la v2.2 instalada está en
  `~/temporal/nacal-instalada-v2.2/`; `master` fusionada en `main` y
  subida): el cambio de caja guardado admite argumentos con comandos
  protegidos o robustos. Libro, de 18,9 s a 13,7 s; Econometría, de 66,5 s
  a 50,6 s (con turbo). Sin cambio visible: banco, seis exámenes AMC con
  `lualatex`, las 2 155 fórmulas de manim de los vídeos (guiones en
  `~/temporal/nacal-guiones-v23/`) y `qbank-econometria`; detalle en `CHANGELOG.md`. La salida
  de la v2.2 con la que se comparó el banco es
  `~/temporal/nacal-banco-B/cand-v22`. Sin probar con otra versión de
  LaTeX que TeX Live 2022 (Andrés puede tener otra): usa `\regex` y
  `\l_text_…_tl` de expl3.
- Marcos preguntó si quitar `\MakeUppercase`/`\MakeLowercase` y limpiar los
  fuentes: medido, no compensa (0,3 s más sobre la v2.3) y se pierde la red
  de seguridad.
- `\Matdim` en texto corrido: Marcos decidió dejarlo tal cual (20/11).

## Referencia del banco: `ref2` (20/11/2026)

- **La referencia vigente es `~/temporal/nacal-banco/ref2`** (sustituye a
  `ref1`): 230 documentos, `nacal` v2.3, `ectrnot` v1.1 y `alprobnot` v1.0,
  fuentes copiadas el 20/11/2026; dos pasadas finales idénticas (`ref2` y
  `ref2b`). Auxiliares en `~/temporal/nacal-banco/trabajo`; los de `ref1`
  quedan en `trabajo-ref1-v16`. El `.sty` de la referencia está en
  `~/temporal/nacal-banco/sty/v23/`. Para probar un candidato:
  `JOBS=6 banco.sh generar DIR NOMBRE` y `banco.sh comparar ref2 NOMBRE`.
- `libro` y `nota3` del libro de probabilidad ya compilan dentro del banco,
  y `2026-Quiz2-C` vuelve a reproducirse.
- `MatematicasII-SRC` se reorganizó: `Version0/` ya no existe, el material
  está en `clases/` (`partes/`, `lecciones/`, `problemas/`). `banco.sh` lee
  `clases/` y compone las transparencias con la receta del makefile nuevo.
  Si `instantanea` da un error de `rsync`, es que algún repositorio ha
  cambiado de estructura: el banco seguiría con la copia vieja sin avisar
  más que en esa línea.
- El ciclo completo (instantánea, `preparar`, dos pasadas y comparar) tarda
  unos 12 minutos con `JOBS=6` y el turbo activo.
- **Vídeos**: `pruebas/banco-manim.sh` (`instantanea`, `generar DIR NOMBRE`,
  `comparar A B`) compila con `latex` las 2 155 fórmulas que manim guardó en
  `media/Tex` de `VideosMates2` y `videoMath2` y compara los DVI. Referencia
  en `~/temporal/nacal-banco/manim/ref2` (dos generaciones idénticas).
- `~/temporal/nacal-banco-B` queda obsoleto: enlaza a las fuentes del banco,
  que han cambiado.

## Exploración cerrada: negrita guardada en cajas (20/11/2026)

Lo que queda de `nacal` en el tiempo de compilación es `\boldsymbol`. Se
exploró guardar en cajas la negrita ya compuesta: el libro baja de 14,5 s a
10,5 s y las transparencias `P04_screen` de 26,3 s a 11,4 s; Econometría
apenas (de 51,5 s a 48,5 s). Banco idéntico a `ref2` con la variante
prudente, pero tiene un riesgo que la v2.3 no tiene (falla en silencio si el
contexto cambia). **Marcos decidió no adoptarlo por ahora.** Todo lo
aprendido, las dos trampas encontradas y el prototipo están en
`pruebas/prototipos/cajas-boldsymbol.org` y `.diff`: leerlos antes de volver
a tocar `\boldsymbol`. La parte de Econometría habría que estudiarla en
`ectrnot`.

## `alprobnot` v1.1 (instalada el 20/11/2026 por la sesión del libro)

`libro-P` ocupaba 13 de las 16 familias matemáticas (el umbral es 14);
`libro` y Matemáticas II, 11 o 12. Marcos pidió adelantarse: `alprobnot`
v1.1 lleva el mismo cambio que `ectrnot` v1.1 y baja todos a 10. El libro
la aplicó y la confirmó en su git el mismo día (respuesta en
`respuesta-desde-el-libro.md`); por el enlace de `~/texmf` es la que usa
también Matemáticas II. Copia del candidato en
`pruebas/prototipos/alprobnot-v1.1-candidato.sty` (y `.diff`).
Pruebas: banco contra `ref2`, 230 idénticos; `libro-P` con `P-Cap03` y
`P-Cap04` activados (están comentados en `libro-P.tex`, y ahí están 11 de
los 12 `\bigtimes`), idéntico; las ocho partes de Matemáticas II en inglés,
idénticas. Desde entonces la muestra tiene 238 documentos (`P00` a `P07` en
print-profENG, añadidos a `ref2`).
Lección: contar apariciones en los fuentes no dice qué se compila; mirar
qué ficheros incluye el documento principal.
Para medir las familias de un documento:
`pdflatex -jobname X '\AtEndDocument{\typeout{\expandafter\the\csname c@mv@normal\endcsname}}\input{X.tex}'`.
Avisos informativos (20/11/2026), en `encargo-desde-nacaltex.md` sin
confirmar: `MatematicasII-SRC` (le llegará `alprobnot` v1.1 por el enlace
cuando el libro lo aplique), `qbank-econometria` y `qbank` (`ectrnot` v1.1
ya instalada). `Econometria-SRC` no tiene sesión: lo lleva Marcos. Andrés
no usa ni `alprobnot` ni `ectrnot`: no hay que avisarle. Los qbank y
Econometría no tienen el aviso automático de encargos: decírselo a Marcos
al abrir sesión allí.

## Limpieza de `~/temporal` (20/11/2026)

Hecha a petición de Marcos: de 8,7 GB a unos 2,2 GB. **Casi todas las rutas
de `~/temporal` que cita este fichero más arriba ya no existen** (raíces
`nacal-banco-B`, `-C`, `-migrado`, `-v1`; `nacal-flujo`; `nacal-v2`; las
`nacal-instalada-v1.3` a `v2.1`; pruebas de `nacal-moodle` y de AMC;
`probnot-borrador` e `-inventario`; referencias `ref0`, `ref1`, etc.).
Sus resultados están en `CHANGELOG.md` y en este fichero. Queda:

- `~/temporal/nacal-banco/`: `fuentes`, `trabajo`, `ref2`, `sty/v23`,
  `manim/{fuentes,ref2}` y `qbank/` (copia `src-20261120` y las últimas
  generaciones).
- `nacal-instalada-v2.2` y `ectrnot-instalada-v1.0` (para volver atrás),
  `estrategia-fable` (plan y copias previas de ficheros que no estaban en
  git), `Econometria-copia-2026-11-05`, `nacal-moodle-congelado`,
  `nacal-guiones-v23`.
- No son de esta sesión y no se tocan: `MatematicasII-SRC`, `CloudStation`
  y `SynologyDrive` (carpetas de compilación de los makefiles, con uso
  reciente), `MatematicasII-referencia`/`-nacal030`/`-nacal041`,
  `matII-tex-acumulados`, `nacal-banco-python`, `nacal-muestra-fracciones`,
  `revision-fable`, `init-prueba`.

`banco.sh` usa ahora por defecto el `nacal.sty` instalado como «congelado»
(antes, una copia de la v1.3 en `sty/congelado`, ya borrada). Para borrar en
`~/temporal` hay que dar rutas literales: el `rm -rf` con variables lo
bloquea una comprobación de seguridad.

## `xcolor` (decidido el 20/11/2026)

`nacal.sty` carga `xcolor` pero ya no lo usa: lo necesitaba `\ColorA`, que
hoy está en `v1/nacal-econometria.sty`, `ectrnot` y `alprobnot`, y ninguno
lo carga por su cuenta. Decisiones de Marcos:
- **No quitar `xcolor` de `nacal`**: rompería los documentos que usan
  `\color` sin cargarlo, y no se gana nada.
- En la **próxima versión real** de `ectrnot` y de `alprobnot`, añadirles
  `\RequirePackage{xcolor}` (sin efecto visible). No sacar versiones solo
  para esto. Anotado en el `README.org` de `ectrnot`; para `alprobnot`,
  incluirlo en el siguiente encargo al libro que toque ese fichero.

## Las cuatro pruebas de regresión (desde el 21/11/2026)

Todas en `pruebas/`, todas sobre copias en `~/temporal/nacal-banco/` y con
la misma forma (`instantanea`, `generar DIR NOMBRE`, `comparar A B`):

| Guion | Qué compila | Referencia |
|---|---|---|
| `banco.sh` | 238 documentos: libro, Matemáticas II, exámenes, Econometría, figuras (`pdflatex`, `xelatex`) | `ref2` |
| `banco-manim.sh` | 2 155 fórmulas de los vídeos (`latex`, DVI) | `manim/ref2` |
| `banco-amc.sh` | los seis exámenes AMC más recientes (`lualatex`) | `amc/ref2` |
| `banco-qbank.sh` | un banco de preguntas entero, XML y PDF (lento: 45 a 90 min) | la generación anterior |

Antes de instalar una versión de `nacal`: las tres primeras (unos 5 minutos
en total con `JOBS=6`); la cuarta, si el cambio puede afectar a Moodle o si
Marcos lo pide. `banco-amc.sh` solo copia las fuentes de los exámenes:
nunca escaneos, notas ni datos de alumnos. Sustituye al guion suelto de
`~/temporal/nacal-guiones-v23/`.

`qbank-PEconometria` entero (21/11/2026): generado con la v2.2 y la v2.3
sobre una copia congelada, 733 ficheros idénticos. Cada generación tarda
unos 90 minutos. Con esto, la v2.3 está probada contra todo lo que se ha
podido compilar aquí; falta el flujo real de Marcos y otra versión de LaTeX.
