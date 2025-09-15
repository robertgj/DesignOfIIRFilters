#!/bin/sh

prog=schurOneMlattice_socp_slb_lowpass_differentiator_R2_test.m

depends="test/schurOneMlattice_socp_slb_lowpass_differentiator_R2_test.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
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
local_max.m tf2pa.m x2tf.m tf2Abcd.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
print_polynomial.m WISEJ.m qroots.oct \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct Abcd2tf.oct Abcd2H.oct"

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
k2 = [   0.0000000000,   0.2065205470,   0.0000000000,  -0.0281020445, ... 
         0.0000000000,   0.0093023973,   0.0000000000,  -0.0038787444, ... 
         0.0000000000,   0.0012820857 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [  -0.0212083759,  -0.2188914462,  -0.2870345994,  -0.0306418043, ... 
         0.0731356951,  -0.0170264555,  -0.0231060228,   0.0170587049, ... 
         0.0012358212,  -0.0062679753,   0.0022181847 ]';
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
