minphase_test_FIGURES= \
minphase_test_brz_brzc_response \
minphase_test_cepstral_combined_response

minphase_test_FILES = minphase_test.m test_common.m minphase.m
# Add minphase.oct to minphase_test_FILES to build octfile (assumes eigen3)

src/minphase.oct : XCXXFLAGS= -I/usr/include/eigen3 
