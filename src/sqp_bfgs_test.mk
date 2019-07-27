sqp_bfgs_test_EXTRA_DIARY_FILES=sqp_bfgs_test.diary.SQP

sqp_bfgs_test.diary.SQP : sqp_bfgs_test.diary
	grep SQP $^ > $@

sqp_bfgs_test_FILES = \
sqp_bfgs_test.m test_common.m print_polynomial.m print_pole_zero.m \
armijo.m armijo_kim.m goldensection.m goldfarb_idnani.m \
goldstein.m invSVD.m quadratic.m sqp_bfgs.m \
sqp_common.m updateWbfgs.m updateWchol.m
