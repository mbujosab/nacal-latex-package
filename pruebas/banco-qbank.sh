#!/usr/bin/env bash
# banco-qbank.sh — prueba de regresión de los bancos de preguntas
# (qbank-econometria y qbank-PEconometria): XML de Moodle y PDF de AMC.
#
# Trabaja sobre una copia del repositorio en $BANCO/qbank/REPO/NOMBRE (sin
# .git ni build/); nunca escribe en el repositorio original ni en ~/texmf.
#
# Uso:
#   banco-qbank.sh generar REPO RUTAS NOMBRE [objetivos de make...]
#       REPO    qbank-econometria | qbank-PEconometria (carpeta de $DOCENCIA),
#               o una ruta absoluta a una copia modificada del repositorio
#       RUTAS   carpetas con los .sty que se quieren probar, separadas por «:»
#               (se anteponen en TEXINPUTS; lo demás sale de ~/texmf)
#       NOMBRE  etiqueta del resultado (p. ej. ref-v16, candidato)
#   banco-qbank.sh comparar REPO A B
#       compara los resultados A y B: .tex generados y XML byte a byte;
#       PDF por texto (pdftotext) y por píxeles.
set -uo pipefail

BANCO=${BANCO:-$HOME/temporal/nacal-banco}
DOCENCIA=${DOCENCIA:-$HOME/SynologyDrive/ReposGH/Docencia}
RES=${RES:-100}
export SOURCE_DATE_EPOCH=1767225600 FORCE_SOURCE_DATE=1

nombre_repo() { basename "$1"; }

generar() {
    local repo=$1 rutas=$2 nombre=$3; shift 3
    local origen=$repo; [ -d "$origen" ] || origen=$DOCENCIA/$repo
    [ -d "$origen" ] || { echo "No existe $origen" >&2; exit 1; }
    local dest; dest=$BANCO/qbank/$(nombre_repo "$repo")/$nombre
    rm -rf "$dest"; mkdir -p "$dest"
    rsync -a --exclude .git --exclude build --exclude __pycache__ "$origen/" "$dest/"
    # rutas absolutas
    local abs="" r
    IFS=: read -ra partes <<< "$rutas"
    for r in "${partes[@]}"; do [ -n "$r" ] && abs+="$(cd "$r" && pwd):"; done
    echo "origen: $origen" > "$dest/ORIGEN.txt"
    echo "TEXINPUTS: $abs" >> "$dest/ORIGEN.txt"
    ( cd "$dest" && TEXINPUTS="$abs" make "${@:-all}" ) > "$dest/make.log" 2>&1
    echo "make terminó con código $?" | tee -a "$dest/ORIGEN.txt"
    # qué nacal*.sty se usaron de verdad
    cat "$dest"/build/*/*.log 2>/dev/null | tr -d '\n' | grep -oE "[^( ]*(nacal|ectrnot|alprobnot)[a-z-]*\.sty" | sort | uniq -c | tee -a "$dest/ORIGEN.txt"
    for t in tex xml pdf; do echo "$t: $(find "$dest/build" -name "*.$t" | wc -l)"; done | tee -a "$dest/ORIGEN.txt"
}

comparar() {
    local repo; repo=$(nombre_repo "$1"); local A=$BANCO/qbank/$repo/$2/build B=$BANCO/qbank/$repo/$3/build
    local inf=$BANCO/qbank/$repo/informe-$2-$3; rm -rf "$inf"; mkdir -p "$inf"
    local igual=0 dist=0 falta=0 f rel
    while read -r f; do
        rel=${f#"$A"/}
        if [ ! -f "$B/$rel" ]; then echo "FALTA en $3: $rel"; falta=$((falta+1)); continue; fi
        case $rel in
            *.tex|*.xml)
                if cmp -s "$f" "$B/$rel"; then igual=$((igual+1))
                else dist=$((dist+1)); echo "DISTINTO $rel"; diff "$f" "$B/$rel" > "$inf/${rel//\//_}.diff"; fi ;;
            *.pdf)
                if cmp -s "$f" "$B/$rel"; then igual=$((igual+1)); continue; fi
                local ta tb; ta=$(pdftotext -layout "$f" - 2>/dev/null | md5sum); tb=$(pdftotext -layout "$B/$rel" - 2>/dev/null | md5sum)
                local pa pb; pa=$(pdftoppm -r "$RES" -png "$f" | md5sum); pb=$(pdftoppm -r "$RES" -png "$B/$rel" | md5sum)
                if [ "$ta" = "$tb" ] && [ "$pa" = "$pb" ]; then igual=$((igual+1))
                else dist=$((dist+1)); echo "DISTINTO $rel (texto: $([ "$ta" = "$tb" ] && echo igual || echo distinto); píxeles: $([ "$pa" = "$pb" ] && echo iguales || echo distintos))"; fi ;;
        esac
    done < <(find "$A" -type f \( -name '*.tex' -o -name '*.xml' -o -name '*.pdf' \) | sort)
    local sobran; sobran=$(comm -13 <(cd "$A" && find . -type f \( -name '*.tex' -o -name '*.xml' -o -name '*.pdf' \) | sort) \
                                   <(cd "$B" && find . -type f \( -name '*.tex' -o -name '*.xml' -o -name '*.pdf' \) | sort) | wc -l)
    echo "$repo $2 frente a $3: iguales $igual, distintos $dist, faltan en $3 $falta, solo en $3 $sobran" | tee "$inf/RESUMEN.txt"
}

orden=${1:-ayuda}; shift || true
case $orden in
    generar)  generar "$@" ;;
    comparar) comparar "$@" ;;
    *) sed -n '2,18p' "$0" ;;
esac
