bitflip_bandpass_NS_lattice_test_FIGURES=bitflip_bandpass_NS_lattice_response 

bitflip_bandpass_NS_lattice_test_COEFS = \
bitflip_bandpass_NS_lattice_test.mat \
bitflip_bandpass_NS_lattice_test_s10_bfsd_coef.m \
bitflip_bandpass_NS_lattice_test_s11_bfsd_coef.m \
bitflip_bandpass_NS_lattice_test_s20_bfsd_coef.m \
bitflip_bandpass_NS_lattice_test_s00_bfsd_coef.m \
bitflip_bandpass_NS_lattice_test_s02_bfsd_coef.m \
bitflip_bandpass_NS_lattice_test_s22_bfsd_coef.m \
bitflip_bandpass_NS_lattice_test_cost.tab \
bitflip_bandpass_NS_lattice_test_adders.tab

bitflip_bandpass_NS_lattice_test_FILES = \
bitflip_bandpass_NS_lattice_test.m test_common.m \
bitflip_bandpass_test_common.m schurNSlattice2tf.m SDadders.m \
schurNSlattice_cost.m schurNSscale.oct schurdecomp.oct schurexpand.oct \
schurNSlattice2Abcd.oct Abcd2tf.m tf2schurNSlattice.m bin2SD.oct flt2SD.m \
x2nextra.m bitflip.oct print_polynomial.m bin2SPT.oct
