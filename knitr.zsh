{
	# rm -rf figure cache
	R -e "knitr::knit2pdf('main.Rnw', 'main.tex')"

	lualatex -synctex=1 -interaction=nonstopmode main.tex
	pdflatex main.tex
	bibtex main
	bibtex main
	pdflatex main.tex
	pdflatex main.tex

	rm -f *.bb* *.bl* *.aux *.toc *.lo* *.out *.tex

	open main.pdf
}