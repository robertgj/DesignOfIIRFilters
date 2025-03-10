minphase_test_FIGURES= \
minphase_test_simulated_response \
minphase_test_brz_brzc_response \
minphase_test_brzc_zeros \
minphase_test_cepstral_combined_response

minphase_test_COEFS= \
minphase_test_brz_coef.m \
minphase_test_brzc_coef.m \
minphase_test_k_coef.m \
minphase_test_khat_coef.m \
minphase_test_spec.m

# Add minphase.oct to minphase_test_FILES to build octfile (assumes eigen3)
minphase_test_FILES = minphase_test.m test_common.m minphase.m \
direct_form_scale.m complementaryFIRlatticeFilter.m crossWelch.m \
complementaryFIRdecomp.oct qroots.oct \
# minphase.oct
