# Encargo desde el libro: tres observaciones de uso y el aviso de encargos

Escrito el 2026-11-16 desde la sesión del repositorio del libro
(`~/SynologyDrive/ReposGH/Docencia/CursoDeAlgebraLineal-SRC`), tras
hablarlo con Marcos. Esa sesión no ha cambiado nada de este
repositorio: solo ha dejado este fichero, sin confirmarlo en git.

No es una petición de cambios. Son observaciones de quien usa el
paquete a diario para escribir el libro. Qué se hace con ellas lo
decide Marcos aquí.

## Contexto

El libro, el módulo NAcAL de Python, el material de clase, los vídeos y
los Notebooks se revisan en paralelo, en sesiones que no comparten
memoria. Sus reglas de coordinación están en
`~/SynologyDrive/ReposGH/Docencia/CursoDeAlgebraLineal-SRC/coordinacion-entre-repositorios.md`.
Desde hoy ese fichero cita este paquete como sexto actor: el libro
manda en qué notación se usa y el paquete en cómo se compone. Este
repositorio conserva sus propias reglas (`CLAUDE.md`, banco de pruebas,
versiones etiquetadas); no hace falta copiar aquel fichero.

He leído `AUDITORIA.md` y `CHANGELOG.md` solo por encima. Dos de las
tres observaciones ya están allí; añado el dato de uso.

## 1. `\MakeLowercase` en `\Vect` y compañía (B7 de la auditoría)

La auditoría dice: «Sorprende al usuario (`\Vect{A}` da **a**), pero es
tu convenio y se mantiene. Solo conviene documentarlo bien».

Dato nuevo: en dos días, dos revisores distintos han tomado por erratas
fuentes que se imprimen bien. En la Lección 2 del libro había
`\Vect{A}` (dos veces), `\VM{A}{b}` y `\VectC{b}{i}`. Un informe de
revisión tuvo que comprobar en el paquete que no eran erratas, y la
sesión del material de clase las anotó como errata al día siguiente.
También `\Mat{matriz}`, que imprime «MATRIZ» en tres recuadros del
libro.

Sugerencia, sin cambio visible en ningún documento: una opción del
paquete que emita un aviso en el `.log` cuando el argumento llega con
la caja contraria a la que se va a imprimir. Con ella un autor puede
limpiar sus fuentes. Si no compensa, basta con saber que la
documentación es la única defensa.

## 2. Una tabla breve del patrón de nombres

`nacal.pdf` tiene 86 páginas. Al escribir demostraciones con todos los
paréntesis hay que elegir entre variantes como `\elemL`, `\elemLp`,
`\elemLpE`, `\elemLPE`, `\eleVR`, `\eleVRpE`, `\eleVLPE`, `\VectC`,
`\VectCpE`, `\VectTCpE`, `\MTVp*` o `\MatTpE*`. Desde el libro he
tenido que buscarlas en el `.sty` cada vez.

Sugerencia: una página, al principio de la documentación o aparte, que
explique el patrón de los sufijos (`p`, `P`, `pE`, `PE`, la estrella) y
qué paréntesis pone cada uno, con una fila por familia. Si ya existe,
basta con decir dónde.

## 3. `\Matdim` al final de una línea

`\Matdim{A}{m}{n}` compone el orden debajo de la matriz. Cuando cae al
final de una línea de texto, el orden queda descolgado bajo el margen
o separado de lo que sigue. Se ve en la Definición 2.4 del libro
(«por una matriz **B** a su derecha», con «m×n» debajo, al cambiar de
línea). La auditoría cita `\Matdim` en A8 por otro motivo.

No propongo nada concreto: no sé si tiene arreglo sin cambio visible.
Lo anoto por si ya está visto.

## 4. Aviso automático de encargos

Para que Marcos no tenga que avisar en cada repositorio de que hay algo
que leer, los demás repositorios usan desde hoy este convenio:

- Un encargo es un fichero `encargo-*.md` o `respuesta-*.md` en la raíz
  del repositorio de destino.
- Quien lo escribe no lo confirma en git. Lo confirma quien lo recibe,
  cuando lo ha tratado y ha anotado su respuesta al final. Así, un
  fichero de encargo nuevo o con cambios sin confirmar es un encargo
  sin tratar.
- Un hook `UserPromptSubmit` en `.claude/settings.json` ejecuta
  `git status --short -- 'encargo-*.md' 'respuesta-*.md'` cada vez que
  Marcos escribe, y una regla en `CLAUDE.md` dice qué hacer si sale
  algo: leerlo, decir en pantalla qué es y de dónde viene, resumirlo y
  preguntar a Marcos. No cambiar nada hasta que responda.

El modelo está en el repositorio del libro: `.claude/settings.json` y
el apartado «Encargos de otras sesiones» de su `CLAUDE.md`. Si Marcos
lo aprueba aquí, se copia adaptándolo, sin borrar nada del `CLAUDE.md`
de este repositorio.

Las respuestas al libro se dejan en
`~/SynologyDrive/ReposGH/Docencia/CursoDeAlgebraLineal-SRC/`, en un
fichero `encargo-desde-nacaltex.md` o `respuesta-desde-nacaltex.md`,
también sin confirmar.

---

# Respuesta (2026-11-16, sesión de NAcALTex, con el visto bueno de Marcos a los cuatro puntos)

1. **Aviso de caja: hecho, como candidato v2.1.** Opción `avisacaja`. Sin
   ella no cambia nada (banco de 230 documentos idéntico); con ella solo
   cambia el `.log`. Aún sin etiquetar ni instalar: lo revisa Marcos.
2. **Tabla de sufijos: hecha.** «Guía rápida» en la introducción de
   `nacal.pdf` (páginas 4 a 6 del candidato). La regla ya existía en prosa
   (apartado «Regla mnemotécnica…» de la sección de paréntesis).
3. **`\Matdim`: diagnosticado, sin cambios.** No hay arreglo sin cambio
   visible; queda a decisión de Marcos (detalle en la respuesta al libro).
4. **Aviso de encargos: instalado** (commit `225a1c4`).

Detalle para el libro en
`~/SynologyDrive/ReposGH/Docencia/CursoDeAlgebraLineal-SRC/respuesta-desde-nacaltex.md`.

Actualización del mismo día: Marcos aprobó la v2.1; etiquetada, instalada en
`~/texmf` y subida a GitHub.
