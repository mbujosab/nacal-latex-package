# Registro de cambios de nacal

Cada versión tiene una etiqueta git con el mismo nombre (`v1.3.1`, `v1.4`…).
En `~/texmf` solo se instalan versiones etiquetadas.

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
