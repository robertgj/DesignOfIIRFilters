qroots_test_FIGURES =

qroots_test_COEFS = qroots_test_coef.m

qroots_test_FILES = qroots_test.m test_common.m check_octave_file.m \
print_pole_zero.m tf2x.m zp2x.m qroots.oct

src/qroots.oct : XCXXFLAGS= -lquadmath -fext-numeric-literals
