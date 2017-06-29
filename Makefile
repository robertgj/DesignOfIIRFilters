# Makefile for DesignOfIIRFilters.pdf

VPATH = src:fig
TARGET=DesignOfIIRFilters

#
# Octave script files that generate figures. Each has an associated .mk file
# and, on completion, a .diary file.
#

OCTAVE_SCRIPTS = \
 Abcd2cc_test \
 allpass2ndOrderCascadeDelay_socp_test \
 allpass2ndOrderCascade_socp_sqmag_test \
 allpass2ndOrderCascade_socp_test \
 bincoeff_test \
 bitflip_NSPA_lattice_test \
 bitflip_NS_lattice_test \
 bitflip_OneMPA_lattice_test \
 bitflip_OneM_lattice_test \
 bitflip_bandpass_NS_lattice_test \
 bitflip_bandpass_OneM_lattice_test \
 bitflip_bandpass_direct_test \
 bitflip_bandpass_schur_FIR_lattice_test \
 bitflip_svcasc_test \
 bitflip_test \
 branch_bound_bandpass_OneM_lattice_10_nbits_test \
 branch_bound_bandpass_OneM_lattice_6_nbits_test \
 branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test \
 butt3NSPA_test \
 butt3NSSV_test \
 butt3NS_test \
 butt3OneMSV_test \
 butt3OneM_test \
 butt6NSPABP_test \
 decimator_R2_test \
 deczky1_sqp_test \
 deczky3_socp_test \
 deczky3_socp_bfgs_test \
 deczky3_sqp_test \
 deczky3a_socp_test \
 deczky3a_sqp_test \
 de_min_NSPA_lattice_test \
 de_min_NS_lattice_test \
 de_min_OneMPA_lattice_test \
 de_min_OneM_lattice_test \
 de_min_svcasc_test \
 error_feedback_test \
 freq_transform_structure_test \
 frm2ndOrderCascade_socp_test \
 gkstep_test \
 iir_frm_allpass_socp_slb_test \
 iir_frm_parallel_allpass_socp_slb_test \
 iir_frm_socp_slb_test \
 iir_slb_exchange_constraints_test \
 iir_slb_update_constraints_test \
 iir_socp_slb_bandpass_test \
 iir_sqp_mmse_test \
 iir_sqp_mmse_tarczynski_ex2_test \
 iir_sqp_slb_bandpass_test \
 iir_sqp_slb_differentiator_test \
 iir_sqp_slb_fir_bandpass_test \
 iir_sqp_slb_hilbert_test \
 iir_sqp_slb_minimum_phase_test \
 iir_sqp_slb_pink_test \
 iir_sqp_slb_test \
 linesearch_test \
 local_max_test \
 local_peak_test \
 lowpass2ndOrderCascade_socp_test \
 minphase_test \
 octave_info_test \
 parallel_allpass_delay_socp_slb_test \
 parallel_allpass_delay_sqp_slb_test \
 parallel_allpass_socp_slb_flat_delay_test \
 parallel_allpass_socp_slb_test \
 polyphase_allpass_socp_slb_flat_delay_test \
 polyphase_allpass_socp_slb_test \
 pop_relaxation_bandpass_OneM_lattice_10_nbits_test \
 samin_NSPA_lattice_test \
 samin_NS_lattice_test \
 samin_OneMPA_lattice_test \
 samin_OneM_lattice_test \
 samin_svcasc_test \
 schurNSlattice_sqp_slb_lowpass_test \
 schurOneMAPlattice_frm_halfband_socp_slb_test \
 schurOneMAPlattice_frm_hilbert_socp_slb_test \
 schurOneMlattice_bandpass_allocsd_test \
 schurOneMlattice_socp_slb_lowpass_test \
 schurOneMlattice_sqp_slb_bandpass_test \
 schurOneMlattice_sqp_slb_hilbert_test \
 schurOneMlattice_sqp_slb_lowpass_test \
 schurOneMR2lattice2Abcd_test \
 schur_retimed_test \
 sedumi_test \
 simplex_NSPA_lattice_test \
 simplex_NS_lattice_test \
 simplex_OneMPA_lattice_test \
 simplex_OneM_lattice_test \
 simplex_svcasc_test \
 socp_relaxation_gaussian_FIR_lattice_16_nbits_test \
 socp_relaxation_hilbert_OneM_lattice_10_nbits_test \
 socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test \
 sparsePOP_test \
 spectralfactor_test \
 sqp_bfgs_test \
 sqp_gi_test \
 sqp_relaxation_bandpass_OneM_lattice_10_nbits_test \
 sqp_relaxation_lowpass_OneM_lattice_10_nbits_test \
 sv2block_test \
 svcasc2noise_example_test \
 tarczynski_ex2_standalone_test \
 tfp2g_test \
 tfp2schurNSlattice2Abcd_test

# These are all the .oct files. Some are not needed to build the pdf
# (eg: labudde.oct and complex_lower_hessenberg_inverse.oct) but are
# needed by aegis test scripts.
OCTFILES = \
 Abcd2H \
 bin2SD \
 bin2SPT \
 bitflip \
 complementaryFIRdecomp \
 complex_lower_hessenberg_inverse \
 complex_zhong_inverse \
 labudde \
 reprand \
 schurdecomp \
 schurexpand \
 schurFIRdecomp \
 schurNSlattice2Abcd \
 schurNSscale \
 schurOneMAPlattice2H \
 schurOneMlattice2Abcd \
 schurOneMlattice2H \
 spectralfactor

#
# Generate figures
#

DIA_FILES= johansson_frm_structure lim_frm_structure \
 simple_frm_response lim_frm_response_a \
 lim_frm_response_b lim_frm_response_c lim_frm_response_d \
 lim_frm_response_e lim_frm_response_f lim_frm_response_g \
 delay direct2 directL directR reorder svfg svfgcascade sv_cfA sv_cfB sv_cfC \
 factoredsvfg retimedfactoredsvfg FrequencyTransformation lattice depth4 \
 depth10 schur_AllPole_filter schur_FIR_filter schur_H_filter schur_Norm \
 arbitrary_to_two_in_two_out_allpass lattice_retimed_a lattice_retimed_b \
 schur_OneMultiplier schur_RetimedA schur_RetimedB schur_RetimedC \
 schur_ScaledNorm schur_ScaledNorm_SV_derivation \
 schur_OneMultiplier_SV_derivation schur_TransposeOneMult \
 schur_TransposeScaledNorm svfg_noise output_noise Example_Butt3NS \
 Example_Butt3NS_SV_retimed Example_Butt3OneM_SV_retimed \
 Example_Schur_retimedA Example_Schur_retimedB \
 BitFlippingAlgorithm BranchBoundTree errorfeedback \
 schurOneMR2lattice schurOneMR2lattice_retimed complementary_FIR_filter

#
# clean suffixes
#
CLEAN_SUFFIXES= \~ .eps .diary .tmp .oct .mex .o .ok _coef.m _digits.m \
.spec -core .tab .out .results
CLEAN_TEX_SUFFIXES= .aux .bbl .blg .brf .dvi .out .toc .lof .lot \
.log .synctex.gz 
CLEAN_AEGIS_SUFFIXES= \,D

#
# Command definitions
#
OCTAVE_FLAGS=-q
OCTAVE=octave-cli $(OCTAVE_FLAGS)
PDFLATEX=pdflatex -interaction=nonstopmode --synctex=1
BIBTEX=bibtex
JEKYLL_CONFIG=--config docs/_config.yml --source docs --destination docs/_site
#
# Rules
#
%.eps : %.dia
	dia -t eps -e $@ $^ 

%.pdf : %.eps
	epstopdf $< 

# To test an octfile with address-sanitizer add these flags:
#    "-g -fsanitize=undefined -fsanitize=address -fno-sanitize=vptr \
#     -fno-omit-frame-pointer"
# and run with:
#   LD_PRELOAD=/usr/lib64/libasan.so.3 octave --eval "expr"
#
# Apparently, if the AddressSanitizer library is built without RTTI then
# there are many "vptr" false-positives.
#
# To test an octfile with oprofile, compile the octfile with '-g' then run:
#   operf octave file_test.m
#   opannotate --source file.oct
%.oct : %.cc
	mkoctfile -v -o $@ -march=native -O2 -Wall $(EXTRA_CXXFLAGS) -lgmp -lmpfr $^

#
# Macros and templates
#
clean_macro=-for suf in $(1) ; do find . -name \*$$suf -exec rm -f {} ';' ; done

define dia_template =
$(1).eps : $(1).dia
$(1).pdf : $(1).eps
endef

define octave_script_template =
$(1).diary : $($(1)_FILES)
	$(OCTAVE) -p `pwd`/src --eval '$(1)'
endef

#
# Intermediate file dependencies
# 
$(foreach octave_script, $(OCTAVE_SCRIPTS), \
  $(eval include src/$(octave_script).mk) \
  $(eval test_FIGURES+=$($(octave_script)_FIGURES)) \
  $(eval test_COEFS+=$($(octave_script)_COEFS)) \
  $(eval EXTRA_DIARY_FILES+=$($(octave_script)_EXTRA_DIARY_FILES)) \
  $(eval $(call octave_script_template,$(octave_script))))

$(foreach dia_file, $(DIA_FILES), $(eval $(call dia_template,$(dia_file))))

$(foreach figure, $(test_FIGURES), $(eval $(call bw_pdf_template,$(figure))))

#
# Target file dependencies
#
$(TARGET).pdf: $(DIA_FILES:%=%.pdf) $(OCTAVE_SCRIPTS:%=%.diary) \
               $(EXTRA_DIARY_FILES) $(TARGET).bib $(TARGET).tex
	$(PDFLATEX) $(TARGET) && \
	$(BIBTEX)   $(TARGET) && \
	$(PDFLATEX) $(TARGET) && \
	$(PDFLATEX) $(TARGET) && \
	$(PDFLATEX) $(TARGET) 

#
# PHONY targets
#
.PHONY: testvars
testvars :
	@echo "deczky3_socp_test_FILES=" ${deczky3_socp_test_FILES}

.PHONY: octfiles
octfiles: $(OCTFILES:%=src/%.oct) sedumi_test.diary sparsePOP_test.diary

.PHONY: batchtest
batchtest: octfiles
	sh ./batchtest.sh "`find test -name t0???a.sh -printf '%p '`" batchtest.out

.PHONY: clean
clean: 
	-rm -f $(test_FIGURES:%=%.tex)
	-rm -f $(test_FIGURES:%=%.pdf)
	-rm -f $(test_COEFS)
	-rm -f $(EXTRA_DIARY_FILES)
	-rm -f $(DIA_FILES:%=%.pdf)
	$(call clean_macro,$(CLEAN_SUFFIXES))

.PHONY: cleanaegis
cleanaegis: 
	$(call clean_macro,$(CLEAN_AEGIS_SUFFIXES))

.PHONY: cleantex
cleantex:	
	$(call clean_macro,$(CLEAN_TEX_SUFFIXES))
	-rm -f $(TARGET).pdf

.PHONY: cleanall
cleanall: clean cleantex cleanaegis

.PHONY: backup
backup: cleanall
	dir=`pwd` && tar -chjvf ~/`basename $$dir`.`date +%d%b%y`.tbz *

.PHONY: help
help: 
	@echo "Targets: all octfiles clean cleantex cleanall backup"
	@echo "         batchtest gitignore jekyll jekyll-serve"

.PHONY: gitignore
gitignore:
	-rm -f .gitignore
	for suf in $(CLEAN_SUFFIXES) $(CLEAN_TEX_SUFFIXES) \
		$(CLEAN_AEGIS_SUFFIXES);\
	do \
		echo "*"$$suf >> .gitignore ; \
	done
	for file in $(test_FIGURES:%=%.tex) $(test_FIGURES:%=%.pdf) \
		$(test_COEFS) $(EXTRA_DIARY_FILES) $(DIA_FILES:%=%.pdf); \
	do \
		echo $$file >> .gitignore ; \
	done
	echo $(TARGET).pdf >> .gitignore
	echo aegis.conf >> .gitignore
	echo patch/aegis-4.24.patch >> .gitignore
	echo patch/fhist-1.21.D001.patch >> .gitignore

.PHONY: jekyll
jekyll: $(TARGET).pdf
	cp $(TARGET).pdf docs/public
	jekyll build $(JEKYLL_CONFIG)

.PHONY: jekyll-serve
jekyll-serve: jekyll
	jekyll serve $(JEKYLL_CONFIG)

.PHONY: all
all: octfiles $(TARGET).pdf gitignore jekyll

.DEFAULT_GOAL := $(TARGET).pdf 

