#!/usr/bin/env bash
# banco-manim.sh — prueba de regresión con las fórmulas de los vídeos.
#
# manim compila cada fórmula de un vídeo como un .tex mínimo (standalone con
# \usepackage{nacal}) y lo guarda en media/Tex. Este guion copia esos .tex,
# los compila con latex (DVI, como hace manim) usando un nacal.sty dado y
# compara los DVI byte a byte.
#
# Nunca escribe en los repositorios de los vídeos ni en ~/texmf: trabaja en
# $BANCO/manim.
#
# Uso:
#   banco-manim.sh instantanea         copia los .tex que cargan nacal a $BANCO/manim/fuentes
#   banco-manim.sh generar DIR NOMBRE  compila con DIR/nacal.sty; DVI en $BANCO/manim/NOMBRE
#   banco-manim.sh comparar A B        compara los DVI de A y de B
set -uo pipefail

BANCO=${BANCO:-$HOME/temporal/nacal-banco}
DOCENCIA=${DOCENCIA:-$HOME/SynologyDrive/ReposGH/Docencia}
JOBS=${JOBS:-4}
M=$BANCO/manim
# Carpetas media/Tex de los repositorios de vídeos (relativas a $DOCENCIA).
CARPETAS=${CARPETAS:-"VideosMates2/lib/media/Tex VideosMates2/media/Tex videoMath2/lib/media/Tex VideosMates2/tmp/media_bocetos/Tex"}

# Fecha fija: el DVI lleva la fecha de compilación en la cabecera.
export SOURCE_DATE_EPOCH=1767225600 FORCE_SOURCE_DATE=1

instantanea() {
    rm -rf "$M/fuentes"; mkdir -p "$M/fuentes"
    local c d n=0 f
    for c in $CARPETAS; do
        [ -d "$DOCENCIA/$c" ] || { echo "No existe $DOCENCIA/$c" >&2; continue; }
        d=$M/fuentes/${c//\//_}; mkdir -p "$d"
        for f in "$DOCENCIA/$c"/*.tex; do
            grep -q 'nacal' "$f" 2>/dev/null && { cp "$f" "$d/"; n=$((n+1)); }
        done
    done
    echo "Fórmulas copiadas el $(date '+%F %T'): $n" | tee "$M/fuentes/INSTANTANEA.txt"
}

# _una STYDIR SALIDA FICHERO: compila una fórmula y guarda su DVI.
_una() {
    local stydir=$1 salida=$2 f=$3
    local rel=${f#"$M/fuentes/"}; local id=${rel%.tex}; id=${id//\//__}
    local tmp; tmp=$(mktemp -d "$M/tmp/XXXXXX")
    cp "$f" "$tmp/x.tex"
    ( cd "$tmp" && TEXINPUTS="$stydir:" latex -interaction=batchmode x.tex >/dev/null 2>&1 )
    if [ -f "$tmp/x.dvi" ]; then cp "$tmp/x.dvi" "$salida/$id.dvi"
    else echo "SIN DVI $rel"; fi
    # Comprobar que se cargó el nacal.sty pedido.
    tr -d '\n' < "$tmp/x.log" 2>/dev/null | grep -q "$stydir/nacal\.sty" || echo "AVISO $rel: no consta $stydir/nacal.sty"
    rm -rf "$tmp"
}

generar() {
    local stydir; stydir=$(cd "$1" && pwd); local salida=$M/$2
    [ -f "$stydir/nacal.sty" ] || { echo "No hay nacal.sty en $stydir" >&2; exit 1; }
    [ -d "$M/fuentes" ] || { echo "Falta la instantánea: banco-manim.sh instantanea" >&2; exit 1; }
    rm -rf "$salida"; mkdir -p "$salida" "$M/tmp"
    echo "nacal.sty: $stydir ($(sha256sum "$stydir/nacal.sty" | cut -c1-16))" > "$salida/ORIGEN.txt"
    find "$M/fuentes" -name '*.tex' | sort \
        | xargs -P "$JOBS" -I{} "$0" _una "$stydir" "$salida" {} | sort > "$salida/INCIDENCIAS.txt"
    echo "$2: $(find "$salida" -name '*.dvi' | wc -l) DVI, $(grep -c . "$salida/INCIDENCIAS.txt") incidencias (ver $salida/INCIDENCIAS.txt)"
}

comparar() {
    local A=$M/$1 B=$M/$2 igual=0 dist=0 falta=0 f n
    for f in "$A"/*.dvi; do
        n=$(basename "$f")
        if [ ! -f "$B/$n" ]; then falta=$((falta+1)); echo "FALTA en $2: $n"
        elif cmp -s "$f" "$B/$n"; then igual=$((igual+1))
        else dist=$((dist+1)); echo "DISTINTO $n"; fi
    done
    local sobran; sobran=$(comm -13 <(cd "$A" && ls *.dvi | sort) <(cd "$B" && ls *.dvi | sort) | wc -l)
    echo "manim $1 frente a $2: iguales $igual, distintos $dist, faltan en $2 $falta, solo en $2 $sobran"
}

orden=${1:-ayuda}; shift || true
case $orden in
    instantanea) instantanea ;;
    generar)     generar "${1:?falta el directorio del nacal.sty}" "${2:?falta el nombre de la salida}" ;;
    comparar)    comparar "${1:?falta A}" "${2:?falta B}" ;;
    _una)        _una "$@" ;;
    *) sed -n '2,16p' "$0" ;;
esac
