DOCTYPE = SCTR
DOCNUMBER = 14
DOCNAME = $(DOCTYPE)-$(DOCNUMBER)
JOBNAME = $(DOCNAME)
TEX = $(filter-out $(wildcard *acronyms.tex) , $(wildcard *.tex))

export TEXMFHOME ?= lsst-texmf/texmf

# Version information extracted from git.
GITVERSION := $(shell git log -1 --date=short --pretty=%h)
GITDATE := $(shell git log -1 --date=short --pretty=%ad)
GITSTATUS := $(shell git status --porcelain)
ifneq "$(GITSTATUS)" ""
	GITDIRTY = -dirty
endif

$(JOBNAME).pdf: $(DOCNAME).tex meta.tex acronyms.tex
	xelatex $(DOCNAME)
	bibtex $(DOCNAME)
	xelatex $(DOCNAME)
	bibtex $(DOCNAME)
	xelatex $(DOCNAME)
	xelatex $(DOCNAME)

.FORCE:

meta.tex: Makefile .FORCE
	rm -f $@
	touch $@
	echo '% GENERATED FILE -- edit this in the Makefile' >>$@
	/bin/echo '\newcommand{\lsstDocType}{$(DOCTYPE)}' >>$@
	/bin/echo '\newcommand{\lsstDocNum}{$(DOCNUMBER)}' >>$@
	/bin/echo '\newcommand{\vcsrevision}{$(GITVERSION)$(GITDIRTY)}' >>$@
	/bin/echo '\newcommand{\vcsRevision}{$(GITVERSION)$(GITDIRTY)}' >>$@
	/bin/echo '\newcommand{\vcsdate}{$(GITDATE)}' >>$@
	/bin/echo '\newcommand{\vcsDate}{$(GITDATE)}' >>$@

generate: .FORCE
	docsteady --namespace PSE generate-tpr LVV-P63 $(DOCNAME).tex

#Traditional acronyms are better in this document
acronyms.tex : ${TEX} myacronyms.txt skipacronyms.txt
	echo ${TEXMFHOME}
	python3 ${TEXMFHOME}/../bin/generateAcronyms.py -t "DM"    $(TEX)

myacronyms.txt :
	touch myacronyms.txt

skipacronyms.txt :
	touch skipacronyms.txt

clean :
	latexmk -c
	rm *.pdf *.nav *.bbl *.xdv *.snm
