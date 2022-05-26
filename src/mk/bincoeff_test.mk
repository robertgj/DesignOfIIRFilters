bincoeff_test_FIGURES = bincoeff_test_roots bincoeff_test_qzsolve
bincoeff_test_FILES = bincoeff_test.m qzsolve.oct

src/qzsolve.oct : XCXXFLAGS= -lquadmath -fext-numeric-literals
