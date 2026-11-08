ficheros:
	rm -f nacal.sty nacal-probabilidad.sty nacal-econometria.sty
	latex nacal.ins
	pdflatex -interaction nonstopmode nacal.dtx
	makeindex -s gglo.ist -o nacal.gls nacal.glo
	makeindex -s gind.ist -o nacal.ind nacal.idx
	pdflatex  -interaction batchmode nacal.dtx
	pdflatex  -interaction batchmode nacal.dtx
	pdflatex  -interaction batchmode nacal.dtx
