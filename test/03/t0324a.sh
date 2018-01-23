#!/bin/sh

prog=schurOneMPAlattice_socp_slb_bandpass_test.m
depends="schurOneMPAlattice_socp_slb_bandpass_test.m test_common.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m schurOneMAPlattice2Abcd.m tf2schurOneMlattice.m \
schurOneMscale.m local_max.m tf2pa.m print_polynomial.m \
Abcd2tf.m H2Asq.m H2T.m H2P.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct SeDuMi_1_3/"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test_A1k_coef.m << 'EOF'
A1k = [   0.2892623403,  -0.0722998682,   0.7673448879,   0.1218109095, ... 
         -0.1933815833,   0.3321992386,   0.0735610114,  -0.1828639681, ... 
          0.1128603061,   0.1706247610,  -0.1442749575,   0.1211757591 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k_coef.m"; fail; fi

cat > test_A1epsilon_coef.m << 'EOF'
A1epsilon = [ -1,  1,  1, -1, ... 
               1, -1, -1,  1, ... 
               1, -1, -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon_coef.m"; fail; fi

cat > test_A1p_coef.m << 'EOF'
A1p = [   0.7305157320,   0.9838877597,   1.0577910175,   0.3837916490, ... 
          0.4337718167,   0.5276147524,   0.7452089563,   0.8022006681, ... 
          0.9651687235,   0.8617452928,   1.0237931988,   0.8853483132 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1p_coef.m"; fail; fi

cat > test_A2k_coef.m << 'EOF'
A2k = [  -0.2524565293,  -0.3365991773,   0.7758894169,   0.1208763683, ... 
         -0.2397134389,   0.3162548649,   0.1325278942,  -0.1057222169, ... 
          0.1415626419,   0.1513870043,  -0.1733251864,   0.1098310926 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k_coef.m"; fail; fi

cat > test_A2epsilon_coef.m << 'EOF'
A2epsilon = [ -1,  1,  1, -1, ... 
               1, -1, -1,  1, ... 
               1, -1, -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon_coef.m"; fail; fi

cat > test_A2p_coef.m << 'EOF'
A2p = [   1.0668034407,   0.8241785424,   1.1698600095,   0.4155823729, ... 
          0.4692572571,   0.5992154400,   0.8313920462,   0.9499539650, ... 
          1.0563050520,   0.9159964438,   1.0669636162,   0.8955869704 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2p_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1k_coef.m schurOneMPAlattice_socp_slb_bandpass_test_A1k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k_coef.m"; fail; fi

diff -Bb test_A1epsilon_coef.m \
     schurOneMPAlattice_socp_slb_bandpass_test_A1epsilon_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon_coef.m"; fail; fi

diff -Bb test_A1p_coef.m schurOneMPAlattice_socp_slb_bandpass_test_A1p_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1p_coef.m"; fail; fi

diff -Bb test_A2k_coef.m schurOneMPAlattice_socp_slb_bandpass_test_A2k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k_coef.m"; fail; fi

diff -Bb test_A2epsilon_coef.m \
     schurOneMPAlattice_socp_slb_bandpass_test_A2epsilon_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon_coef.m"; fail; fi

diff -Bb test_A2p_coef.m schurOneMPAlattice_socp_slb_bandpass_test_A2p_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2p_coef.m"; fail; fi

#
# this much worked
#
pass

