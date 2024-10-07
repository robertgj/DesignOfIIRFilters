lzsolve_test_FIGURES=

lzsolve_test_COEFS= 

lzsolve_test_FILES= lzsolve_test.m test_common.m check_octave_file.m lzsolve.oct

src/lzsolve.oct : MKOCTFILE_FLAGS+=-lqlapack -lqblas
