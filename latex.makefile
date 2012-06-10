
###
SRC_DIR   = ./ ./src/ $(addprefix src/, $(MODULES))

STY_FILES = $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.sty))
TEX_FILES = $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.tex))
BIB_FILES = $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.bib))
IDX_FILES = 

LATEX_FLAGS = -halt-on-error -quiet -output-directory obj/

###
UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
PDFVIEWER = evince
endif
ifeq ($(UNAME), Darwin)
PDFVIEWER = open
endif

###
default: $(addsuffix .pdf, $(addprefix bin/, $(PROJECT)))

display: default
	(${PDFVIEWER} $(addsuffix .pdf, $(addprefix bin/, $(PROJECT))) &)

publish: default
	(scp $(addsuffix .pdf, $(addprefix bin/, $(PROJECT))) jshiebel@wopr.csl.mtu.edu:~/.WWW/files/)

###
bin/$(PROJECT).pdf: obj/$(PROJECT).pdf
	(mkdir -p bin/)
	(cp obj/$(PROJECT).pdf bin/$(PROJECT).pdf)

obj/$(PROJECT).pdf: obj/$(PROJECT).ps
	(cd obj; ps2pdf14 -r1800 -dPDFSettings=/printer -dCompatibilityLevel=1.4 -dMaxSubsetPct=0 -dSubsetFonts=false -dEmbedAllFonts=true -sPAPERSIZE=letter $(PROJECT).ps)

obj/$(PROJECT).ps : obj/$(PROJECT).dvi
	(cd obj; dvips -q -Ppdf -G0 -tletter -updftex.map $(PROJECT).dvi)

###
# DVI
obj/$(PROJECT).dvi : ${STY_FILES} ${TEX_FILES} ${BIB_FILES}
	mkdir -p obj/
	latex ${LATEX_FLAGS} $(PROJECT)
ifeq ($(findstring ${PROJECT}.bib,$(wildcard ./*.bib)), ${PROJECT}.bib)
	(cp $(wildcard ./*.bst) obj/; cp ${PROJECT}.bib obj/; cd obj; bibtex ${PROJECT}; cd ..; cp obj/${PROJECT}.bbl ./)
	latex ${LATEX_FLAGS} ${PROJECT}
endif
	latex ${LATEX_FLAGS} ${PROJECT}

### Clean
#
clean ::
	rm -rf obj/ bin/
