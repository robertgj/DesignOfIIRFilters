#!/bin/sh

prog=schurOneMPAlatticeDoublyPipelinedDelay_kyp_LeeHu_lowpass_test.m
depends="test/schurOneMPAlatticeDoublyPipelinedDelay_kyp_LeeHu_lowpass_test.m \
schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_start.m \
schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_update.m \
schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_finish.m \
test_common.m \
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
schurOneMAPlatticeDoublyPipelined2Abcd.m \
schurOneMAPlatticeDoublyPipelined2H.m \
schurOneMPAlatticeDoublyPipelinedAsq.m \
schurOneMPAlatticeDoublyPipelinedEsq.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMPAlatticeDelay_wise_lowpass.m \
schurOneMscale.m local_max.m tf2pa.m print_polynomial.m \
Abcd2tf.m tf2Abcd.m H2Asq.m H2T.m H2P.m WISEJ_DA.m delayz.m \
Abcd2H.oct schurdecomp.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test_k_coef.m << 'EOF'
k = [  -0.5767489048,   0.3940083133,   0.2182357105,   0.0899134474, ... 
        0.0212450550 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr="schurOneMPAlatticeDoublyPipelinedDelay_kyp_LeeHu_lowpass_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k_coef.m $nstr"_k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k_coef.m"; fail; fi

#
# this much worked
#
pass

