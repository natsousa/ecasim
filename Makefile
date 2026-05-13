.PHONY: install document test check render clean

install:
	Rscript -e 'devtools::install_deps(dependencies = TRUE)'
	Rscript -e 'devtools::install(".", upgrade = FALSE)'

document:
	Rscript -e 'devtools::document()'

test:
	Rscript -e 'devtools::test()'

check:
	Rscript -e 'devtools::check()'

render:
	quarto render analysis/report.qmd

clean:
	rm -rf analysis/report.html analysis/report_files analysis/.quarto _freeze
