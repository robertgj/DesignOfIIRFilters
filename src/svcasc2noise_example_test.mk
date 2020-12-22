svcasc2noise_example_test_FIGURES=\
svcasc2noise_lowpass_response svcasc2noise_highpass_response

svcasc2noise_example_test_COEFS=\
svcasc2noise_butterworth_20_low_section_noise_gain.tab \
svcasc2noise_butterworth_20_high_section_noise_gain.tab \
svcasc2noise_butterworth_20_low_overall_noise_gain.tab \
svcasc2noise_butterworth_20_high_overall_noise_gain.tab \
svcasc2noise_butterworth_20_low_noise_simulation.tab \
svcasc2noise_butterworth_20_high_noise_simulation.tab 

svcasc2noise_example_test_FILES = \
svcasc2noise_example_test.m test_common.m \
svcasc2noise.m butter2pq.m pq2svcasc.m pq2blockKWopt.m \
svcasc2Abcd.m KW.m optKW2.m optKW.m svcascf.m svf.m crossWelch.m \
p2n60.m qroots.m qzsolve.oct
