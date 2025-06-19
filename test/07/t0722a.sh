#!/bin/sh

prog=schurOneMlattice_kyp_Dinh_lowpass_R2_test.m
depends="test/schurOneMlattice_kyp_Dinh_lowpass_R2_test.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeP.m \
schurOneMlatticeT.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice2tf.m \
schurOneMlattice2Abcd.m \
schurOneMR2lattice2Abcd.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
tf_wise_lowpass.m local_max.m tf2pa.m print_polynomial.m \
Abcd2tf.m tf2Abcd.m H2Asq.m H2T.m H2P.m WISEJ.m delayz.m \
Abcd2H.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct"

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
k = [   0.0000000000,  -0.3709291459,   0.0000000000,   0.5995266555, ... 
        0.0000000000,  -0.3228875589,   0.0000000000,   0.1375876146 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m"; fail; fi

cat > test_c_coef.m << 'EOF'
c = [  -0.0059237030,   0.1083595957,   0.1621684100,   0.1799780728, ... 
        0.2657098972,   0.1704985791,   0.0541938219,   0.0127833150, ... 
       -0.0049715841 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr="schurOneMlattice_kyp_Dinh_lowpass_R2_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k_coef.m $nstr"_k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k_coef.m"; fail; fi

diff -Bb test_c_coef.m $nstr"_c_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c_coef.m"; fail; fi


#
# this much worked
#
pass

