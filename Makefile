#----------------------------------------------------------
# Parameters
#----------------------------------------------------------
PROJECT= master
FIGURES_DIR= ./Figures
SRC= $(wildcard *.tex) thesismanuscrit.cls \
	$(wildcard Preamble/*.tex) \
	$(wildcard Front/*.tex) \
	$(wildcard Main/*.tex) \
	    $(wildcard Main/SelecAleatoire/*.tex) \
	        $(wildcard Main/Figures/*) \
	$(wildcard Back/*.tex)
#----------------------------------------------------------

PDF= $(PROJECT).pdf
BIBTOOL= biber
VIEWER= okular

# Tool for compiling directly to pdf
LATEX= lualatex
LFLAGS= -interaction nonstopmode

RERUN= '(There were undefined references|Rerun to get (cross-references|the bars) right)'
UNDEFINED= '((Reference|Citation).*undefined)|(Label.*multiply defined)'

#----------------------------------------------------------
# Beginning of targets
#----------------------------------------------------------

.PHONY: pdf clean clean-all display

.SUFFIXES: .tex .pdf .bb; .bcf

# For compatibility with vim latex-suite search and
# compilation
pdf: $(PDF)
	@echo "Citations ou références indéfinies:"
	@egrep -i $(UNDEFINED) $*.log || echo "Aucune"

$(PDF):

%.pdf: %.tex $(SRC) %.bbl %.bcf.md5
	@$(LATEX) $(LFLAGS) $<
	#@if egrep -q $(RERUN) $*.log ; then $(LATEX) $(LFLAGS) $< ; fi
	#@if egrep -q $(RERUN) $*.log ; then $(LATEX) $(LFLAGS) $< ; fi
	#@if egrep -q $(RERUN) $*.log ; then $(LATEX) $(LFLAGS) $< ; fi
	@MD5=$$(md5sum $*.bcf) ; echo $$MD5 | cmp -s $*.bcf.md5 - ; if $$? -ne 0 ; \
	    then echo $$MD5 > $*.bcf.md5 ; \
		make pdf ; fi

%.bbl: %.bcf.md5
	@$(BIBTOOL) $*

%.bcf.md5: %.bcf
	@MD5=$$(md5sum $<) ; echo $$MD5 | cmp -s $@ - ; if $$? -ne 0 ; \
	    then echo $$MD5 > $@ ; fi

%.bcf:
	@$(LATEX) $(LFLAGS) $*.tex

clean:
	@rm -f *.log *.aux *.dvi *.toc *.lot *.lof *.snm *.nav *.out
	@rm -f *.bbl *.blg *.run.xml *.bcf
	@rm -f *.bcf.md5 # From Makefile
	@rm -f *.upa *.upb # For PDF comments?
	@rm -f comment.cut # Created by comment package
	@rm -f $(FIGURES_DIR)/*-converted-to.pdf
	@find . -name "*.aux" -print0 | xargs -0 rm -f

clean-all: clean
	@rm -f $(PDF)

display: pdf
	@$(VIEWER) $(PDF) &

targz: pdf clean
	tar -cvzf "../$${PWD##*/}-$$(date +%F).tar.gz" . --exclude=".*.swp" --exclude=".git" --exclude=".svn"
	@if [ -n "$$(find . -name '.*.swp')" ] ; then echo "Warning: hidden vim swap files in directory were not added to archive" ; fi
