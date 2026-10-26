.PHONY: deps test report clean

R := Rscript

# Restore the packages pinned in renv.lock.
deps:
	$(R) -e 'source("renv/activate.R"); renv::restore(prompt = FALSE)'

# Source the loader, then utils/estimation/test_pipeline.R.
# The helper defines test_pipeline() and does not fit a model.
test:
	$(R) -e 'source("libraries.R"); setwd("utils/estimation"); source("test_pipeline.R")'

# Knit main.Rnw and compile main.tex with pdflatex.
report:
	$(R) -e 'source("libraries.R"); knitr::knit("main.Rnw", output = "main.tex"); tinytex::latexmk("main.tex", engine = "pdflatex")'

clean:
	rm -f main.tex main.pdf \
		main.aux main.log main.out main.toc main.bbl main.blg \
		main.fls main.fdb_latexmk main.synctex.gz main.lof main.lot main.xdv
	rm -rf figure cache
