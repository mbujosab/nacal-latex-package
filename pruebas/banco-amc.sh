#!/usr/bin/env bash
# banco-amc.sh — prueba de regresión con exámenes de AMC (auto-multiple-choice).
#
# Los exámenes PEctr-Test-* se compilan con lualatex, un motor que el banco
# principal (banco.sh) no cubre. Este guion copia las fuentes de unos cuantos
# exámenes, las compila con un nacal.sty dado y compara los PDF (texto y
# píxeles).
#
# Nunca escribe en las carpetas de los exámenes ni en ~/texmf: trabaja en
# $BANCO/amc. De cada examen solo copia las fuentes: no copia escaneos,
# notas ni datos de alumnos (scans, cr, data, exports, anonymous, printouts).
#
# Uso:
#   banco-amc.sh instantanea [EXAMEN...]  copia las fuentes a $BANCO/amc/fuentes
#                                         (sin argumentos: los $N más recientes)
#   banco-amc.sh generar DIR NOMBRE       compila con DIR/nacal.sty -> $BANCO/amc/NOMBRE
#   banco-amc.sh comparar A B             compara los PDF de A y de B
#
# AMC compila con «lualatex --shell-escape»; aquí se compila sin
# --shell-escape (los exámenes no lo necesitan: comprobado el 20/11/2026).
# El número de copias es el del fuente, no el que fija AMC al imprimir.
set -uo pipefail

BANCO=${BANCO:-$HOME/temporal/nacal-banco}
PROYECTOS=${PROYECTOS:-$HOME/SynologyDrive/POM/proyectos}
PATRON=${PATRON:-PEctr-Test-*}
N=${N:-6}
JOBS=${JOBS:-2}
RES=${RES:-100}
M=$BANCO/amc

export SOURCE_DATE_EPOCH=1767225600 FORCE_SOURCE_DATE=1

instantanea() {
    local lista=("$@") e
    if [ ${#lista[@]} -eq 0 ]; then
        mapfile -t lista < <(cd "$PROYECTOS" && ls -d $PATRON 2>/dev/null | sort | tail -n "$N")
    fi
    [ ${#lista[@]} -gt 0 ] || { echo "No hay exámenes $PATRON en $PROYECTOS" >&2; exit 1; }
    mkdir -p "$M/fuentes"
    # Se vacía con find (y no con rm -rf sobre una variable).
    find "$M/fuentes" -mindepth 1 -delete
    for e in "${lista[@]}"; do
        [ -f "$PROYECTOS/$e/source.tex" ] || { echo "Sin source.tex: $e" >&2; continue; }
        rsync -a --exclude scans --exclude cr --exclude data --exclude exports \
              --exclude anonymous --exclude printouts --exclude '*.pdf' \
              --exclude 'amc-compiled*' --exclude '*.log' --exclude '*~' \
              "$PROYECTOS/$e/" "$M/fuentes/$e/"
        echo "copiado $e"
    done
    echo "Exámenes copiados el $(date '+%F %T')" > "$M/fuentes/INSTANTANEA.txt"
}

# _uno STYDIR SALIDA EXAMEN: compila un examen (dos pasadas) y guarda PDF y log.
_uno() {
    local stydir=$1 salida=$2 e=$3
    local tmp; tmp=$(mktemp -d "$M/tmp/XXXXXX")
    cp -a "$M/fuentes/$e/." "$tmp/"
    ( cd "$tmp" && for k in 1 2; do
          TEXINPUTS="$stydir:" lualatex -interaction=batchmode source.tex >/dev/null 2>&1
      done )
    local usado=no
    tr -d '\n' < "$tmp/source.log" 2>/dev/null | grep -q "$stydir/nacal\.sty" && usado=sí
    if [ -f "$tmp/source.pdf" ]; then
        cp "$tmp/source.pdf" "$salida/$e.pdf"; cp "$tmp/source.log" "$salida/$e.log"
        echo "$e  ok  ($(pdfinfo "$tmp/source.pdf" | awk '/^Pages:/{print $2}') págs., errores: $(grep -a -c '^!' "$tmp/source.log"), nacal.sty pedido: $usado)"
    else
        cp "$tmp/source.log" "$salida/$e.log" 2>/dev/null
        echo "$e  SIN PDF (ver $salida/$e.log)"
    fi
    find "$tmp" -mindepth 1 -delete; rmdir "$tmp"
}

generar() {
    local stydir; stydir=$(cd "$1" && pwd); local salida=$M/$2
    [ -f "$stydir/nacal.sty" ] || { echo "No hay nacal.sty en $stydir" >&2; exit 1; }
    [ -f "$M/fuentes/INSTANTANEA.txt" ] || { echo "Falta la instantánea: banco-amc.sh instantanea" >&2; exit 1; }
    mkdir -p "$salida" "$M/tmp"
    find "$salida" -mindepth 1 -delete
    echo "nacal.sty: $stydir ($(sha256sum "$stydir/nacal.sty" | cut -c1-16))" > "$salida/ORIGEN.txt"
    ( cd "$M/fuentes" && ls -d */ | tr -d / ) \
        | xargs -P "$JOBS" -I{} "$0" _uno "$stydir" "$salida" {} | sort | tee "$salida/RESUMEN.txt"
}

comparar() {
    local A=$M/$1 B=$M/$2 f n igual=0 dist=0
    for f in "$A"/*.pdf; do
        n=$(basename "$f" .pdf)
        if [ ! -f "$B/$n.pdf" ]; then echo "$n  FALTA en $2"; dist=$((dist+1)); continue; fi
        local ta tb pa pb
        ta=$(pdftotext -layout "$f" - | md5sum); tb=$(pdftotext -layout "$B/$n.pdf" - | md5sum)
        pa=$(pdftoppm -r "$RES" -png "$f" | md5sum); pb=$(pdftoppm -r "$RES" -png "$B/$n.pdf" | md5sum)
        if [ "$ta" = "$tb" ] && [ "$pa" = "$pb" ]; then igual=$((igual+1)); echo "$n  IGUAL"
        else dist=$((dist+1)); echo "$n  DISTINTO (texto: $([ "$ta" = "$tb" ] && echo igual || echo distinto); píxeles: $([ "$pa" = "$pb" ] && echo iguales || echo distintos))"; fi
    done
    echo "amc $1 frente a $2: iguales $igual, distintos $dist"
}

orden=${1:-ayuda}; shift || true
case $orden in
    instantanea) instantanea "$@" ;;
    generar)     generar "${1:?falta el directorio del nacal.sty}" "${2:?falta el nombre de la salida}" ;;
    comparar)    comparar "${1:?falta A}" "${2:?falta B}" ;;
    _uno)        _uno "$@" ;;
    *) sed -n '2,21p' "$0" ;;
esac
