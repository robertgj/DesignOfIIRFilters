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
D1 = [   1.0000000000,   0.7309833543,  -0.2731621091,  -0.3205248816, ... 
        -0.2368338586,  -0.0201303939,   0.0561600330,  -0.0644659335, ... 
         0.2463389326,   0.0748790434,  -0.1477063778,   0.0189328709 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D1_coef.m"; fail; fi

cat > test_D2_coef.m << 'EOF'
D2 = [   1.0000000000,   0.0743838592,  -0.4665818476,   0.2758208874, ... 
         0.1612365026,   0.1296340237,  -0.0723719460,  -0.2194905347, ... 
         0.2681122515,  -0.1008172434,  -0.1193099518,   0.1485283998, ... 
        -0.0751249982 ];
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

