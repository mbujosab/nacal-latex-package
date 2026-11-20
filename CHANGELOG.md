# Registro de cambios de nacal

Cada versión tiene una etiqueta git con el mismo nombre (`v1.3.1`, `v1.4`…).
En `~/texmf` solo se instalan versiones etiquetadas.

## v2.3 (2026-11-20). Candidata: sin etiqueta ni instalar

Compilación más rápida, sin cambio visible. Sale de una pregunta de Marcos:
si convenía quitar `\MakeUppercase` y `\MakeLowercase` y corregir los fuentes.

Medida en el libro: de 289 271 llamadas al cambio de caja, 8 408 escapaban
al guardado de la v2.2 y llamaban cada vez a `\MakeUppercase` o
`\MakeLowercase` (unos 0,7 ms cada una). Eran argumentos con comandos
dentro: `\Vect{\boldsymbol{\gamma}}`, `\Mat{\MatT{A}}`, `\Vect{Q^*}`,
`\Mat{C'}`…

- El resultado guardado admite ahora cualquier argumento hecho de caracteres
  ASCII corrientes (letras sin acento, cifras, signos, llaves, `^`, `_`) y
  de comandos que el cambio de caja deja como están: símbolos `\mathchardef`
  (como `\beta`), comandos protegidos (todos los de `\NewDocumentCommand`) y
  robustos (como `\boldsymbol`), salvo los que `\MakeUppercase` trata aparte
  (`\ref`, `\label`, `\ensuremath`…). Lo decide `\nacal@caja@fija:NF`.
- Siguen por el camino de antes los argumentos con acentos, caracteres
  activos, `$` o comandos corrientes (`\widehat`, `\,`, `\_`, los del
  usuario), porque un comando corriente puede cambiar de definición entre
  dos usos. En el libro quedan 356 llamadas así.
- No se quita el cambio de caja: una variante sin él tarda lo mismo que esta
  (13,4 s frente a 13,7 s en el libro).

Tiempos de una pasada de `pdflatex` (misma máquina, con turbo; por eso no
son comparables con los de la v2.2 de abajo): el libro, de 18,9 s a 13,7 s;
los apuntes de Econometría (`ectr_print`), de 66,5 s a 50,6 s.

Pruebas (20/11/2026): banco de 230 documentos, pasada final sobre los
auxiliares de la v2.2 (el número de composiciones no cambia, así que no
hace falta el ciclo de pythontex): 228 idénticos a la salida de la v2.2;
los otros dos (`libro` y `nota3` del libro de probabilidad) no compilan en
la instantánea del banco, y compilados aparte sobre una copia de la carpeta
compartida salen idénticos byte a byte. Documento de prueba con 45 fórmulas
(acentos, `\ref`, un comando del usuario redefinido entre dos usos, cambio
de idioma, `avisacaja`): mismas medidas, mismos 41 avisos y 0 píxeles
distintos. El banco se pasó con `ectrnot` v1.1. Sin pasar: los bancos de
preguntas y los exámenes AMC.

## v2.2 (2026-11-19)

Compilación mucho más rápida, sin cambio visible. Sale de una pregunta de
Marcos sobre la lentitud de los documentos que usan `nacal`.

Causa: `\leftidx` (base de todos los subíndices) y `\boldsymbol` (negrita de
`\Mat` y `\Vect`) componen su contenido cinco veces cada uno, y al anidarse
los comandos esos factores se multiplican (`\Mat{A}` componía la «A» 25
veces; `\VectC{A}{j}`, 125). Además, cada repetición llamaba a
`\MakeUppercase` o `\MakeLowercase`, que son lentos.

- El cambio de caja se calcula una sola vez por argumento distinto y se
  guarda (`\nacal@caja`). Solo para argumentos hechos de letras sin acento,
  cifras y símbolos como `\beta`; en los demás casos se llama a
  `\MakeUppercase`/`\MakeLowercase` como antes.
- `\RidxE` (subíndice derecho, del que dependen `\Ridx`, `\elemR`, `\Mat`,
  `\Vect`, `\VectC`…) ya no usa `\leftidx`: compone el objeto una vez en una
  caja que se descarta y otra de verdad (dos veces en lugar de cinco). La
  caja descartada es necesaria: en documentos que agotan las 16 familias de
  fuentes matemáticas (los apuntes de Econometría), sin ella se perdía la
  negrita de una `\Mat{R}`.
- Los subíndices izquierdos (`\LidxE`, `\LRidxE`) no se han tocado.
- Con `avisacaja`, `\eleVV` y `\eleMM` ya no avisan: su uso normal es
  darles el nombre de la matriz en mayúsculas (pedido por la sesión del
  libro en `respuesta-desde-el-libro.md`). `\SV` sigue avisando.

Tiempos de una pasada de `pdflatex` (misma máquina, sin turbo): el libro,
de 410 s a 38 s; los apuntes de Econometría (`ectr_print`), de 866 s a 128 s.

**Aviso para documentos con pythontex dentro de comandos de nacal** (por
ejemplo `\TrC[\py{…}]{…}`): pythontex numera cada evaluación y ahora hay
menos, así que la primera compilación tras instalar la v2.2 necesita el
ciclo completo (`pdflatex`, `pythontex`, `pdflatex`). Con solo `pdflatex`
esas fórmulas salen con resultados descolocados.

Pruebas (19/11/2026): banco de 230 documentos, ciclo completo con pythontex,
contra `ref1`: 227 idénticos; 2 sin PDF (los del libro de probabilidad, cuya
instantánea es anterior a su `[v1]`, como en la v2.0 y la v2.1); 1 distinto,
`2026-Quiz2-C`, que no depende del paquete (con la v2.1 de hoy sale igual
byte a byte: cambió la salida de Python, 1/2 donde la referencia tiene 0.5).
La caché sola, sin tocar `\RidxE`: 228 idénticos con solo la pasada final.
`avisacaja`: mismos avisos y mismos píxeles que en la v2.1. Respecto a la
v2.1 solo cambian `\RidxE`, `\nacal@min` y `\nacal@may`. Exámenes AMC
`PEctr-Test-2026-11-13`, `-11-12` y `-11-06`, compilados con `lualatex` sobre
copias: idénticos a la v2.1 (píxeles y texto). Los bancos de preguntas no se
han pasado. Aprobada por Marcos e instalada el 19/11/2026.

## v2.1 (2026-11-16)

Sin cambio visible en ningún documento. Sale de un encargo de la sesión del
libro (`encargo-desde-el-libro.md`).

- Opción nueva `avisacaja`: `\usepackage[avisacaja]{nacal}` escribe un aviso
  en el `.log` cada vez que un argumento llega con la caja contraria a la que
  se imprime (`\Vect{A}` imprime **a**; `\Mat{b}` imprime **B**). Sirve para
  limpiar los fuentes. No cambia nada de lo que se compone: un documento de
  prueba sale idéntico píxel a píxel con la opción y sin ella. Un aviso por
  fichero, línea, comando y argumento. Solo mira letras sin acento.
- Para ello `\vect`, `\Vect`, `\Mat`, `\SV`, `\eleVV` y `\eleMM` cambian la
  caja con dos comandos internos, `\nacal@min` y `\nacal@may`, que sin la
  opción equivalen a `\MakeLowercase` y `\MakeUppercase`. Los otros 496
  macros tienen la misma definición que en la v2.0 (`\meaning` idéntico).
- Documentación: «Guía rápida» de los sufijos `p`, `P`, `pE`, `PE` y la
  estrella en la introducción de `nacal.pdf`, con una fila por cada una de
  las 83 familias y el resultado de cada variante; nota del convenio de
  mayúsculas y minúsculas junto a `\Vect` y `\Mat`. `nacal.pdf` pasa de 86 a
  90 páginas.

Pruebas (16/11/2026): banco de 230 documentos contra `ref1`, 228 idénticos;
los otros dos (`libro` y `nota3` del libro de probabilidad) no compilan en
la instantánea del banco porque es anterior a su `[v1]` (igual que con la
v2.0); compilados aparte con `[v1]` salen idénticos a `ref1`. Los bancos de
preguntas no se pasaron (no usan la opción). Aprobada por Marcos e instalada
el 16/11/2026.

## v2.0 (2026-11-11)

`nacal` queda solo con álgebra lineal. Cambio incompatible para los
documentos que usan la notación de probabilidad o de econometría.

- `\usepackage{nacal}` ya no carga `nacal-probabilidad` ni
  `nacal-econometria`. Equivale al `\usepackage[soloAL]{nacal}` de la v1.6:
  los 501 macros tienen la misma definición (`\meaning` idéntico).
- Opción nueva `v1`: `\usepackage[v1]{nacal}` carga además los dos paquetes
  viejos y equivale al `\usepackage{nacal}` de la v1.6 (688 macros
  idénticos). Sirve para compilar documentos antiguos sin tocarlos más.
- `soloAL` se acepta y no tiene efecto.
- `nacal-probabilidad.sty` y `nacal-econometria.sty` (v1.6) ya no se generan
  de `nacal.dtx`: son ficheros congelados en `v1/`. Su fuente literario está
  en git bajo la etiqueta `v1.6`. Hay que instalarlos junto a `nacal.sty`.
- De `NAcAL-Tex.org` salen las secciones de probabilidad, econometría y
  sucesiones (unas 3000 líneas). `\Media`, `\Estmc` y `\VEstmc`, que estaban
  en esas secciones pero pertenecen a `nacal.sty`, pasan a una sección nueva,
  «Media y ajuste».
- Documentación: `nacal.pdf` pasa de 113 a 86 páginas. Se retira `\bigtimes`
  de la documentación (es de `nacal-probabilidad`) y un ejemplo de `\proy`
  que usaba `\indUno`.

La notación de probabilidad y econometría vive ahora en paquetes de cada
proyecto: `alprobnot` (libro de Álgebra Lineal y Matemáticas II) y `ectrnot`
(Econometría; <https://github.com/mbujosab/ectrnot>).

Pruebas (10 y 11/11/2026, antes de instalar): banco de 230 documentos, 228
idénticos a la v1.6; los otros dos (`libro` y `nota3` del libro de
probabilidad, que cargan `nacal` sin opciones) salen idénticos con `[v1]`.
`qbank-econometria`: 39 XML y 114 PDF idénticos. `qbank-PEconometria`: 88 XML
y 261 PDF idénticos.

## v1.6 (2026-11-09)

Cambios visibles, aprobados por Marcos el 9/11/2026 (C3 y C4 de
`AUDITORIA.md`).

- `\widebar` deja de ser un operador (`\mathop`). Afecta a `\Media` y
  `\conj`. Antes, en `a\Media{\Vect{x}}+b\Media{\Vect{y}}`, había un espacio
  fino entre la `a` y la barra, y el `+` perdía su espacio («a x̄ +b ȳ»). En
  fórmulas destacadas, `\Media{X}_n` ponía la n debajo de la barra; ningún
  documento lo usaba.
- «esp» (`\EOEsu`, `\EOEpr`, `\EOEg`, `\EInvOEg`, `\dEOEgE`, `\dEOEg` y
  `\dEInvOEg`) se escribe como operador, `\operatorname{esp}`: recto, no en
  cursiva. En `\EOEsu` y `\EOEpr`, `\Big(`…`\Big)` pasa a
  `\Bigl(`…`\Bigr)`, para que no quede un espacio entre «esp» y el paréntesis.

Efecto medido con el banco (frente a la v1.5): cambian 6 páginas del libro
(87, 88, 89, 104, 222 y 233; en `libro-P`, 93, 94, 95, 110, 248 y 259) y 4 de
los apuntes de Econometría (22, 23, 50 y 147). Ningún examen ni transparencia.

En los documentos, «esp» escrito a mano (`esp(`, `esp\big(`, `esp\Invp*`)
pasa también a `\operatorname{esp}`: 23 apariciones en el libro (`Cap04`,
`Cap05`, `Cap16` y `Cap17`) y 3 en `MatematicasII-SRC/Version0/temas/T06.tex`.
Con eso, frente a la v1.5 cambian 9 páginas del libro (87, 88, 89, 104, 222,
224, 229, 233 y 236) y 1 transparencia de `P06` (página 14 de `print-prof`).
Antes y después, en `~/temporal/nacal-v16-cambios.pdf`.

Libro de probabilidad compartido con Andrés (`~/repos/SynologyDrive/libroProbabilidad`,
`libro.tex`): cambian 9 de 97 páginas (36, 42, 50, 51, 57, 58, 59, 62 y 66),
por `\conj` con una letra delante (`f\conj{g}` sale «fḡ» y no «f ḡ»).
Medido después de instalar; Marcos lo aprobó el 9/11/2026.

AMC (87 preguntas de `qbank-PEconometria` y los exámenes
`PEctr-Test-2026-11-06` y `-10-30`): idénticos a la v1.5. Ninguno usa
`\Media` ni «esp».

Instalada en `~/texmf` el 2026-11-09. La v1.5 instalada está guardada en
`~/temporal/nacal-instalada-v1.5/`.

## v1.5 (2026-11-08)

Sin cambio visible. Reparto aprobado por Marcos el 8/11/2026
(`REPARTO-paquetes.org`, D1 y D3).

- `nacal.dtx` genera tres paquetes: `nacal.sty` (álgebra lineal),
  `nacal-probabilidad.sty` (secciones Probabilidad y Sucesiones) y
  `nacal-econometria.sty` (Econometría). Cada uno carga el anterior.
- `\usepackage{nacal}` sigue cargando los tres, en el mismo punto y en el
  mismo orden que antes.
- Opción nueva `soloAL`: `\usepackage[soloAL]{nacal}` carga solo álgebra
  lineal (2 familias matemáticas menos).
- `\Media`, `\Estmc` y `\VEstmc` pasan a `nacal.sty` (D1): están disponibles
  también con `soloAL`.

Comprobaciones:
- Entre los tres `.sty` hay las mismas líneas de código que en la v1.4, salvo
  las cabeceras.
- Las 690 definiciones tienen el mismo `\meaning` (también el código interno
  de xparse) y las familias `matha`/`mathx` tienen el mismo número.
- Se han probado 12 combinaciones de carga: con `soloAL`, con
  `nacal-probabilidad` antes o después de `nacal`, con `eng` y con
  `nacal-moodle`.
- Banco de pruebas (ampliado con los apuntes de Econometría y `nota3` de
  `probabilidadCasoFinito`): los 57 documentos salen idénticos a la v1.4,
  píxel a píxel.
- Flujos completos (9/11/2026), con la v1.5 frente a la v1.4, todo idéntico:
  - los 57 documentos del banco compilados desde cero, como sus makefile
    (pythontex, bibtex, bib2gls, makeindex, latexmk);
  - 1008 fórmulas de manim (`media/Tex` de VideosMates2): DVI iguales byte a
    byte;
  - Moodle: 87 XML de `qbank-PEconometria` con `nacal-moodle` v1.1;
  - AMC: 87 preguntas y los exámenes `PEctr-Test-2026-11-06` y `-10-30`;
  - exportación desde org de `nota3.org` y `diccionario.org`.

Instalada en `~/texmf` el 2026-11-09 (los tres `.sty`, `.pdf`, `.dtx` e
`.ins`). La v1.4 instalada está guardada en `~/temporal/nacal-instalada-v1.4/`.

## v1.4 (2026-11-05)

Cambios visibles, aprobados por Marcos el 5/11/2026. Se miden con el banco de
pruebas (`pruebas/`).

- `\E`, `\Var`, `\Dt`, `\Cov`, `\Corr` y `\ESP` dejan de meter un espacio
  antes de `\xspace`. En modo texto, `\E{X}.` salía «E(X) .» y ahora sale
  «E(X).».
- `\elemLR` y `\deffun` dejan de meter un espacio delante: faltaba un `%` al
  final de la primera línea de la definición.
- Familia `pE` (`\VectFpE`, `\VectCpE`, `\VectTFpE` y `\VectTCpE`): con
  asterisco y argumento opcional, el paréntesis interior es ahora el mismo que
  sin asterisco (`\Matp*` / `\MatTpE*`), como en el resto de la familia.
  Ningún documento usa esa combinación.

Instalada en `~/texmf` el 2026-11-08, tras comprobar que `nacal-moodle` (87
XML de `qbank-PEconometria`) y AMC (87 preguntas del qbank y los exámenes
`PEctr-Test-2026-11-06` y `-10-30`) salen idénticos que con la v1.3.

Efecto medido: cambian 8 páginas del libro (70, 124, 157, 158, 167, 215, 264
y 271; desaparece un espacio doble o un espacio antes de puntuación). No cambia
ningún examen ni ninguna transparencia.

## v1.3.1 (2026-11-05)

Correcciones sin cambio visible: los 54 documentos del banco salen idénticos
píxel a píxel.

- `\ProvidesPackage` bien formado: una sola fecha y versión, sin acentos.
- Se borra una segunda declaración repetida de `\DeclareSymbolFont{mathx}`.
- `\eleMpE`, `\eleMPE`, `\eleMTpE` y `\eleMTPE` comprueban el argumento
  opcional (`#2`) y no el asterisco (`#1`).
- `\SITEFCRp`, `\SITEFCRP`, `\SITEFCRpE` y `\SITEFCRPE` llaman a `\SITEFCR`
  y no a `\SITEFC`, que da el orden inverso de las transformaciones.
  `nacal-moodle` ya las definía bien.
- Se elimina `\PSpanNew`. Dependía de `stackengine`, que no se carga, así que
  cualquier uso daba error. No lo usaba ningún documento.
- `\media`, `\mediaM`, `\dt`, `\dtM`, `\var`, `\varM`, `\cvarM`, `\cov`,
  `\covM`, `\corr` y `\corrM`: se quita una comprobación `\IfNoValueTF` sobre
  argumentos obligatorios. Nunca se cumplía, así que era código muerto.
- El alfabeto interno `\mymathbb` pasa a llamarse `\nacal@bb`, para no chocar
  con otros paquetes. No lo usa ningún documento.
- `\it` (obsoleto, de LaTeX 2.09) pasa a `\mathit` en `\normal`, `\tstudent`,
  `\fsnedecor` y `\ValorC`. El resultado es idéntico.
- `.gitignore`: el `makefile` pasa a estar en el repositorio y se ignoran los
  `*.hd`.

## v1.3 (2023-09-22) y anteriores

Historial en git hasta la etiqueta `v1.3-baseline` (commit `24f78e8`).
