SLIDES =									\
  title										\
  package-managers-0 package-managers-1		\
  problems imperative						\
  giving-up-0 giving-up-1					\
  functional functional-1					\
  guix-components							\
  profile-0 profile-1 rollback profile-1	\
  gc-1 gc-2 gc-3							\
  package-expression						\
  end

PDFS = $(addsuffix .pdf, $(SLIDES))

slides.pdf: $(PDFS)
	gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$@ $+

%.pdf: %.svg
	inkscape -z --export-dpi=300 --export-pdf=$@ $<

clean:
	rm -f $(PDFS) slides.pdf
