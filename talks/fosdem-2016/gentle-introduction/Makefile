slides.pdf: $(addsuffix .pdf, 01 02 03 03b 03c 04 05 06 07 08)
	gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$@ $^

%.pdf: %.svg
	inkscape -z --export-dpi=300 --export-pdf=$@ $<
