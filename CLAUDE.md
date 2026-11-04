# nacal.sty — contexto y encargo de auditoría para Claude

Fichero escrito el 10 de octubre de 2026, al final de una conversación con
Marcos sobre otro proyecto (probabilidad en el caso finito, carpeta
`~/SynologyDrive/ReposGH/AndresyMarcos/probabilidadCasoFinito`). Marcos pidió
una auditoría del paquete y que el tema se tratara en una conversación
aparte, en esta carpeta. Léelo entero antes de tocar nada.

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
