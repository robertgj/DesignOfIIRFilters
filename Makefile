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
# buffer caused problems with the make $(test_COEFS) variable. The work
# around is to remove the _spec.m and _test.mat file names from the _test.mk

#
# Top-level variables
#
VPATH=src:src/test:fig/dia
TARGET=DesignOfIIRFilters

# Octave script files that generate figures. Each has an associated .mk file
# and, on completion, a .diary file.
OCTAVE_SCRIPTS:=$(notdir $(basename $(wildcard src/mk/*.mk)))

# These are all the .oct files. Some are not needed to build the pdf
# (eg: labudde.oct and complex_lower_hessenberg_inverse.oct) but are
# needed by aegis test scripts.
OCT_FILES:=$(notdir $(basename $(wildcard src/*.cc)))

# GNU dia figure files
DIA_FILES:=$(notdir $(basename $(wildcard fig/dia/*.dia)))

# clean suffixes
CLEAN_SUFFIXES= \~ .eps .diary .tmp .oct .mex .o .ok _coef.m _digits.m \
_spec.m _test.mat -core .tab .elg .results
CLEAN_TEX_SUFFIXES= .aux .bbl .blg .brf .dvi .out .toc .lof .lot .loa \
.log .synctex.gz 
CLEAN_AEGIS_SUFFIXES= \,D \,B

# Command definitions
OCTAVE=octave
MKOCTFILE=mkoctfile
OCTAVE_FLAGS=--no-gui -q -p src
OCTAVE_VER=$(shell $(OCTAVE) $(OCTAVE_FLAGS) \
                             --eval "disp(OCTAVE_VERSION)" | cut -d '-' -f 1)
MKOCTFILE_FLAGS=-v -o $@ -Wall -lgmp -lmpfr -I/usr/include/eigen3 \
-Wno-deprecated-declarations
# Suppress warning for deprecated std::wbuffer_convert<convfacet_u8, char>

PDF_MONO_FLAGS='\newcommand\DesignOfIIRFiltersMono{}\input{DesignOfIIRFilters}'
PDFLATEX=pdflatex -interaction=nonstopmode --synctex=1
BIBTEX=bibtex
QPDF=/usr/bin/qpdf
PDFGREP=/usr/bin/pdfgrep
GREP=/usr/bin/grep -Hi
JEKYLL_OPTS=--config docs/_config.yml --source docs --destination docs/_site

#
# A list of all the dependencies of $(TARGET).pdf
#
TARGET_DEPENDENCIES=$(DIA_FILES:%=%.pdf) $(OCTAVE_SCRIPTS:%=%.diary) \
                    $(EXTRA_DIARY_FILES) $(TARGET).bib $(TARGET).tex 


#
# Rules
#
%.diary : %.m
	$(OCTAVE_LD_PRELOAD) $(OCTAVE) $(OCTAVE_FLAGS) $<

%.eps : %.dia
	dia -t eps -e $@ $^ 2>&1 | tee $@.elg

%.pdf : %.eps
	epstopdf $< 

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
# %.oct depends on Makefile in case MKOCTFILE_FLAGS changes behaviour
%.oct : %.cc Makefile
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

define octave_script_template =
$(1).diary : $($(1)_FILES)
endef


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


#
# Build target file. Check for log file warnings, incomplete references.
#
$(TARGET).pdf: $(TARGET_DEPENDENCIES)
	$(PDFLATEX) $(TARGET) && \
	$(BIBTEX)   $(TARGET) && \
	$(PDFLATEX) $(TARGET) && \
	$(PDFLATEX) $(TARGET) && \
	$(PDFLATEX) $(TARGET)
	-@if [[ -x $(QPDF) ]] ; then \
		$(QPDF) --linearize $(TARGET).pdf docs/public/$(TARGET).pdf ; \
	else \
		cp -f $(TARGET).pdf docs/public/$(TARGET).pdf ; \
	fi
	-@if [[ -x $(PDFGREP) ]] ; then \
		$(PDFGREP) "\[\?" DesignOfIIRFilters.pdf || true ; \
	fi;
	-@find . -name \*.elg -exec $(GREP) Can\'t\ load\ glyph {} ';' | sort | uniq
	-@for warnstr in No\ file erfull warning ; do \
		$(GREP) "$$warnstr" DesignOfIIRFilters.log | sort | uniq ; \
	done ; 	
	-@$(GREP) "warning" DesignOfIIRFilters.blg | sort | uniq ; 
	echo "Build complete" ;

#
# PHONY targets
#

.PHONY: testvars
testvars :	
	@echo "OCTAVE_SCRIPTS=" $(OCTAVE_SCRIPTS)
	@echo $(OCT_FILES:%=src/%.oct)
	@echo "deczky3_socp_test_FILES=" ${deczky3_socp_test_FILES}
	@echo $(OCTAVE_VER)

.PHONY: chktex
chktex:
	if [[ -x /usr/bin/chktex ]] ; then \
	  /usr/bin/chktex -n 3 -n 1 -n 7 -n 24 -n 13 -n 17 -n 8 -n 26 -n 32 -n 11 \
	                  -n 9 -n 10 -n 36 -n 25 $(TARGET).tex; \
	fi	

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
	-rm -f octave-workspace
	-rm -Rf docs/.sass-cache docs/_site
	$(call clean_macro,$(CLEAN_SUFFIXES))

.PHONY: cleanaegis
cleanaegis: 
	$(call clean_macro,$(CLEAN_AEGIS_SUFFIXES))

.PHONY: cleantex
cleantex:	
	$(call clean_macro,$(CLEAN_TEX_SUFFIXES))
	-rm -f $(TARGET).pdf

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
	echo octave-workspace open_useful_docs.sh $(TARGET).pdf >> .gitignore
	echo _site .sass-cache .jekyll-cache .jekyll-metadata >> .gitignore
	sed -i -e "s/\ /\n/g" .gitignore
	echo $(test_FIGURES:%=%.tex) > gitignore.tmp
	echo $(test_FIGURES:%=%.pdf) >> gitignore.tmp
	echo $(test_FIGURES:%=%-inc.pdf) >> gitignore.tmp
	echo $(test_COEFS) >> gitignore.tmp
	echo $(EXTRA_DIARY_FILES) >> gitignore.tmp
	echo $(DIA_FILES:%=%.pdf) >> gitignore.tmp
	sed -i -e "s/\ /\n/g" gitignore.tmp
	sort gitignore.tmp  >> .gitignore
	rm gitignore.tmp

.PHONY: jekyll
jekyll: $(TARGET).pdf cleanjekyll
	jekyll serve $(JEKYLL_OPTS)

.PHONY: monochrome
monochrome: $(TARGET_DEPENDENCIES)
	$(PDFLATEX) $(PDF_MONO_FLAGS) && \
	$(BIBTEX) $(TARGET) && \
	$(PDFLATEX) $(PDF_MONO_FLAGS) && \
	$(PDFLATEX) $(PDF_MONO_FLAGS) && \
	$(PDFLATEX) $(PDF_MONO_FLAGS)

.PHONY: all
all: octfiles $(TARGET).pdf 

.DEFAULT_GOAL := $(TARGET).pdf 
