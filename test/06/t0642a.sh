#!/bin/sh

prog=schurOneMlattice_socp_slb_lowpass_differentiator_R2_test.m

depends="test/schurOneMlattice_socp_slb_lowpass_differentiator_R2_test.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_socp_slb_lowpass_plot.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
local_max.m tf2pa.m x2tf.m Abcd2tf.m tf2Abcd.m H2Asq.m H2T.m H2P.m \
print_polynomial.m WISEJ.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct qroots.m qzsolve.oct"

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
cat > test.k2.ok << 'EOF'
k2 = [   0.0000000000,   0.1889539538,   0.0000000000,  -0.0284766905, ... 
         0.0000000000,   0.0116932149,   0.0000000000,  -0.0104124204, ... 
         0.0000000000,   0.0127069920 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0123978535,  -0.2265628385,  -0.3095745305,  -0.0203101092, ... 
         0.0869340779,  -0.0349290725,  -0.0231821198,   0.0311422815, ... 
        -0.0069378944,  -0.0117026096,   0.0087826337 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_socp_slb_lowpass_differentiator_R2_test";

diff -Bb test.k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k2.ok"; fail; fi

diff -Bb test.c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c2.ok"; fail; fi

#
# this much worked
#
pass
