#!/bin/sh

prog=schurOneMPAlattice_socp_slb_lowpass_differentiator_test.m

depends="test/schurOneMPAlattice_socp_slb_lowpass_differentiator_test.m \
test_common.m \
../tarczynski_parallel_allpass_lowpass_differentiator_test_Da0_coef.m \
../tarczynski_parallel_allpass_lowpass_differentiator_test_Db0_coef.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticedAsqdw.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMscale.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2Abcd.m \
local_max.m H2Asq.m H2T.m H2P.m H2dAsqdw.m print_polynomial.m delayz.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct Abcd2tf.oct qroots.oct"

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
cat > test.A1k2.ok << 'EOF'
A1k2 = [   0.0999744433,   0.9914105120,  -0.6780826485,   0.4789826243, ... 
          -0.3352880114,   0.2062056789,  -0.0903020971,   0.0204109759 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.A1k2.ok"; fail; fi

cat > test.A2k2.ok << 'EOF'
A2k2 = [   0.2387507967,   0.4747278063,   0.4538920676,  -0.5991576167, ... 
           0.5373044950,  -0.3901597171,   0.2033390227,  -0.0643364939, ... 
           0.0092813752 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.A2k2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlattice_socp_slb_lowpass_differentiator_test";

diff -Bb test.A1k2.ok $nstr"_A1k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.A1k2.ok"; fail; fi

diff -Bb test.A2k2.ok $nstr"_A2k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.A2k2.ok"; fail; fi

#
# this much worked
#
pass
