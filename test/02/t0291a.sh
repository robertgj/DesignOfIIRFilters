#!/bin/sh

prog=schurOneMPAlattice_socp_mmse_test.m
depends="schurOneMPAlattice_socp_mmse_test.m test_common.m \
schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m schurOneMPAlatticeP.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice2tf.m schurOneMAPlattice2tf.m schurOneMAPlattice2Abcd.m \
local_max.m tf2pa.m print_polynomial.m \
Abcd2tf.m H2Asq.m H2T.m H2P.m tf2schurOneMlattice.m schurOneMscale.m \
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
cat > test_D1_coef.m << 'EOF'
D1 = [   1.0000000000,   0.7309833545,  -0.2731621170,  -0.3205248847, ... 
        -0.2368338585,  -0.0201303879,   0.0561600367,  -0.0644659350, ... 
         0.2463389383,   0.0748790460,  -0.1477063774,   0.0189328735 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D1_coef.m"; fail; fi

cat > test_D2_coef.m << 'EOF'
D2 = [   1.0000000000,   0.0743838609,  -0.4665818471,   0.2758208981, ... 
         0.1612365023,   0.1296340236,  -0.0723719480,  -0.2194905354, ... 
         0.2681122613,  -0.1008172442,  -0.1193099513,   0.1485284061, ... 
        -0.0751249966 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_D1_coef.m schurOneMPAlattice_socp_mmse_test_D1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D1_coef.m"; fail; fi

diff -Bb test_D2_coef.m schurOneMPAlattice_socp_mmse_test_D2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D2_coef.m"; fail; fi

#
# this much worked
#
pass

