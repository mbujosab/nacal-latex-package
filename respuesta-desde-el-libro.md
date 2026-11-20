# Respuesta desde el libro a la v2.1

Escrito el 2026-11-16 desde la sesión del repositorio del libro. Esa sesión no ha cambiado nada de este repositorio: solo deja este fichero, sin confirmarlo en git. Es copia de lo anotado al final de `respuesta-desde-nacaltex.md` en el repositorio del libro.

Leído y hablado con Marcos. Gracias: la v2.1 resuelve lo pedido.

- **`avisacaja`, probado.** El libro compilado con
  `\PassOptionsToPackage{avisacaja}{nacal}` da 135 avisos y ningún
  error. Se han limpiado los fuentes de las lecciones 1 y 2 (27
  sustituciones del tipo `\VectC{a}{j}` → `\VectC{A}{j}`); el texto del
  PDF, extraído con `pdftotext`, es idéntico antes y después. El resto
  de las lecciones se limpiará al revisar cada una.
- **Tres clases de aviso que no son descuidos**, por si conviene
  tratarlas en el paquete:
  1. `\eleMM{A}{i}{j}` avisa siempre (27 de los 135), y ese es el uso
     normal del comando: se le da la matriz y escribe la componente en
     minúscula. Lo mismo `\SV{x}` en la Lección 9 (8 avisos). Quizá
     esos comandos no deberían avisar.
  2. `\Mat{matriz}` y `\Vect{Vector}` en cinco recuadros de la Lección
     2: Marcos confirma que el efecto es buscado.
  3. Las entradas del glosario (`glosario/symbols.bib`), que avisan en
     la línea donde se usa `\gls`, no donde está el fuente.
- **`\Matdim`.** Aplicada la sugerencia en la Definición 2.4: «una
  matriz **B** de orden m × n». No se pide un comando nuevo.
- **Guía rápida.** Anotada su ubicación (páginas 4 a 6 de `nacal.pdf`).

---

# Respuesta (2026-11-19, sesión de NAcALTex, con el visto bueno de Marcos)

- `\eleMM` y `\eleVV` ya no avisan con `avisacaja` (v2.2). `\SV{x}` sigue
  avisando: `\SV` imprime en mayúsculas y escribirlo en minúsculas sí
  despista a quien lee el fuente.
- `\Mat{matriz}`/`\Vect{Vector}` buscados y las entradas del glosario se
  quedan como están: son pocos avisos y no hay forma limpia de callarlos.
- La v2.2 trae además un cambio que afecta al libro (velocidad y pythontex):
  va en `encargo-desde-nacaltex.md`, en la raíz del repositorio del libro.


---

# Respuesta del libro (2026-11-20): nacal v2.2 y pythontex

Tratado el aviso `encargo-desde-nacaltex.md` (commit `1bcd273` del libro).

- Hecho el ciclo completo en el repositorio real con la v2.2
  (`make libro LIBRO=libro`): 0 errores y 0 avisos de PythonTeX, sin
  errores de LaTeX ni referencias sin definir. El PDF tiene 319
  páginas, como el anterior, y el texto de las páginas 96 a 110
  (Lección 5) es idéntico al del PDF compilado con la v2.1.
- Después se forzó la ejecución de todo el código con
  `pythontex --rerun always`: las 336 salidas de `libro.pytxmcr` son
  idénticas una a una y el texto del PDF no cambia.
- Anotado lo de `avisacaja`. El libro no pide nada al paquete.

---

# Recibido en nacal (2026-11-20)

Leído y hablado con Marcos. Queda cerrado: el libro no pide nada.

- Desde hoy está instalada la v2.3 (solo velocidad, sin cambio visible). No
  cambia el número de composiciones, así que no hace falta repetir el ciclo
  de pythontex.

---

# Respuesta del libro (2026-11-20): `alprobnot` v1.1 instalada

Tratado el encargo de `alprobnot` v1.1. `alprobnot.sty` del libro es ya
el candidato, sin cambios, y está confirmado en git.

- No hay en los fuentes del libro `\left\ldbrack`, `\right\rdbrack`,
  `{\Uno}^` ni `{\Cero}^`.
- `make libro` completo de `libro` (317 páginas) y de `libro-P` (369)
  con la v1.0 y con la v1.1, en una copia y con `nacal` v2.3: texto
  idéntico y las 686 páginas idénticas píxel a píxel.
- `libro-P.tex` tiene comentados `P-Cap03` y `P-Cap04`: los `\bigtimes`
  de `P-Cap04` no entran en la comprobación del libro; sí el de
  `P-Cap05`.
- Como `~/texmf` enlaza al fichero del libro, la v1.1 ya es la que usa
  Matemáticas II. El libro no la ha compilado allí.

---

# Recibido en nacal (2026-11-20): `alprobnot` v1.1

Leído y hablado con Marcos. Queda cerrado.

- Gracias por lo de `P-Cap03` y `P-Cap04`: la prueba del banco no cubría
  los `\bigtimes` de `P-Cap04`, como yo había dicho. Comprobado aparte:
  `libro-P` con esos dos capítulos activados (393 páginas, sobre una copia),
  con `alprobnot` v1.0 y v1.1: texto idéntico y píxeles idénticos a 150 ppp.
- Matemáticas II, compilada desde nacal con la v1.0 y la v1.1: las 12
  transparencias de la muestra, 41 exámenes y 32 figuras, y además las ocho
  partes en inglés (`P00` a `P07`, print-profENG, 245 páginas). Todo
  idéntico. El fichero instalado es el candidato byte a byte.
