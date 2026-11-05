# La notación de probabilidad y estadística en nacal

Informe para decidir, con Andrés, la notación de probabilidad y estadística de
nacal. 5 de noviembre de 2026. **No se ha cambiado nada de esta parte del
paquete.** El informe dice qué hay hoy, a qué documentos afectaría cada
cambio y qué propongo.

Cifras: usos de cada macro en ficheros `.tex`, `.org`, `.py` y `.json`. No
cuento las copias de `nacal.sty`/`.dtx`, `CursoAL-SRC`, los `.viejo` ni los
`build/` generados de los qbanks.

## Resumen

- **Los exámenes que estás poniendo ahora no corren riesgo.**
  - Los AMC (`PEctr-Test-*`) y el banco `qbank-PEconometria` escriben
    `\mathrm{E}` a mano: no usan ningún macro de probabilidad de nacal.
  - Los vídeos tampoco usan ninguno.
  - Los exámenes de Matemáticas II apenas los usan.
- **Hay tres mundos con convenios distintos:**
  1. **Econometría** (apuntes y `qbank-econometria`): E recta para la
     esperanza (`\E`), 𝔼 violeta para la condicionada (`\ECond`),
     variables aleatorias en violeta (`\VA`, `\MVA`…) y medias con barra
     (`\Media`). Es el mayor usuario de esta parte del paquete y la usa tal
     como está.
  2. **Los dos proyectos de probabilidad** (`libroProbabilidad` y
     `probabilidadCasoFinito`): 𝕊 para la esperanza (`\sesp`, `\ESP`),
     semiproductos `\sspi`/`\SPI`, `\PSpan`, `\ind`, sucesiones. Son los que
     más redefinen y más macros propios añaden.
  3. **Álgebra Lineal y Matemáticas II**: usan los macros de los proyectos de
     probabilidad (`\ESP`, `\sspi`, `\PRO`, `\ind`) en los capítulos de
     probabilidad, pero **redefinen `\sesp` como 𝔼** en 67 ficheros.
- **Lo que está a medio diseñar** es lo que comparten los mundos 2 y 3: el
  símbolo de la esperanza, el significado de los opcionales y `\PSpan`. La
  econometría casi no lo toca.

## 1. Quién usa qué

Usos por proyecto. En los dos proyectos de probabilidad, sin duplicados (sin `basura/` ni los `.tex` exportados). En los demás se cuentan también las líneas comentadas, así que las cifras son aproximadas.

| | Econometría (Version1) | qbank-econometria | libroProbabilidad | probabilidadCasoFinito | Álgebra Lineal | Matemáticas II |
|---|---|---|---|---|---|---|
| `\E`, `\Var`, `\Cov` (E recta) | 857, 171, 59 | 18, 26, 1 | 2 (con un `\E` propio) | 0 | 1, 5, 4 | 3, 1, 1 |
| `\ECond`, `\ECondYX` (𝔼 violeta) | 286, 168 | 8, 6 | 0 | 0 | 0 | 1 |
| `\sesp`, `\ESP` (𝕊) | 0, 2 | 0 | 142, 264 | 203, 510 | 104, 477 (como 𝔼) | 32, 23 (como 𝔼) |
| `\sspi`, `\SPI` | 96, 1 | 0 | 933, 382 | 1725, 328 | 972, 123 | 54, 12 |
| `\PRO` | 23 | 15 | 65 | 140 | 260 | 30 |
| `\PSpan` | 142 | 0 | 107 | 987 (redefinido) | 202 | 21 |
| `\ind` | 73 | 0 | 708 | 1870 (1743 son `\ind{}`) | 1978 | 150 |
| `\Ind` | 0 (ya quitado) | 0 | 10 | 171 | 0 | 2 |
| `\Media`, `\media` | 424, 428 | 12, 17 | 0 | 0 | 124, 65 | 38, 36 |
| `\VA`, `\MVA` (violeta) | 2291, 1263 | 137, 75 | 0 | 0 | 0 | 43, 0 |
| `\suc`, `\esuc` | 0, 1 | 0 | 493, 207 | 234, 35 | 0 | 0 |

**Documentos que redefinen macros de nacal** (cada uno es una señal de que
el paquete no da lo que hace falta):

- `\sesp` → 𝔼: 35 ficheros del libro de Álgebra Lineal (`libro-P.tex:331`,
  `libro.tex:331`, `book.tex:348`, 12 bloques de `figuras/Figuras.org` y 29
  figuras de `figuras/tex/`) y 32 de Matemáticas II (`Version0/figuras`).
- `\sspi`, `\SPI` y `\PSpan`: `probabilidadCasoFinito/preambulo-comun.org:56,
  57, 85`, y las mismas líneas en `nota3.org`, `kalman.org` y sus `.tex`.
- `\imrec`: `nota3.org:262`, `kalman.org:262`, `nota.org:252` y
  `nota2.org:253`.
- `\Ind` como `\mathbbmsl{1}`: definido en `probabilidadCasoFinito/init.org:197`
  y comentado en otros ocho ficheros.
- `libroProbabilidad/simbolos.tex:28-46` define sus propios `\E`, `\Var`,
  `\Cov` y `\Corr`. Este último escribe «corr», en minúscula, frente a «Corr»
  en nacal.

**Macros sin ningún uso en ningún proyecto** (36): `\Cero`, `\pindep`,
`\Svar`, `\SvarM`, la mayoría de las variantes con paréntesis de `\dt`, `\var`,
`\cvarM`, `\cov` y `\corr` (`\dtp`, `\varP`, `\covMP`…), `\MVAp`, `\MVAP`,
`\MVATP`, `\MVATpE`, `\MVATPE`, `\MVAKK`, `\VVAKK` y varias de estimadores
(`\EstmcCorr`, `\EstmdCorr`, `\EstmcCovCond`, `\EstmcECond`…). No propongo
quitarlos. Casi todos son miembros de familias regulares (`p`, `P`, `pE`…), y
`nacal-moodle` podría usarlos al generar preguntas nuevas.

## 2. Decisiones, una a una

Cada decisión indica qué hay hoy, a qué afecta, las opciones y mi propuesta.
Las numero con P para no confundirlas con las A1-A7 de `diccionario.org`.

### P1. El símbolo de la esperanza (es la A3 del diccionario)

**Hoy** hay cuatro, y cada uno tiene un dueño:

| símbolo | macro | quién |
|---|---|---|
| E recta | `\E` | Econometría |
| 𝔼 violeta | `\ECond` | Econometría, solo condicionada |
| 𝕊 | `\sesp`, `\ESP` | proyectos de probabilidad |
| 𝔼 | `\sesp` redefinido | Álgebra Lineal, Matemáticas II |

Además, los AMC y `qbank-PEconometria` escriben `\mathrm{E}` a mano.

**Lo que dice el diccionario (A3):** $E_\eta$, omitiendo el subíndice cuando
no haya ambigüedad. Coincide con lo que el alumno espera y con la E recta de
Econometría.

**Lo que observo:** 𝕊 (el valor actual de `\sesp`) solo lo usan los dos
proyectos de probabilidad. Ningún texto para alumnos lo usa: el libro de
Álgebra Lineal lo cambia siempre a 𝔼.

**Propuesta:**
1. **Separar el símbolo del macro.** Que todos los macros de esperanza de la
   familia `\sesp`/`\ESP` tomen la letra de un único sitio, configurable
   desde el preámbulo, por ejemplo `\nacalSimboloEsperanza{\mathbb{E}}`. El
   valor por defecto sería 𝕊, para que ningún documento cambie.
2. Así, los 67 ficheros que redefinen `\sesp` podrían cambiar la
   redefinición por una línea de configuración. No es obligatorio: la
   redefinición seguiría funcionando.
3. Andrés y tú elegís la letra de los textos nuevos (E, 𝔼 o 𝕊) sin tocar el
   paquete.
4. **No** unificaría `\E` de Econometría con `\ESP`. Son dos familias con
   argumentos distintos y la econometría está bien como está. Lo que conviene
   es que el **aspecto** coincida si así lo decidís: si elegís E recta, `\ESP`
   y `\E` se verían igual.

**Afecta a:** nada, mientras no se cambie el valor por defecto.

### P2. Qué significa el argumento opcional (nota 3 del diccionario)

**Hoy:** en `\sspi[S]` el opcional es una etiqueta (sale η con subíndice S).
En `\ESP[\sspi]{u}`, `\PRO[\sspi]{u}` y `\norma[\sspi]{u}` el opcional es el
símbolo completo. Eso obliga a escribir `\ESP[\sspi[S]]{u}`.
`probabilidadCasoFinito` ha redefinido `\sspi` y `\SPI` con un tercer
criterio: un solo opcional, que es el subíndice completo. Hoy el mismo
`\SPI[…]` significa cosas distintas según el proyecto.

**Afecta a:**
- `\sspi` y `\SPI`: unos 2700 usos en libroProbabilidad, 2050 en
  casoFinito, 1100 en Álgebra Lineal y 66 en Matemáticas II.
- `\ESP`, `\PRO` y `\norma` (estos últimos con opcional): menos usos, pero
  en los mismos proyectos.

**Opciones:**
- **(a) Dejarlo como está** y documentar las dos semánticas. Coste cero; la
  inconsistencia sigue.
- **(b) Semántica nueva con nombres nuevos.** Por ejemplo `\esp[S]{u}`,
  `\pr[S]{u}` y `\sp[S]{u}{v}`, todos con la etiqueta como opcional y la η
  añadida por el macro. Los nombres antiguos se quedan como están. Nada
  cambia; los textos nuevos usan los nombres nuevos.
- **(c) Semántica nueva tras una opción**, `\usepackage[probabilidad]{nacal}`,
  que redefine `\sspi`, `\SPI`, `\ESP` y `\PRO` con la semántica nueva. Solo
  la usarían los textos nuevos. Riesgo: el mismo macro significa cosas
  distintas según la opción, lo que confunde al copiar fragmentos de un
  documento a otro.

**Propuesta: (b).** Es la que garantiza que nada antiguo cambie y la única
en la que, al leer el fuente, se sabe qué semántica se está usando. El
diccionario ya advierte que solo compensa si se hace **antes** de escribir
los textos nuevos. Si se elige, hay que hacerlo pronto.

### P3. `\PSpan` (envolvente probabilizable)

**Hoy:** la versión de nacal la usan Econometría (142), el libro de
probabilidad (107), Álgebra Lineal (202) y Matemáticas II (21).
`probabilidadCasoFinito` la redefine (987 usos) con un dibujo distinto,
basado en `stackengine` (`preambulo-comun.org:80-85`). `\PSpanNew` ya no
existe: la quité en la 1.3.1 porque no funcionaba.

**Propuesta:** si el dibujo de casoFinito es el que preferís, incorporarlo
a nacal **con un nombre nuevo** (por ejemplo `\PSpanS`) y que el preámbulo
de casoFinito deje de redefinir. Cambiar el aspecto de `\PSpan` modificaría
Econometría y el libro.

### P4. `\Ind`, `\ind{}` y la función indicadora

**Hoy:** `\Ind` es 𝟙 en nacal. En Econometría ya no queda ningún `\Ind`
activo (los he quitado hoy; ver la sección 4). `\ind{}`, con argumento vacío,
aparece 1743 veces en casoFinito (139 líneas en `nota3.org`). Produce 𝟙 con
un subíndice vacío, unos 0,5 pt más ancho que `\Ind`. El diccionario (nota 4)
ya recomienda `\Ind`.

**Propuesta:** en los textos nuevos, `\Ind`. En los antiguos, sustituir
`\ind{}` por `\Ind` solo si se quiere ese medio punto; es un cambio mecánico
en los documentos, no en el paquete. También se puede dejar `\ind{}`.

### P5. `\Media` se comporta como operador (C3 del informe de auditoría)

**Hoy:** `\widebar` es `\mathop{\overline{…}}`. Por eso, en fórmulas
destacadas, `\Media{X}_n` pone la n *debajo* de la barra, y añade un espacio
fino detrás. Afecta a Econometría (424 usos), Álgebra Lineal (124),
Matemáticas II (38) y `qbank-econometria` (12).

**Propuesta:** antes de decidir, añadir Econometría al banco y medir. Si la n
debajo no es intencionada, la corrección cambiaría el espaciado en esos
documentos, así que habría que aprobarla mirando las páginas afectadas.

### P6. «esp» en cursiva matemática (C4 del informe de auditoría)

`\EOEg` y sus variantes «espejo» escriben esp(…) como e·s·p en cursiva.
Tiene 39 usos en 6 ficheros. Lo normal sería `\operatorname{esp}`. Es un
cambio visible pequeño; necesito tu decisión.

### P7. Macros propios de los proyectos que podrían ir a nacal

Del libro de probabilidad y de casoFinito:
- **Espacios de esperanza**: `\ET` (623 usos), `\ESEF`, `\ESHF`, `\ESEP`,
  `\ESHP`, `\CET`…
- **Sucesiones**: unas 20 variantes (`\Asuc`, `\lsuc`, `\csuc`,
  `\sucTrad`…).
- **Seminormas y Daniell**: `\ssn`, `\sn`, `\dsn`, `\indi`…
- **Probabilidad finita**: `\ppp` (1131), `\ex` (868), `\cl` (695), `\vvv`
  (201), `\hada`, `\ceroesp`…
- `\norm` duplica a `\norma` de nacal.

**Propuesta:** de momento, **nada**. Esos macros cambiarán mientras se
escriben los textos A y B. Cuando la notación de casoFinito esté cerrada,
llevar a nacal los que también usen los otros proyectos, con nombres que no
choquen. Lo que solo usa un proyecto debe quedarse en el preámbulo de ese
proyecto.

### P8. Detalles menores

- `\Corr` escribe «Corr» y `libroProbabilidad/simbolos.tex` escribe «corr».
  Decidir uno.
- `probabilidadCasoFinito/init.org` carga `mathabx` y una copia local
  `./notacion/nacal` que no existe, así que no compila. Si es un fichero
  vivo, hay que arreglarlo. nacal y `mathabx` no pueden cargarse juntos.

## 3. Cómo se haría, sin romper nada

1. **Antes de nada, ampliar el banco de pruebas** con: unos apuntes de
   Econometría, una salida de `qbank-econometria` (moodle y AMC), `nota3`
   de casoFinito, un capítulo del libro de probabilidad y un banco generado
   con `nacal-moodle`. Hoy el banco solo tiene el libro de Álgebra Lineal,
   las transparencias y los exámenes de Matemáticas II.
2. Lo nuevo va con **nombres nuevos** (P2, P3) o detrás de un **ajuste de
   preámbulo** cuyo valor por defecto no cambia nada (P1).
3. Si algún macro se retira, primero da un aviso (`\PackageWarning`) durante
   al menos un curso.
4. Los preámbulos de los proyectos dejan de redefinir macros de nacal a
   medida que el paquete ofrezca lo que necesitan.

## 4. Lo hecho hoy en Econometría

Has pedido quitar `\Ind` de los apuntes de Econometría (`Econometria-SRC/Version1`).
Esa carpeta no está en git, así que antes guardé copia de los ficheros
tocados en `~/temporal/Econometria-copia-2026-11-05/`.
- `Lec05.tex:2691`: la cabecera de la tabla pasa de `$\Ind$` a `$n$`. Es lo
  que corrige el «1» de la página 75 de `apuntes-Ectr-print.pdf`.
- `Lec10.tex`: había `\renewcommand{\Ind}{t}` seguido de `w_\Ind` y
  `\cdot\Ind`. Ahora se escribe `t` directamente, así que el resultado es el
  mismo. He borrado las siete redefiniciones de `\Ind` de esa lección (las de `\TM` siguen).
- `Lec11.tex:176`: borrada una redefinición de `\Ind` que no se usaba.
- Los `\Ind` que quedan están todos en comentarios.

Hay que recompilar los apuntes para que el PDF refleje el cambio. No lo he
hecho porque esa cadena no está en el banco.

## 5. Preguntas para Andrés y para ti

1. P1: ¿qué letra para la esperanza en los textos nuevos? ¿Os parece bien
   el ajuste de preámbulo?
2. P2: ¿semántica nueva con nombres nuevos (mi propuesta), opción de
   paquete, o dejarlo?
3. P3: ¿qué dibujo de `\PSpan` preferís?
4. P5: ¿la n debajo de la barra en `\Media{X}_n` es intencionada?
5. P6: ¿«esp» recto?
