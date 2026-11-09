# Auditoría de nacal.sty (v1.3)

Fecha: 4 de noviembre de 2026. Versión auditada: etiqueta `v1.3-baseline`
(commit `24f78e8`), idéntica a la instalada en `~/texmf/tex/latex/nacal/`.

Fase de solo lectura: **no se ha cambiado nada del paquete**. Las correcciones
que se mencionan como "medidas" se han probado en copias del `.sty` dentro del
banco de pruebas (`~/temporal/nacal-banco/sty/candA` y `candB`), nunca en la
copia instalada.

## Estado a 5 de noviembre de 2026

Marcos aprobó corregir la sección 1, corregir C1, arreglar `\Ind` en
Econometría (C2) y probar C5. Hecho:

- **v1.3.1** (commit `19936dc`, etiqueta `v1.3.1`): A1-A6, B4 (solo
  `\mymathbb`), B5 y B8, más `CHANGELOG.md`. Banco: 54/54 idénticos.
- **v1.4**: C1 y C5. Ver `CHANGELOG.md`.
- **C2**: hecho en el curso de Econometría (ver `~/SynologyDrive/ReposGH/AndresyMarcos/probabilidadCasoFinito/informe-notacion-nacal.org`,
  sección 4).
- **Sección 4** (probabilidad): sin cambios. Inventario y propuestas en
  `~/SynologyDrive/ReposGH/AndresyMarcos/probabilidadCasoFinito/informe-notacion-nacal.org`, para decidir con Andrés.
- Correcciones a este informe, hechas en la implementación:
  - A4: los `\SITEFCRp…` sí se usan, porque `nacal-moodle` los redefine para
    HTML. Por eso se corrigen y no se quitan.
  - A5: `\PSpanNew` se ha eliminado en lugar de marcarlo obsoleto. Daba error
    en cualquier uso, así que ningún documento que compile podía usarlo.
  - A8: **no es un error.** Comprobado: si un argumento `O{…}` recibe la marca
    «sin valor», LaTeX usa el valor por defecto. Pasar el opcional `o` tal
    cual es la forma correcta. No se cambia.
  - B2: `doc/nacal.sty` es un enlace simbólico a `../nacal.sty`; no puede
    desfasarse.

## Estado a 9 de noviembre de 2026

- **v1.5**: reparto en tres paquetes (`REPARTO-paquetes.org`). Instalada.
- **C3** y **C4**: aprobados por Marcos; hechos en la v1.6 (ver
  `CHANGELOG.md`). También se corrigieron los «esp» escritos a mano en el
  libro y en `T06.tex` de MatII.
- **C6**: se queda como está. La asignatura nunca se ha impartido en inglés.

## Resumen

El paquete está bien construido y no necesita rehacerse. Está escrito con
`dtx`/`docstrip` desde un fuente literario, documentado, versionado en git y
con licencia, y usa `\NewDocumentCommand` de forma uniforme. Esto último
importa: los comandos así definidos son *robustos* (funcionan dentro de
`\section`, `\caption`, etc.) y LaTeX avisa si un nombre ya existe, de modo
que el paquete nunca pisa en silencio un comando de otro.

Hay tres tipos de problemas:

1. **Una docena de errores concretos**, casi todos de copiar y pegar. Corregirlos
   no cambia ningún documento del banco (medido).
2. **Unos espacios sobrantes en modo texto** en ocho macros. Corregirlos cambia
   8 páginas del libro y ningún examen ni transparencia (medido). Es un cambio
   deseable, pero visible, así que lo decides tú.
3. **La parte de probabilidad y econometría está a medio diseñar.** Hay cuatro
   símbolos distintos para la esperanza, opcionales con significados
   distintos, y documentos que redefinen macros del paquete. Además, `\Ind`
   cambió de significado en 2023 y eso ha estropeado una tabla de los apuntes
   de Econometría (comprobado en el PDF). Esto no se arregla tocando código:
   requiere decisiones de notación tuyas y de Andrés.

## Cómo se ha medido

Banco de pruebas en `pruebas/` (ver `CLAUDE.md`): 54 documentos reales (el
libro completo, las transparencias P00-P07 en varias versiones y 41 exámenes
de 2010 a 2026). Se compilan con el `.sty` congelado y con el candidato, y se
comparan página a página por texto (`pdftotext`) y por píxeles (`pdftoppm` a
100 ppp + `compare`). Validación: dos compilaciones con el mismo `.sty` dan
PDF idénticos, y añadir 1mu (medio punto) a `\Mat` se detecta en 53 de los 54
documentos.

**Limitación:** el banco no incluye todavía documentos del curso de
Econometría ni de los proyectos de probabilidad, que son justo los que usan la
parte del paquete más necesitada de cambios. Antes de tocar esa parte hay que
añadirlos (ver sección 5).

---

## 1. Errores que se corrigen sin cambio visible

Medido: candidato A con todas estas correcciones → **54 de 54 documentos
idénticos píxel a píxel**.

**A1. `\ProvidesPackage` mal formado** (líneas 24-26).

```latex
\ProvidesPackage{nacal}
    [2023/01/05 v1.0
    [2023/09/22 v1.3 Notacion Asociativa para un Curso de Álgebra Lineal]
```

El argumento opcional debe empezar por `aaaa/mm/dd vX.Y`. Con dos fechas y un
corchete anidado, LaTeX lee como fecha `2023/01/05` y el resto como texto.
Consecuencia: `\listfiles` y el `.log` dicen que tienes la versión de enero de
2023, y un documento no puede exigir "nacal posterior a tal fecha" con
`\usepackage{nacal}[2024/01/01]`. Corrección: una sola fecha y versión, sin
acentos (la línea se escribe en el `.log` y en algunos motores los caracteres
no ASCII salen mal). La fecha debe cambiar en cada versión publicada.

**A2. `\DeclareSymbolFont{mathx}` repetido** (líneas 1566 y 1569). Es un
residuo: la segunda declaración repite la primera. Se borra.

**A3. `\eleMpE`, `\eleMPE`, `\eleMTpE`, `\eleMTPE` preguntan por el argumento
equivocado** (líneas 498-538). Escriben `\IfNoValueTF{#1}`, pero `#1` es el
asterisco; el opcional es `#2`. Hoy funcionan por casualidad: pasan siempre
el opcional, y cuando falta pasan la marca interna de "sin valor", que el
macro de dentro sabe interpretar. Se corrige `#1` → `#2`.

**A4. `\SITEFCRp`, `\SITEFCRP`, `\SITEFCRpE` y `\SITEFCRPE` llaman a `\SITEFC`
en vez de a `\SITEFCR`** (líneas 703-714). Error de copiar y pegar: las
variantes con paréntesis muestran el orden de las transformaciones de
`\SITEFC` (k…1 a la izquierda) y no el de `\SITEFCR` (1…k). Comprobado
compilando. Nadie los usa en ningún repositorio (0 apariciones), así que
corregirlo no cambia ningún documento.

**A5. `\PSpanNew` no puede funcionar.** Usa `\topinset`, del paquete
`stackengine`, cuya carga está comentada (línea 34). Cualquier uso da error.
No se usa en ningún documento. Propuesta: marcarlo obsoleto con un aviso
(`\PackageWarning`) y decidir su futuro dentro de la sección 4.

**A6. Comprobaciones inútiles** en `\media`, `\mediaM`, `\dt`, `\dtM`, `\var`,
`\varM`, `\cvarM`, `\cov`, `\covM`, `\corr` y `\corrM`. Preguntan con
`\IfNoValueTF` si un argumento *obligatorio* vino vacío, y eso nunca ocurre.
La rama "sin valor" es código muerto. No hace daño; se puede simplificar o
dejar.

**A7. Variantes con y sin asterisco idénticas** en `\MatTpE`, `\MatTPE`,
`\InvMatpE`, `\InvMatPE`, `\MVATpE` y `\MVATPE`: las dos ramas hacen lo mismo.
Quizá sea intencionado (por uniformidad de la familia). Sin cambio propuesto;
solo conviene saberlo.

**A8. La marca "sin valor" viaja de un macro a otro.** Por ejemplo, `\Matdim`,
`\eleMT`, `\MVect`, `\MatTp`, `\eleMp` e `\InvMatp` pasan su opcional `o` a
macros que lo declaran `O{}`, sin comprobar si vino. Compilado: no imprime
nada raro con la versión de LaTeX instalada, pero depende de un detalle
interno de LaTeX. Es la misma clase de fragilidad que A3. Corrección sin
cambio visible: comprobar antes de pasar. Prioridad baja.

## 2. Mejoras de estándares sin cambio visible

**B1. Versionado.** Corregido A1, adoptar la rutina que propone `CLAUDE.md`:
`CHANGELOG`, una etiqueta git por versión, e instalar en `~/texmf` solo
versiones etiquetadas. Así siempre se sabe con qué versión se compiló un
examen.

**B2. Copias sueltas del paquete.**
- `~/SynologyDrive/ReposGH/Investigacion/libroProbabilidad/notacion/nacal.sty`
  es la v1.0 (junio de 2023, 1509 líneas). Le faltan 189 macros, entre ellos
  toda la econometría, `\sspi`, `\ESP` e `\Ind`. Ningún documento la carga (en
  `libro.org` está comentada). Propuesta: borrarla o sustituirla por una nota
  que remita a la instalada.
- `doc/nacal.sty` dentro del repositorio coincide con la actual, pero se
  desfasará en cuanto haya una versión nueva. Mejor que `make` la copie, o
  quitarla.
- No he revisado la copia de `~/texmf/tex/latex/nacal-moodle-latex-package/Ejemplo/`.

**B3. Fuentes de `mathabx` declaradas a mano** (líneas 1559-1570). En
`CLAUDE.md` figuraba como problema, pero en realidad es la forma habitual de
tomar unos pocos símbolos de `mathabx` (`\ldbrack`, `\rdbrack`, `\bigtimes`)
sin cargar el paquete entero, que redefine muchos símbolos de `amssymb`. Se
mantiene. Dos matices:
- **Compatibilidad comprobada.** `nacal` + `mathalpha` y `nacal` + `mathtools`
  cargan bien en cualquier orden. `nacal` + `mathabx` falla en los dos
  órdenes: por `\widebar`, que definen los dos, y porque `mathabx` choca con
  `amssymb`, que nacal carga. Hoy afecta a poco: en `libroProbabilidad/libro.org`
  la carga de `mathabx` está comentada. `probabilidadCasoFinito/init.org` sí
  carga `mathabx`, pero junto a `./notacion/nacal`, una copia local que no
  existe en esa carpeta. Así que ese fichero no compila tal como está (su PDF
  es de abril de 2025).
- **Límite de familias matemáticas.** pdfLaTeX admite 16 familias de fuentes
  matemáticas, y nacal ocupa tres de forma fija: `esvect` (flechas de `\vv`),
  `matha` y `mathx`. *Sí ha pasado* (8/11/2026): en los apuntes de
  Econometría, LaTeX daba «Too many math alphabets used in version bold» e
  ignoraba algún `\mathsf`. Así, `\SVA{X}` salía en cursiva con remate en
  las páginas 141 y 145. Se arregló en el curso, quitando `wasysym`, que no se
  usaba. Si vuelve a pasar en otro documento, nacal podría bajar a dos
  familias tomando el ⟦ ⟧ pequeño de `mathx` en vez de `matha`. Es un cambio
  visible que habría que medir con el banco.

**B4. Nombres sin prefijo.** El paquete define nombres internos que otro
paquete podría usar: `\mymathbb`, `\MDaV`, `\perturbacion`. También define
comandos de usuario muy cortos o genéricos: `\N`, `\Z`, `\R`, `\K`, `\T`, `\E`,
`\TM`, `\abs`, `\Span`, `\dom`, `\var`, `\dt`, `\pr`, `\su`, `\per` o `\res`.
Gracias a `\NewDocumentCommand`, un choque no pasa inadvertido: da un error
claro al compilar. Renombrar los comandos de usuario rompería cientos de
documentos, así que no se propone. Sí conviene renombrar los internos, que
ningún documento usa (por ejemplo, `\mymathbb` → `\nacal@bb`). Hay que
comprobar antes que no aparezcan en ningún fichero.

**B5. `\it` obsoleto** en `\normal`, `\tstudent`, `\fsnedecor` (`{\it N\/}`) y
`\ValorC`. `\it` es un comando de LaTeX 2.09 que algunas clases (KOMA, por
ejemplo) ya rechazan o rechazarán. Sustituirlo por `\mathit{…}` da un
resultado idéntico: comprobado a 300 ppp, con 0 píxeles distintos.

**B6. `\xspace`: no cambiar nada.** En `CLAUDE.md` se suponía que estaba
*dentro* de `\ensuremath` y no servía para nada. No es así: está *después*
(`\ensuremath{…}\xspace`). Por eso puedes escribir `\Mat{A} es invertible`
fuera de `$…$` y conservar el espacio. Quitarlo rompería ese uso en todos los
documentos. Los `\xspace` de los macros anidados actúan en modo matemático,
donde no hacen nada, y son inofensivos. La documentación de `xspace` avisa de
casos raros (seguido de `\footnote` o de algunos comandos); no he visto
ninguno en el corpus.

**B7. `\MakeLowercase` en `\vect`, `\Vect`, `\eleVV`, `\eleMM`, etc.**
Compilado dentro de un `\section`: funciona, porque los comandos son robustos.
Sorprende al usuario (`\Vect{A}` da **a**), pero es tu convenio y se mantiene.
Solo conviene documentarlo bien.

**B8. `.gitignore`.** Ignora `makefile`, que es necesario para construir, y
no ignora `nacal.hd` ni los demás auxiliares de `hypdoc`. Propuesta: versionar
`makefile` (aunque se genere desde el `.org`, quien clone el repositorio lo
necesita) e ignorar `*.hd`.

## 3. Cambios de comportamiento (visibles): los decides tú

**C1. Espacios sobrantes en modo texto.**
- `\E`, `\Var`, `\Dt`, `\Cov`, `\Corr` y `\ESP` tienen un espacio antes de
  `\xspace` (`…} \xspace}`). Fuera de `$…$`, `\E{X}.` sale «E(X) .», con un
  espacio antes del punto.
- `\elemLR` y `\deffun` tienen un salto de línea sin `%` al principio de su
  definición, que se convierte en un espacio: en modo texto sale un espacio
  doble delante.

Comprobado compilando. Medido: el candidato B cambia **8 páginas del libro**
(70, 124, 157, 158, 167, 215, 264 y 271) y **ningún examen ni transparencia**.
En el libro, el cambio quita un espacio doble, por ejemplo antes de «α|A|β»
en la página 70. En el curso de Econometría hay unos 22 usos en modo texto,
por ejemplo `Lec13.tex:776` (`¿\E{\Estmd{\beta_3}}?`) y `Lec06.tex:419`. Allí
la corrección quita el espacio antes del signo de puntuación.
**Recomendación: corregir.** Es un error tipográfico y el cambio solo mejora
el resultado.

**C2. `\Ind` estropea los apuntes de Econometría** *(no se corrige en el
paquete)*. En el curso, `\Ind` era la letra del índice de observación (n o t):
se definía en `pre/0prescindible/notacionEctr.tex:19` y se cambia en
`Lec10`/`Lec11` con `\renewcommand{\Ind}{t}`. El commit `245e80d`
(2023-07-23, "Nuevos comandos para el libro de probabilidad") definió en
nacal `\Ind` como el vector 𝟙. Resultado: en `apuntes-Ectr-print.pdf`, página
75, la cabecera de la tabla de `Lec05.tex:2691` muestra «1» (el 𝟙) donde
debería decir «n». **Comprobado en el PDF.** Arreglo propuesto, en el curso y
no en el paquete: definir allí un macro propio para el índice, por ejemplo
`\idx`, y usarlo en lugar de `\Ind`. Hay que revisar todos los `$\Ind$` del
curso.

**C3. `\Media` y `\conj` se comportan como operadores.** `\widebar` está
definido como `\mathop{\overline{#1}}`. Por eso, en una fórmula destacada,
`\Media{X}_n` pone la n *debajo* de la barra y no como subíndice. Además
añade un espacio fino detrás: `\Media{X}w` sale «X̄ w». Comprobado compilando.
Uso: `\Media` aparece 206 veces en Econometría, y `\conj{…}_` 3 veces en
todo el corpus. Si lo corriges, cambia el espaciado en todos esos sitios. Hay
que medirlo con documentos de Econometría en el banco.

**C4. «esp» en cursiva matemática.** `\EOEsu`, `\EOEpr`, `\EOEg` y las
demás variantes «espejo» escriben `esp(…)` en modo matemático. TeX lo compone
como el producto e·s·p, en cursiva. Lo normal sería `\operatorname{esp}`,
recto y con el espaciado de operador. Uso: `\EOEg` aparece 39 veces en 6
ficheros. Cambio visible.

**C5. Paréntesis distintos con y sin asterisco.** *(Resuelto en la v1.4: ningún documento usa asterisco con opcional en esta familia, y las dos variantes se ven igual. Se unifica con `\Matp*`/`\MatTpE*`. Afecta también a `\VectTFpE` y `\VectTCpE`.)* En `\VectFpE` y `\VectCpE`
con opcional, la rama con asterisco usa `\MatP*` (`\left( \right)`) y la rama
sin asterisco `\Matp*` (paréntesis fijos). El resto de la familia es
coherente, así que probablemente sea una errata. Afecta solo al tamaño del
paréntesis interior cuando se pasa el opcional. Uso: `\VectFpE` aparece 382
veces y `\VectCpE` 816. Habría que medir cuántos llevan asterisco y opcional.

**C6. Texto en castellano fijo.** `\SupIV` y `\SupIVmas` escriben
`\textrm{ es invertible}` incluso con la opción `[eng]`. Debería ser
`\eng{ es invertible}{ is invertible}`. Cambio visible solo en documentos en
inglés.

**C7. `\minus` es `\hbox{-}`.** El −1 de las inversas lleva un guion de
tamaño de texto, no un signo menos de subíndice. Parece una elección estética
deliberada (un menos corto), así que no propongo cambiarlo. Solo lo anoto.

## 4. La parte de probabilidad y econometría

Información reunida del curso de Econometría (`Econometria-SRC/Version1`), de
los bancos `qbank-econometria` y `qbank-PEconometria`, del libro de
probabilidad (`Investigacion/libroProbabilidad`), de `probabilidadCasoFinito`
y del libro de Álgebra Lineal.

**Cuatro formas de escribir la esperanza:**

| Macro | Símbolo | Quién lo usa |
|---|---|---|
| `\E` | E recta (operador) | Econometría (527 usos), qbank-econometria |
| `\ECond` | 𝔼 de pizarra, en violeta | Econometría (176) |
| `\sesp`, `\ESP` | 𝕊 de pizarra | libro de probabilidad (105 + 221), probabilidadCasoFinito (≈1150) |
| `\sesp` redefinido | 𝔼 de pizarra | libro de Álgebra Lineal: `libro-P.tex:331` y unas 90 figuras (`figuras/tex`) |

A eso se suma `qbank-PEconometria`, que escribe `\mathrm{E}` a mano. La
decisión A3 del diccionario recomienda $E_\eta$, que no coincide con ninguna
de las cuatro. En la práctica, el valor por defecto de `\sesp` (𝕊) solo lo usan
los proyectos de probabilidad; el libro de Álgebra Lineal lo cambia siempre.

**Opcionales con significados distintos** (nota 3 de `diccionario.org`). En
`\sspi[S]` el opcional es una etiqueta; en `\ESP[\sspi]{u}`, `\PRO[\sspi]{u}`
y `\norma[\sspi]{u}` es el símbolo completo. El libro de probabilidad usa la
semántica de nacal (`\SPI[E]`, `\sspi[\R]`, `\ESP[\sspi[\R]]`).
`probabilidadCasoFinito` la redefine (`preambulo-comun.org:56-57`): un solo
opcional que es el subíndice completo. Hoy, el mismo `\SPI[…]` significa
cosas distintas en los dos proyectos.

**Otras divergencias:**
- `\PSpan`: Econometría (104 usos) y el libro (94) usan el de nacal;
  `probabilidadCasoFinito` lo redefine. `\PSpanNew` no lo usa nadie y no
  funciona (A5).
- `\Ind`: 𝟙 en nacal, índice n/t en Econometría (C2).
- `\TM`: N en nacal; Econometría lo cambia a T en algunas lecciones.
- `\ind{}` con argumento vacío: aparece en `nota3` (4284 usos, sobre todo en
  `probabilidadCasoFinito`). Añade un subíndice vacío, unos 0,5 pt más
  ancho que `\Ind`.
- Macros del libro de probabilidad que podrían ir al paquete: `\ESEF`,
  `\ESHF`, `\ESEP` y `\ESHP` (ternas de espacio), `\ET`, `\va` y las familias
  de sucesiones. `\norm` duplica a `\norma`.

**Propuesta de método** (no de notación, que os corresponde a Andrés y a
ti):
1. Cerrar primero A3 (esperanza) y la semántica de los opcionales. Lo demás
   depende de esas dos decisiones.
2. Implementar la notación nueva **sin cambiar los macros existentes**: o con
   nombres nuevos, o detrás de una opción (`\usepackage[probabilidad]{nacal}`)
   que redefina `\sesp`, `\sspi` y `\SPI` con la semántica nueva. Los
   documentos actuales (Econometría, exámenes, el libro) compilan igual sin
   tocar nada.
3. Que los preámbulos de los proyectos dejen de redefinir macros de nacal: lo
   que redefinen hoy es justo lo que el paquete debería ofrecer.
4. Antes de nada, añadir al banco unos documentos de Econometría y de los
   dos proyectos de probabilidad.

## 5. Plan propuesto

| Versión | Contenido | Efecto medido | Riesgo |
|---|---|---|---|
| **1.3.1** | A1-A4, A6, A8, B1, B4 (solo internos), B5, B8. A5 como aviso | ninguno (54/54 iguales) | muy bajo |
| **1.4** | C1, y C4-C6 si los apruebas | C1: 8 páginas del libro, 0 exámenes | bajo |
| **2.0** o `[probabilidad]` | sección 4, tras las decisiones A1-A7 | por medir | medio; aislado tras la opción |

Para cada versión:
1. Editar `NAcAL-Tex.org` (nunca el `.sty`).
2. Tanglear y ejecutar `make`.
3. Comparar el `.sty` generado con el candidato probado.
4. Pasar el banco.
5. Que tú lo pruebes en tu flujo real: exportación desde org, moodle (con
   `nacal-moodle`) y AMC.
6. Etiquetar la versión e instalarla en `~/texmf`.

Ampliaciones del banco recomendadas antes de la 1.4:
- El curso de Econometría (por C1, C3 y C2).
- Una salida AMC de `qbank-econometria`.
- `nota3` de `probabilidadCasoFinito`.
- Un vídeo.

## 6. Preguntas para ti

1. ¿Apruebas la 1.3.1 tal como está descrita (sin cambio visible)?
2. ¿Corrijo los espacios de C1 aunque cambien 8 páginas del libro?
3. C3 (`\Media` como operador): ¿la n debajo de la barra en las fórmulas
   destacadas es intencionada o un error?
4. C4: ¿«esp» debe ir recto (`\operatorname{esp}`)?
5. C5: en `\VectFpE*[k]{A}{i}`, ¿qué paréntesis querías?
6. C2: ¿arreglamos `\Ind` en los apuntes de Econometría (en el curso, no en el
   paquete)?
7. ¿Borramos la copia obsoleta de `libroProbabilidad/notacion/nacal.sty`?

## Anexo: otros hallazgos fuera del paquete

- `finals/Final-2010-jun.tex` no compila: busca
  `preguntas/Finales/2010-jun.tex`, pero existen `2010-jun-C.tex` y
  `2010-jun-L.tex`. Lo mismo pasa con `Final-2010-sep`.
- Hay dos copias antiguas del libro: `CursoAL-SRC` (revisada; se puede borrar
  tras rescatar 3 notebooks y las figuras «Biyecciones») y
  `CursoDeAlgebraLineal-SRC.viejo` (61 MB, sin revisar).
- `~/CloudStation` es un enlace a `~/SynologyDrive`: no hay copias
  duplicadas.
- El curso de Econometría (`Econometria-SRC`) no es un repositorio git.
