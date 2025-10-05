# Makefile for DesignOfIIRFilters.pdf

# Debugging hack in "Tracing rule execution in GNU Make" by John Graham-Cumming
# See https://www.cmcrossroads.com/article/tracing-rule-execution-gnu-make
# OLD_SHELL := $(SHELL)
# SHELL = $(warning Building $@$(if $<, (from $<))$(if $?, ($? newer))) \
#         $(OLD_SHELL) -x
#
# Use the following to find out if running on Linux with sys_vendor as "QEMU":
# VENDOR=$(shell cat /sys/class/dmi/id/sys_vendor)
#
# The apparently hardwired limit of 131071 characters in the bash command
# buffer caused problems with the $(test_COEFS) variable. The work
# around is to remove the _spec.m and _test.mat file names from the _test.mk

#
# Top-level variables
#
TARGETS=DesignOfIIRFilters DesignOfSchurLatticeFilters
VPATH=src:src/test:fig/dia:fig/tikz

# Octave script files that generate figures. Each has an associated .mk file
# and, on completion, a .diary file.
OCTAVE_SCRIPTS:=$(notdir $(basename $(wildcard src/mk/*.mk)))

# These are all the .oct files. Some are not needed to build the pdf
# (eg: labudde.oct and complex_lower_hessenberg_inverse.oct) but are
# needed by aegis test scripts.
OCT_FILES:=$(notdir $(basename $(wildcard src/*.cc)))

# GNU dia figure files
DIA_FILES:=$(notdir $(basename $(wildcard fig/dia/*.dia)))

# TEX tikz figure files
TIKZ_FILES:=$(notdir $(basename $(wildcard fig/tikz/*.tex)))

# clean suffixes
CLEAN_SUFFIXES= \~ .eps .diary .tmp .oct .mex .o .ok _coef.m _digits.m \
_spec.m _test.mat -core .tab .elg .results
CLEAN_TEX_SUFFIXES= .aux .bbl .blg .brf .dvi .out .toc .lof .lot .loa \
.log .synctex.gz 
CLEAN_AEGIS_SUFFIXES= \,D \,B \,B,Conflicts
CHECK_STRINGS= warning erfull

# Command definitions
OCTAVE=octave
MKOCTFILE=mkoctfile
OCTAVE_FLAGS=--no-gui -q -p src
OCTAVE_VER=$(shell $(OCTAVE) $(OCTAVE_FLAGS) \
                             --eval "disp(OCTAVE_VERSION)" | cut -d '-' -f 1)
MKOCTFILE_FLAGS=-v -o $@ -Wall -lgmp -lmpfr -I/usr/include/eigen3 \
-Wno-deprecated-declarations
# Suppress warning for deprecated std::wbuffer_convert<convfacet_u8, char>

PDFLATEX=TEXMFHOME=./fig/texmf pdflatex
PDFLATEX_FLAGS=-output-directory=. -interaction=nonstopmode -synctex=1
PDF_MONO_FLAGS='\newcommand\$(1)Mono{}\input{$(1)}'
BIBTEX=bibtex
QPDF=/usr/bin/qpdf
PDFGREP=/usr/bin/pdfgrep
GREP=/usr/bin/grep -Hi
JEKYLL_OPTS=--config docs/_config.yml --source docs --destination docs/_site

#
# A list of all the dependencies of $(TARGETS:%=%.pdf)
#
TARGET_DEPENDENCIES= $(DIA_FILES:%=%.pdf) $(TIKZ_FILES:%=%.pdf) \
$(OCTAVE_SCRIPTS:%=%.diary) $(EXTRA_DIARY_FILES) 	

#
# Rules
#
%.diary : %.m
	$(OCTAVE_LD_PRELOAD) $(OCTAVE) $(OCTAVE_FLAGS) $<

%.eps : %.dia
	dia -t eps -e $@ $^ 2>&1 | tee $@.elg

%.pdf : %.eps
	epstopdf $< 

%.pdf : %.tex
	$(PDFLATEX) $(PDFLATEX_FLAGS) $<

# To test an octfile with valgrind and gdb:
#   1. XCXXFLAGS="-ggdb3 -O0"
#   2. Run "valgrind --track-origins=yes --vgdb=yes --vgdb-error=0 \
#           octave-cli -p src -p src/test"
#   3. Run "gdb --args octave-cli -p src -p src/test" in a separate
#      shell and then issue the gdb commands:
#        target remote | vgdb
#        continue
#
# To test an octfile with address-sanitizer add these flags:
#   XCXXFLAGS="-g -fsanitize=undefined -fsanitize=address \
#              -fno-sanitize=vptr -fno-omit-frame-pointer"
# and run with:
#   LD_PRELOAD=/usr/lib64/libasan.so.8 octave-cli --eval "expr"
#
# Apparently, if the AddressSanitizer library is built without RTTI then
# there are many "vptr" false-positives.
#
# %.oct
%.oct : %.cc 
	$(MKOCTFILE) $(MKOCTFILE_FLAGS) $(XCXXFLAGS) $<

#
# Macros 
#
clean_macro=-for suf in $(1) ; do find . -name \*$$suf -exec rm -f {} ';' ; done


#
# Templates defining dependencies
#
define dia_template =
$(1).eps : $(1).dia
$(1).pdf : $(1).eps
endef

define tikz_template =
$(1).pdf : $(1).tex
endef

define octave_script_template =
$(1).diary : $($(1)_FILES)
endef

define target_template =
$(1).pdf : $(1).tex $(1).bib $(TARGET_DEPENDENCIES)
	$(PDFLATEX) $(PDFLATEX_FLAGS) $(1) && \
	$(BIBTEX) $(1) && \
	$(PDFLATEX) $(PDFLATEX_FLAGS) $(1) && \
	$(PDFLATEX) $(PDFLATEX_FLAGS) $(1) && \
	$(PDFLATEX) $(PDFLATEX_FLAGS) $(1) 
	-@if [[ -x $(QPDF) ]] ; then \
		$(QPDF) --linearize $(1).pdf docs/public/$(1).pdf ; \
	else \
		cp -f $(1).pdf docs/public/$(1).pdf ; \
	fi
	-@if [[ -x $(PDFGREP) ]] ; then \
		$(PDFGREP) "\[\?" $(1).pdf || true ; \
	fi;
	-@for warnstr in $(CHECK_STRINGS); do \
		$(GREP) $$$$warnstr $(1).log ; done
	-@echo Build complete
endef

.PHONY: $(1)_monochrome
$(1)_monochrome: $(1).tex $(1).bib $(TARGET_DEPENDENCIES)
	$(PDFLATEX) $(PDFLATEX_FLAGS) $(PDF_MONO_FLAGS) && \
	$(BIBTEX) $(1) && \
	$(PDFLATEX) $(PDFLATEX_FLAGS) $(PDF_MONO_FLAGS) && \
	$(PDFLATEX) $(PDFLATEX_FLAGS) $(PDF_MONO_FLAGS) && \
	$(PDFLATEX) $(PDFLATEX_FLAGS) $(PDF_MONO_FLAGS)

#
# Intermediate file dependencies
# 
$(foreach octave_script, $(OCTAVE_SCRIPTS), \
  $(eval include src/mk/$(octave_script).mk) \
  $(eval test_FIGURES+=$($(octave_script)_FIGURES)) \
  $(eval test_COEFS+=$($(octave_script)_COEFS)) \
  $(eval EXTRA_DIARY_FILES+=$($(octave_script)_EXTRA_DIARY_FILES)) \
  $(eval $(call octave_script_template,$(octave_script))))

$(foreach dia_file, $(DIA_FILES), $(eval $(call dia_template,$(dia_file))))

$(foreach tikz_file, $(TIKZ_FILES), $(eval $(call tikz_template,$(tikz_file))))


#
# Build targets
#

$(foreach target, $(TARGETS), $(eval $(call target_template,$(target))))


#
# PHONY targets
#

.PHONY: testvars
testvars :	
	@echo "OCTAVE_SCRIPTS=" $(OCTAVE_SCRIPTS)
	@echo $(OCT_FILES:%=src/%.oct)
	@echo "deczky3_socp_test_FILES=" ${deczky3_socp_test_FILES}
	@echo $(OCTAVE_VER)
	@echo $(TARGETS:%=%.pdf)
	@echo $(DIA_FILES)
	@echo $(TIKZ_FILES)

.PHONY: octfiles
octfiles: $(OCT_FILES:%=src/%.oct)

.PHONY: batchtest
batchtest: octfiles
	sh ./batchtest.sh "`find test -name t0???a.sh -printf '%p '`" batchtest.out

.PHONY: clean
clean: 
	-rm -f $(test_FIGURES:%=%.tex)
	-rm -f $(test_FIGURES:%=%.pdf)
	-rm -f $(test_FIGURES:%=%-inc.pdf)
	-rm -f $(test_COEFS)
	-rm -f $(EXTRA_DIARY_FILES)
	-rm -f $(DIA_FILES:%=%.pdf)
	-rm -f $(TIKZ_FILES:%=%.pdf)
	-rm -f octave-workspace
	-rm -Rf docs/.sass-cache docs/_site
	$(call clean_macro,$(CLEAN_SUFFIXES))

.PHONY: cleanaegis
cleanaegis:
	-rm -f aegis.log
	$(call clean_macro,$(CLEAN_AEGIS_SUFFIXES))

.PHONY: cleantex
cleantex:	
	$(call clean_macro,$(CLEAN_TEX_SUFFIXES))
	-rm -f $(TARGETS:%=%.pdf)

.PHONY: cleanjekyll
cleanjekyll:	
	jekyll clean $(JEKYLL_OPTS)

.PHONY: cleanall
cleanall: clean cleantex cleanaegis cleanjekyll

# Could use tarname=$$AEGIS_PROJECT".C"$$AEGIS_CHANGE 
.PHONY: backup
backup: cleanall
	(tarname=`basename $$PWD` && cd .. && \
	 tar -chjvf ~/$$tarname"."`date +%I%M%p%d%b%y`.tbz --exclude=.git $$tarname)

.PHONY: help
help: 
	@echo \
"Targets: all octfiles clean cleantex cleanall backup batchtest gitignore"

.PHONY: gitignore
gitignore:
	-rm -f .gitignore gitignore.tmp
	echo $(CLEAN_SUFFIXES:%="*"%) > .gitignore
	echo $(CLEAN_TEX_SUFFIXES:%="*"%) >> .gitignore
	echo $(CLEAN_AEGIS_SUFFIXES:%="*"%) >> .gitignore
	echo octave-workspace open_useful_docs.sh $(TARGETS:%=%.pdf) >> .gitignore
	echo _site .sass-cache .jekyll-cache .jekyll-metadata >> .gitignore
	sed -i -e "s/\ /\n/g" .gitignore
	echo $(test_FIGURES:%=%.tex) > gitignore.tmp
	echo $(test_FIGURES:%=%.pdf) >> gitignore.tmp
	echo $(test_FIGURES:%=%-inc.pdf) >> gitignore.tmp
	echo $(test_COEFS) >> gitignore.tmp
	echo $(EXTRA_DIARY_FILES) >> gitignore.tmp
	echo $(DIA_FILES:%=%.pdf) >> gitignore.tmp
	echo $(TIKZ_FILES:%=%.pdf) >> gitignore.tmp
	sed -i -e "s/\ /\n/g" gitignore.tmp
	sort gitignore.tmp  >> .gitignore
	rm gitignore.tmp

.PHONY: jekyll
jekyll: $(TARGETS:%=%.pdf) cleanjekyll
	jekyll serve $(JEKYLL_OPTS)

.PHONY: all
all: octfiles $(TARGETS:%=%.pdf)

.DEFAULT_GOAL := $(word 1,$(TARGETS)).pdf
