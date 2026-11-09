#!/usr/bin/env bash
# banco.sh — banco de pruebas de regresión del paquete nacal
#
# Idea: compilar una muestra de documentos reales (libro, transparencias,
# exámenes) con el nacal.sty congelado y con un nacal.sty candidato, y
# comparar los PDF resultantes página a página (texto y píxeles).
#
# Nada de esto toca los repositorios originales ni ~/texmf: se trabaja sobre
# una instantánea de las fuentes en $BANCO, y el nacal.sty que se usa se elige
# anteponiendo su directorio en TEXINPUTS.
#
# Uso:
#   banco.sh instantanea          copia las fuentes de los repositorios a $BANCO/fuentes
#   banco.sh preparar [id...]     compilación completa (pythontex, bibtex, índices...)
#                                 con el .sty congelado; deja los auxiliares en $BANCO/trabajo
#   banco.sh dorado               una pasada final con el .sty congelado -> $BANCO/dorado
#   banco.sh candidato DIR        una pasada final con DIR/nacal.sty  -> $BANCO/candidato
#   banco.sh comparar [A B]       compara $BANCO/A con $BANCO/B (por defecto dorado candidato)
#   banco.sh lista                muestra los identificadores de la muestra
#   banco.sh instantanea_prob     copia solo Econometría y probabilidadCasoFinito
#
# La pasada final reutiliza los auxiliares de "preparar" (los mismos para el
# dorado y para el candidato), de modo que dos ejecuciones con el mismo .sty
# deben dar PDF idénticos píxel a píxel. Si el candidato cambia la paginación,
# aparecerá como diferencias: es justo lo que se quiere detectar.

set -uo pipefail

AQUI=$(cd "$(dirname "$0")" && pwd)
BANCO=${BANCO:-$HOME/temporal/nacal-banco}
MUESTRA=${MUESTRA:-$AQUI/muestra.txt}
DOCENCIA=${DOCENCIA:-$HOME/SynologyDrive/ReposGH/Docencia}
# Libro de probabilidad compartido con Andrés (carpeta sincronizada entre los
# dos NAS). Solo se lee: rsync hacia la instantánea, nunca al revés.
CASOFINITO=${CASOFINITO:-$HOME/repos/SynologyDrive/libroProbabilidad}
CONGELADO=${CONGELADO:-$BANCO/sty/congelado}
JOBS=${JOBS:-10}
RES=${RES:-100}            # resolución (ppp) para la comparación de píxeles

# Fecha fija: \today y las fechas del PDF no dependen del día en que se compila.
export SOURCE_DATE_EPOCH=1767225600   # 2026-01-01
export FORCE_SOURCE_DATE=1

FUENTES=$BANCO/fuentes
TRABAJO=$BANCO/trabajo

# ---------------------------------------------------------------------------
# Muestra

# Imprime "id tipo args..." para cada línea de la muestra.
muestra() {
    grep -v '^\s*#' "$MUESTRA" | grep -v '^\s*$' | while read -r tipo a b c d; do
        case $tipo in
            libro)  echo "libro_$a $tipo $a" ;;
            transp) echo "${a}_$b $tipo $a $b" ;;
            examen) local l=ES; [ "$b" = english ] && l=EN
                    echo "${a}_${l}_s${c}r${d} $tipo $a $b $c $d" ;;
            ectr)   echo "ectr_$a $tipo $a" ;;
            nota)   echo "nota_${a//\//_} $tipo $a" ;;
            *) echo "muestra: tipo desconocido '$tipo'" >&2 ;;
        esac
    done
}

linea_de() { muestra | awk -v id="$1" '$1==id'; }

# ---------------------------------------------------------------------------
# Instantánea de las fuentes

instantanea() {
    mkdir -p "$FUENTES" "$CONGELADO"
    [ -f "$CONGELADO/nacal.sty" ] || cp "$AQUI/../../nacal-congelado-v1.3-baseline/nacal.sty" "$CONGELADO/"
    rsync -a --delete --exclude .git \
          "$DOCENCIA/CursoDeAlgebraLineal-SRC/" "$FUENTES/libro/"
    rsync -aL --delete \
          "$DOCENCIA/MatematicasII-SRC/Version0/" "$FUENTES/transp/"
    rsync -aL --delete --exclude '/*.pdf' --exclude '*.zip' --exclude 'ParaHaydeeYDavid' \
          "$DOCENCIA/MatematicasII-SRC/Evaluacion/" "$FUENTES/evaluacion/"
    instantanea_prob
    {
        echo "Instantánea tomada el $(date '+%F %T')"
        for r in CursoDeAlgebraLineal-SRC MatematicasII-SRC; do
            echo "$r: $(git -C "$DOCENCIA/$r" log -1 --format='%h %ad %s' --date=short)"
            echo "   cambios sin commit: $(git -C "$DOCENCIA/$r" status --short | wc -l) ficheros"
        done
        echo "nacal.sty congelado: $(sha256sum "$CONGELADO/nacal.sty" | cut -c1-16)"
    } > "$FUENTES/INSTANTANEA.txt"
    cat "$FUENTES/INSTANTANEA.txt"
}

# Econometría (no es git) y probabilidadCasoFinito (no es git). Se puede
# tomar por separado, sin rehacer la del resto: banco.sh instantanea_prob
instantanea_prob() {
    mkdir -p "$FUENTES"
    rsync -aL --delete --exclude '/*.pdf' "$DOCENCIA/Econometria-SRC/Version1/" "$FUENTES/ectr/"
    rsync -a --delete --delete-excluded --exclude '*.pdf' --exclude '*.log' --exclude '*.zip' \
          "$CASOFINITO/" "$FUENTES/casofinito/"
    echo "Econometría y $CASOFINITO copiados el $(date '+%F %T')" >> "$FUENTES/INSTANTANEA.txt"
}

# ---------------------------------------------------------------------------
# Compilación de cada tipo de documento
#
# Cada tipo tiene dos funciones:
#   prep_<tipo> DIR args...   reproduce la compilación completa del makefile original
#   final_<tipo> DIR args...  una sola pasada; deja el PDF en DIR/salida.pdf

opt_examen() { echo "\\def\\sol{$2}\\def\\Ref{$3}\\def\\lang{$1}\\input"; }

prep_libro() {
    local dir=$1 f=$2
    rsync -a "$FUENTES/libro/" "$dir/"
    ( cd "$dir" && make libro LIBRO="$f" )
}
final_libro() {
    local dir=$1 f=$2
    ( cd "$dir" && pdflatex -interaction batchmode "$f.tex" ) && cp "$dir/$f.pdf" "$dir/salida.pdf"
}

prep_transp() {
    local dir=$1 p=$2 tipo=$3 F=$FUENTES/transp
    mkdir -p "$dir"
    for x in DatosDocumento.tex texto.tex ref.bib Documento.tex temas bank data referencias figuras; do
        ln -sfn "$F/$x" "$dir/$x"
    done
    ln -sfn "$F/$p.tex" "$dir/contenido.tex"
    cat "$F/pre/$tipo.tex" "$F"/pre/{01preBeamer,01slides,01packages,01AMS,01colores}.tex \
        "$F/DatosDocumento.tex" "$F/Documento.tex" > "$dir/MatematicasII-$tipo.tex"
    ( cd "$dir"
      xelatex -interaction batchmode -no-pdf "MatematicasII-$tipo.tex"
      pythontex --interpreter python:python3 "MatematicasII-$tipo.tex"
      latexmk -f -pdflatex='xelatex %O %S' -pdf "MatematicasII-$tipo.tex"
      pdflatex -interaction batchmode "MatematicasII-$tipo.tex" )
}
final_transp() {
    local dir=$1 p=$2 tipo=$3
    ( cd "$dir" && pdflatex -interaction batchmode "MatematicasII-$tipo.tex" ) \
        && cp "$dir/MatematicasII-$tipo.pdf" "$dir/salida.pdf"
}

prep_examen() {
    local dir=$1 f=$2 lang=$3 sol=$4 ref=$5 F=$FUENTES/evaluacion
    mkdir -p "$dir/examenes"
    for x in preguntas quizs finals referencias PreambuloParaExamenes.tex InstruccionesQuiz.tex \
             InstruccionesExamenFinal.tex FormatoNecesidadesEspeciales.tex; do
        ln -sfn "$F/$x" "$dir/$x"
    done
    ln -sf "$F"/quizs/*.tex "$F"/finals/*.tex "$dir/examenes/"
    ln -sfn "examenes/$f.tex" "$dir/$f.tex"
    local opt; opt=$(opt_examen "$lang" "$sol" "$ref")
    # para latexmk la orden pasa otra vez por el shell: hay que proteger \ { }
    local optlm; optlm=$(printf '%s' "$opt" | sed 's/[\\{}]/\\&/g')
    ( cd "$dir"
      xelatex -interaction batchmode "$opt $f.tex"
      xelatex -interaction batchmode -no-pdf "$opt $f.tex"
      pythontex --interpreter python:python3 "$f.tex"
      latexmk -f -pdflatex="xelatex %O $optlm %S" -pdf "$f.tex" )
}
final_examen() {
    local dir=$1 f=$2 lang=$3 sol=$4 ref=$5
    local opt; opt=$(opt_examen "$lang" "$sol" "$ref")
    ( cd "$dir" && xelatex -interaction batchmode "$opt $f.tex" ) && cp "$dir/$f.pdf" "$dir/salida.pdf"
}

# Apuntes de Econometría (Econometria-SRC/makefile, objetivo «apuntes»)
prep_ectr() {
    local dir=$1 tipo=$2 F=$FUENTES/ectr
    mkdir -p "$dir"
    for x in DatosDocumento.tex Documento.tex temas referencias figuras; do ln -sfn "$F/$x" "$dir/$x"; done
    ln -sfn "$F/apuntes.tex" "$dir/contenido.tex"
    cat "$F/pre/$tipo.tex" "$F"/pre/{01preBeamer,01slides,01packages,01AMS,01colores}.tex \
        "$F/DatosDocumento.tex" "$F/Documento.tex" > "$dir/Ectr-$tipo.tex"
    ( cd "$dir"
      xelatex -interaction batchmode -no-pdf "Ectr-$tipo.tex" </dev/null
      pythontex --interpreter python:python3 "Ectr-$tipo.tex"
      bibtex "Ectr-$tipo"
      xelatex -interaction batchmode -no-pdf "Ectr-$tipo.tex"
      pdflatex -interaction batchmode "Ectr-$tipo.tex" )
}
final_ectr() {
    local dir=$1 tipo=$2
    ( cd "$dir" && pdflatex -interaction batchmode "Ectr-$tipo.tex" ) && cp "$dir/Ectr-$tipo.pdf" "$dir/salida.pdf"
}

# Notas de probabilidadCasoFinito: se compila el .tex ya exportado desde org
# f puede llevar subcarpeta (basura/nota3): se compila dentro de ella.
prep_nota() {
    local dir=$1 f=$2
    rsync -a "$FUENTES/casofinito/" "$dir/"
    ( cd "$dir/$(dirname "$f")" && for k in 1 2 3; do pdflatex -interaction batchmode "$(basename "$f").tex"; done )
}
final_nota() {
    local dir=$1 f=$2
    ( cd "$dir/$(dirname "$f")" && pdflatex -interaction batchmode "$(basename "$f").tex" ) \
        && cp "$dir/$f.pdf" "$dir/salida.pdf"
}

# ---------------------------------------------------------------------------
# Órdenes internas (una por documento; se lanzan en paralelo)

_preparar() {
    local id=$1; set -- $(linea_de "$id"); shift; local tipo=$1; shift
    local dir=$TRABAJO/$id
    rm -rf "$dir"; mkdir -p "$dir"
    local ini=$SECONDS
    TEXINPUTS="$CONGELADO:" "prep_$tipo" "$dir" "$@" > "$TRABAJO/$id.preparar.log" 2>&1
    echo "preparado $id ($((SECONDS-ini)) s)"
}

_generar() {
    local stydir=$1 salida=$2 id=$3
    set -- $(linea_de "$id"); shift; local tipo=$1; shift
    local tmp; tmp=$(mktemp -d "$BANCO/tmp/$id.XXXX")
    cp -a "$TRABAJO/$id/." "$tmp/"
    rm -f "$tmp/salida.pdf"
    TEXINPUTS="$stydir:" "final_$tipo" "$tmp" "$@" > "$salida/$id.generar.log" 2>&1
    # Comprobar que se cargó el nacal.sty que queríamos y no otro.
    local usado; usado=$(cat "$tmp"/*.log "$tmp"/*/*.log 2>/dev/null | tr -d '\n' | grep -o "[^( ]*nacal\.sty" | sort -u | tr '\n' ' ')
    if [ -f "$tmp/salida.pdf" ]; then
        cp "$tmp/salida.pdf" "$salida/$id.pdf"
        echo "$id  ok  [nacal: $usado]"
    else
        echo "$id  SIN PDF (ver $salida/$id.generar.log)"
    fi
    case $usado in *"$stydir/nacal.sty"*) ;; *) echo "  AVISO $id: no consta que se usara $stydir/nacal.sty";; esac
    rm -rf "$tmp"
}

_comparar() {
    local A=$1 B=$2 id=$3
    local out=$BANCO/informe/$id a=$BANCO/$A/$id.pdf b=$BANCO/$B/$id.pdf
    if [ ! -f "$a" ] || [ ! -f "$b" ]; then echo "$id  FALTA PDF"; return; fi
    rm -rf "$out"; mkdir -p "$out/a" "$out/b" "$out/dif"
    local pa pb
    pa=$(pdfinfo "$a" | awk '/^Pages:/{print $2}')
    pb=$(pdfinfo "$b" | awk '/^Pages:/{print $2}')
    pdftotext -layout "$a" "$out/a.txt"; pdftotext -layout "$b" "$out/b.txt"
    local dtxt
    if diff -u "$out/a.txt" "$out/b.txt" > "$out/texto.diff"; then dtxt=0; rm "$out/texto.diff"
    else dtxt=$(grep -c '^[-+][^-+]' "$out/texto.diff"); fi
    pdftoppm -r "$RES" -png "$a" "$out/a/p"; pdftoppm -r "$RES" -png "$b" "$out/b/p"
    local difs=() pg
    for pg in "$out"/a/p-*.png; do
        local n; n=$(basename "$pg")
        if [ ! -f "$out/b/$n" ]; then difs+=("${n#p-}"); continue; fi
        if ! cmp -s "$pg" "$out/b/$n"; then
            local ae; ae=$(compare -metric AE "$pg" "$out/b/$n" "$out/dif/$n" 2>&1 >/dev/null)
            [ "${ae%% *}" != 0 ] && difs+=("${n#p-}") || rm -f "$out/dif/$n"
        fi
    done
    rm -rf "$out/a" "$out/b"
    if [ "$pa" = "$pb" ] && [ "$dtxt" = 0 ] && [ ${#difs[@]} = 0 ]; then
        echo "$id  IGUAL  ($pa págs.)"; rm -rf "$out"
    else
        echo "$id  DISTINTO  págs. $pa/$pb, líneas de texto distintas: $dtxt, págs. con píxeles distintos: ${#difs[@]} [${difs[*]%.png}]"
    fi
}

# ---------------------------------------------------------------------------

ids() { if [ $# -gt 0 ]; then printf '%s\n' "$@"; else muestra | cut -d' ' -f1; fi; }

generar() {
    local stydir; stydir=$(cd "$1" && pwd); local salida=$BANCO/$2
    [ -f "$stydir/nacal.sty" ] || { echo "No hay nacal.sty en $stydir" >&2; exit 1; }
    rm -rf "$salida"; mkdir -p "$salida" "$BANCO/tmp"
    echo "nacal.sty: $stydir ($(sha256sum "$stydir/nacal.sty" | cut -c1-16))" > "$salida/ORIGEN.txt"
    ids | xargs -P "$JOBS" -I{} "$0" _generar "$stydir" "$salida" {} | sort | tee "$salida/RESUMEN.txt"
}

orden=${1:-ayuda}; shift || true
case $orden in
    lista)       muestra ;;
    instantanea) instantanea ;;
    instantanea_prob) instantanea_prob ;;
    preparar)    mkdir -p "$TRABAJO"; ids "$@" | xargs -P "$JOBS" -I{} "$0" _preparar {} ;;
    dorado)      generar "$CONGELADO" dorado ;;
    candidato)   generar "${1:?falta el directorio del nacal.sty candidato}" candidato ;;
    comparar)    A=${1:-dorado} B=${2:-candidato}; mkdir -p "$BANCO/informe"
                 ids | xargs -P "$JOBS" -I{} "$0" _comparar "$A" "$B" {} | sort | tee "$BANCO/informe/RESUMEN-$A-$B.txt" ;;
    _preparar|_generar|_comparar) "$orden" "$@" ;;
    *) sed -n '2,25p' "$0" ;;
esac
