sedumi_profiler_test_EXTRA_DIARY_FILES=sedumi_profiler_test.info

sedumi_profiler_test_FILES = sedumi_profiler_test.m

sedumi_profiler_test.info : sedumi_profiler_test.diary
	awk '/Function Attr/ {found=1}; found {print}' $< > $@
