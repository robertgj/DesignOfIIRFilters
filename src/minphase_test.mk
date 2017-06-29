minphase_test_FIGURES= \
minphase_test_brz_brzc_response \
minphase_test_cepstral_combined_response

minphase_test_FILES = minphase_test.m test_common.m  minphase.m

minphase.oct : EXTRA_CXXFLAGS=-Wno-misleading-indentation -I/usr/include/eigen3
