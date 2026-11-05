# Registro de cambios de nacal

Cada versión tiene una etiqueta git con el mismo nombre (`v1.3.1`, `v1.4`…).
En `~/texmf` solo se instalan versiones etiquetadas.

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
