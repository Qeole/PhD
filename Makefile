#----------------------------------------------------------
# Parameters
#----------------------------------------------------------
PROJECT= master
FIGURES_DIR= ./Figures
SRC= $(wildcard *.tex) manuscrit.cls $(wildcard Preamble/*.tex) $(wildcard Front/*.tex) $(wildcard Main/*.tex) $(wildcard Back/*.tex)
#
# Set this option to 'yes' to compile to dvi -> ps -> pdf
# instead of creating directly the pdf with pdflatex
DVI_AND_PS= no
#----------------------------------------------------------

PDF= $(PROJECT).pdf
BIBTEX= bibtex
VIEWER= okular

ifeq ($(DVI_AND_PS), yes)

# Tools for compiling to dvi, ps, then pdf
LATEX= latex
LFLAGS=
DVIPS= dvips
PS2PDF= ps2pdf

else

# Tool for compiling directly to pdf
LATEX= lualatex
LFLAGS= -interaction nonstopmode

endif

BIBLIO= '^[^%%]*[\]bibliography\{.*\}'
RERUN= '(There were undefined references|Rerun to get (cross-references|the bars) right)'
UNDEFINED= '((Reference|Citation).*undefined)|(Label.*multiply defined)'

#----------------------------------------------------------
# Beginning of targets
#----------------------------------------------------------

.PHONY: pdf clean clean-all display

.SUFFIXES: .tex .pdf

# For compatibility with vim latex-suite search and
# compilation
pdf: $(PDF)

$(PDF):

ifeq ($(DVI_AND_PS), yes)

%.pdf: %.ps $(SRC)
	@$(PS2PDF) $<

%.ps: %.dvi
	@$(DVIPS) $<

%.dvi: %.tex
	@$(LATEX) $<
	@if egrep -q $(BIBLIO) $< ; then $(BIBTEX) $* ; fi
	@if egrep -q $(RERUN) $*.log ; then $(LATEX) $(LFLAGS) $<; fi
	@if egrep -q $(RERUN) $*.log ; then $(LATEX) $(LFLAGS) $<; fi
	@echo "Undefined citations or references:"
	@egrep -i $(UNDEFINED) $*.log || echo "none"

else

%.pdf: %.tex $(SRC)
	@$(LATEX) $(LFLAGS) $<
	#@if egrep -q $(BIBLIO) $< ; then $(BIBTEX) $* ; fi
	@if egrep -q $(RERUN) $*.log ; then $(LATEX) $(LFLAGS) $< ; fi
	@if egrep -q $(RERUN) $*.log ; then $(LATEX) $(LFLAGS) $< ; fi
	@if egrep -q $(RERUN) $*.log ; then $(LATEX) $(LFLAGS) $< ; fi
	@echo "Citations ou références indéfinies:"
	@egrep -i $(UNDEFINED) $*.log || echo "Aucune"

endif

clean:
	@rm -f *.log *.aux *.dvi *.toc *.lot *.lof *.snm *.nav *.out
	@rm -f *.bbl *.blg *.run.xml *.bcf
	@rm -f *.upa *.upb # For PDF comments?
	@rm -f comment.cut # Created by comment package
	@rm -f $(FIGURES_DIR)/*-converted-to.pdf
	@rm -f Preamble/*.aux Front/*.aux Main/*.aux Back/*.aux

clean-all: clean
	@rm -f $(PDF)

display: pdf
	@$(VIEWER) $(PDF) &

targz: pdf clean
	tar -cvzf "../$${PWD##*/}-$$(date +%F).tar.gz" . --exclude=".*.swp" --exclude=".git" --exclude=".svn"
	@if [ -n "$$(find . -name '.*.swp')" ] ; then echo "Warning: hidden vim swap files in directory were not added to archive" ; fi
