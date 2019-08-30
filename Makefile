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
 allpass_filter_test \
 bincoeff_test \
 bitflip_directFIRsymmetric_bandpass_test \
 bitflip_directIIR_bandpass_test \
 bitflip_schurFIRlattice_bandpass_test \
 bitflip_schurNSPAlattice_lowpass_test \
 bitflip_schurNSlattice_bandpass_test \
 bitflip_schurNSlattice_lowpass_test \
 bitflip_schurOneMPAlattice_bandpass_test \
 bitflip_schurOneMPAlattice_lowpass_test \
 bitflip_schurOneMlattice_bandpass_test \
 bitflip_schurOneMlattice_lowpass_test \
 bitflip_svcasc_lowpass_test \
 bitflip_test \
 branch_bound_directFIRhilbert_12_nbits_test \
 branch_bound_directFIRhilbert_bandpass_12_nbits_test \
 branch_bound_directFIRsymmetric_bandpass_8_nbits_test \
 branch_bound_johanssonOneMlattice_bandstop_16_nbits_test \
 branch_bound_schurOneMAPlattice_frm_12_nbits_test \
 branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test \
 branch_bound_schurOneMPAlattice_bandpass_12_nbits_test \
 branch_bound_schurOneMPAlattice_bandpass_hilbert_10_nbits_test \
 branch_bound_schurOneMPAlattice_bandpass_hilbert_12_nbits_test \
 branch_bound_schurOneMPAlattice_elliptic_lowpass_8_nbits_test \
 branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test \
 branch_bound_schurOneMPAlattice_lowpass_12_nbits_test \
 branch_bound_schurOneMlattice_bandpass_10_nbits_test \
 branch_bound_schurOneMlattice_bandpass_6_nbits_test \
 branch_bound_schurOneMlattice_bandpass_8_nbits_test \
 butt3NSPA_test \
 butt3NSSV_test \
 butt3NS_test \
 butt3OneMSV_test \
 butt3OneM_test \
 butt6NSPABP_test \
 compare_fir_iir_socp_slb_lowpass_test \
 de_min_schurNSPAlattice_lowpass_test \
 de_min_schurNSlattice_lowpass_test \
 de_min_schurOneMPAlattice_lowpass_test \
 de_min_schurOneMlattice_lowpass_test \
 de_min_svcasc_lowpass_test \
 decimator_R2_test \
 decimator_R2_alternate_test \
 deczky1_sqp_test \
 deczky3_socp_bfgs_test \
 deczky3_socp_test \
 deczky3_sqp_test \
 deczky3a_socp_test \
 deczky3a_sqp_test \
 directFIRhilbert_slb_test \
 directFIRhilbert_bandpass_slb_test \
 directFIRsymmetric_bandpass_allocsd_test \
 directFIRsymmetric_slb_bandpass_test \
 directFIRsymmetric_slb_lowpass_test \
 ellipMinQ_test \
 error_feedback_test \
 fir_socp_slb_lowpass_test \
 freq_transform_structure_test \
 frm2ndOrderCascade_socp_test \
 gkstep_test \
 iir_frm_allpass_socp_slb_test \
 iir_frm_parallel_allpass_socp_slb_test \
 iir_frm_socp_slb_test \
 iir_slb_exchange_constraints_test \
 iir_slb_update_constraints_test \
 iir_socp_slb_bandpass_test \
 iir_socp_slb_lowpass_test \
 iir_sqp_mmse_tarczynski_ex2_test \
 iir_sqp_mmse_test \
 iir_sqp_slb_bandpass_test \
 iir_sqp_slb_differentiator_test \
 iir_sqp_slb_fir_bandpass_test \
 iir_sqp_slb_hilbert_test \
 iir_sqp_slb_minimum_phase_test \
 iir_sqp_slb_pink_test \
 iir_sqp_slb_test \
 jacobi_Zeta_test \
 johansson_cascade_allpass_bandstop_test \
 johanssonOneMlattice_socp_slb_bandstop_test \
 linesearch_test \
 local_max_test \
 local_peak_test \
 lowpass2ndOrderCascade_socp_test \
 minphase_test \
 octave_info_test \
 parallel_allpass_delay_socp_slb_test \
 parallel_allpass_delay_sqp_slb_test \
 parallel_allpass_socp_slb_bandpass_test \
 parallel_allpass_socp_slb_bandpass_hilbert_test \
 parallel_allpass_socp_slb_flat_delay_test \
 parallel_allpass_socp_slb_test \
 polyphase_allpass_socp_slb_flat_delay_test \
 polyphase_allpass_socp_slb_test \
 pop_relaxation_schurOneMlattice_bandpass_10_nbits_test \
 samin_schurNSPAlattice_lowpass_test \
 samin_schurNSlattice_lowpass_test \
 samin_schurOneMPAlattice_lowpass_test \
 samin_schurOneMlattice_lowpass_test \
 samin_svcasc_lowpass_test \
 saramakiFAvLogNewton_test \
 saramakiFBvNewton_test \
 schurNSlattice_sqp_slb_lowpass_test \
 schurOneMAPlattice_frm_socp_slb_test \
 schurOneMAPlattice_frm_halfband_socp_slb_test \
 schurOneMAPlattice_frm_hilbert_socp_slb_test \
 schurOneMPAlattice_socp_slb_bandpass_test \
 schurOneMPAlattice_socp_slb_bandpass_hilbert_test \
 schurOneMPAlattice_socp_slb_lowpass_test \
 schurOneMR2lattice2Abcd_test \
 schurOneMlattice_bandpass_allocsd_test \
 schurOneMlattice_socp_slb_bandpass_test \
 schurOneMlattice_socp_slb_lowpass_test \
 schurOneMlattice_sqp_slb_bandpass_test \
 schurOneMlattice_sqp_slb_hilbert_test \
 schurOneMlattice_sqp_slb_lowpass_test \
 schur_retimed_test \
 sdp_relaxation_directFIRhilbert_12_nbits_test \
 sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test \
 sdp_relaxation_directFIRsymmetric_bandpass_10_nbits_test \
 sdp_relaxation_schurOneMlattice_bandpass_10_nbits_test \
 sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test \
 sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test \
 sedumi_test \
 simplex_schurNSPAlattice_lowpass_test \
 simplex_schurNSlattice_lowpass_test \
 simplex_schurOneMPAlattice_lowpass_test \
 simplex_schurOneMlattice_lowpass_test \
 simplex_svcasc_lowpass_test \
 socp_relaxation_directFIRhilbert_12_nbits_test \
 socp_relaxation_directFIRsymmetric_bandpass_12_nbits_test \
 socp_relaxation_schurFIRlattice_gaussian_16_nbits_test \
 socp_relaxation_schurOneMAPlattice_frm_12_nbits_test \
 socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test \
 socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test \
 socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test \
 socp_relaxation_schurOneMlattice_hilbert_10_nbits_test \
 sparsePOP_test \
 spectralfactor_test \
 sqp_bfgs_test \
 sqp_gi_test \
 sqp_relaxation_schurOneMlattice_bandpass_10_nbits_test \
 sqp_relaxation_schurOneMlattice_lowpass_10_nbits_test \
 surmaaho_lowpass_test \
 surmaaho_parallel_allpass_lowpass_test \
 sv2block_test \
 svcasc2noise_example_test \
 tarczynski_ex2_standalone_test \
 tfp2g_test \
 tfp2schurNSlattice2Abcd_test \
 vaidyanathan_trick_test \
 zahradnik_halfband_test \
 zolotarev_vlcek_unbehauen_test \
 zolotarev_vlcek_zahradnik_test

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
 qzsolve \
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
 schurOneMR2lattice schurOneMR2lattice_retimed complementary_FIR_filter \
 schur_OneMultiplierRetimed allpass_AL7c allpass_dir1 allpass_dir2 allpass_GM1 \
 allpass_GM2 allpass_IS allpass_LS1 allpass_LS2a allpass_MH2d allpass_MH2dt \
 allpass_MH3d allpass_MH3dt allpass_dir1_retimed allpass_MH2d_retimed \
 elliptic_unit_cell 

#
# clean suffixes
#
CLEAN_SUFFIXES= \~ .eps .diary .tmp .oct .mex .o .ok _coef.m _digits.m \
.spec -core .tab .out .results
CLEAN_TEX_SUFFIXES= .aux .bbl .blg .brf .dvi .out .toc .lof .lot .loa \
.log .synctex.gz 
CLEAN_AEGIS_SUFFIXES= \,D \,B

#
# Command definitions
#
OCTAVE_DIR?=/usr/local/octave
OCTAVE_FLAGS=-q -p src
OCTAVE=$(OCTAVE_DIR)/bin/octave-cli
MKOCTFILE=$(OCTAVE_DIR)/bin/mkoctfile
PDF_MONO_FLAGS='\newcommand\DesignOfIIRFiltersMono{}\input{DesignOfIIRFilters}'
PDFLATEX=pdflatex -interaction=nonstopmode --synctex=1
BIBTEX=bibtex
QPDF=qpdf
#XCXXFLAGS=-g -fsanitize=undefined -fsanitize=address -fno-sanitize=vptr \
#             -fno-omit-frame-pointer
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
	dia -t eps -e $@ $^ 

%.pdf : %.eps
	epstopdf $< 

# To test an octfile with address-sanitizer add these flags:
#    "-g -fsanitize=undefined -fsanitize=address -fno-sanitize=vptr \
#     -fno-omit-frame-pointer"
# and run with:
#   LD_PRELOAD=/usr/lib64/libasan.so.4 octave --eval "expr"
#
# Apparently, if the AddressSanitizer library is built without RTTI then
# there are many "vptr" false-positives.
#
# To test an octfile with oprofile, compile the octfile with '-g' then run:
#   operf octave file_test.m
#   opannotate --source file.oct
%.oct : %.cc
	$(MKOCTFILE) -v -o $@ -march=native -O2 -Wall $(XCXXFLAGS) -lgmp -lmpfr $^

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
  $(eval include src/$(octave_script).mk) \
  $(eval test_FIGURES+=$($(octave_script)_FIGURES)) \
  $(eval test_COEFS+=$($(octave_script)_COEFS)) \
  $(eval EXTRA_DIARY_FILES+=$($(octave_script)_EXTRA_DIARY_FILES)) \
  $(eval $(call octave_script_template,$(octave_script))))

$(foreach dia_file, $(DIA_FILES), $(eval $(call dia_template,$(dia_file))))

#
# Target file dependencies
#
$(TARGET).pdf: $(TARGET_DEPENDENCIES)
	$(PDFLATEX) $(TARGET) && \
	$(BIBTEX)   $(TARGET) && \
	$(PDFLATEX) $(TARGET) && \
	$(PDFLATEX) $(TARGET) && \
	$(PDFLATEX) $(TARGET)
	-@for warnstr in "No\ file" ull arning; do \
		grep "$$warnstr" DesignOfIIRFilters.log | sort | uniq ; \
	done ; \
	grep "arning" DesignOfIIRFilters.blg | sort | uniq ; \
	if test -e `which pdfgrep` ; then \
		pdfgrep "\[\?" DesignOfIIRFilters.pdf ; \
	fi; \
	echo "Build complete" ;

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

.PHONY: backup
backup: cleanall
	dir=`pwd` && tar -chjvf ~/`basename $$dir`.`date +%d%b%y`.tbz *

.PHONY: help
help: 
	@echo "Targets: all octfiles clean cleantex cleanall backup"
	@echo "         batchtest gitignore jekyll"

.PHONY: gitignore
gitignore:
	-rm -f .gitignore
	echo $(CLEAN_SUFFIXES:%="*"%) >> .gitignore
	echo $(CLEAN_TEX_SUFFIXES:%="*"%) >> .gitignore
	echo $(CLEAN_AEGIS_SUFFIXES:%="*"%) >> .gitignore
	echo $(test_FIGURES:%=%.tex) >> .gitignore
	echo $(test_FIGURES:%=%.pdf) >> .gitignore 
	echo $(test_COEFS) >> .gitignore
	echo $(EXTRA_DIARY_FILES) >> .gitignore
	echo $(DIA_FILES:%=%.pdf) >> .gitignore
	echo aegis.conf /$(TARGET).pdf >> .gitignore
	echo _site .sass-cache .jekyll-metadata >> .gitignore
	sed -i -e "s/\ /\n/g" .gitignore 

.PHONY: jekyll
jekyll: $(TARGET).pdf cleanjekyll
	if [[ -x $(QPDF) ]]; then \
		$(QPDF) --linearize $(TARGET).pdf docs/public/$(TARGET).pdf ; \
	else \
		cp -f $(TARGET).pdf docs/public/$(TARGET).pdf ; \
	fi
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

