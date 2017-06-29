EXTRA_DIARY_FILES += linesearch_test.diary.warning

linesearch_test.diary.warning : linesearch_test.diary
	egrep -v warning $^ > $@

linesearch_test_FILES = \
linesearch_test.m test_common.m print_polynomial.m print_pole_zero.m \
armijo_kim.m armijo.m goldensection.m goldstein.m quadratic.m sqp_common.m \
updateWbfgs.m updateWchol.m
