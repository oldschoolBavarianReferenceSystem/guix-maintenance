DOT      := dot
SKRIBILO := skribilo
PDFLATEX := pdflatex

guix.pdf: bootstrap-graph.pdf

%.pdf: %.dot
	$(DOT) -Tpdf < "$<" > "$@.tmp"
	mv "$@.tmp" "$@"

%.pdf: %.tex
	$(PDFLATEX) "$<"

%.tex: %.skb
	$(SKRIBILO)  -t latex -o "$@" "$<"
