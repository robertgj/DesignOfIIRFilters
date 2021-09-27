#!/bin/sh

prog=schurOneMAPlattice_frm_halfband_socp_slb_test.m

depends="schurOneMAPlattice_frm_halfband_socp_slb_test.m \
../tarczynski_frm_halfband_test_r0_coef.m \
../tarczynski_frm_halfband_test_aa0_coef.m \
test_common.m \
schurOneMAPlattice_frm_halfband_socp_mmse.m \
schurOneMAPlattice_frm_halfband_slb.m \
schurOneMAPlattice_frm_halfband_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_halfband_slb_exchange_constraints.m \
schurOneMAPlattice_frm_halfband_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_halfband_slb_show_constraints.m \
schurOneMAPlattice_frm_halfband_slb_update_constraints.m \
schurOneMAPlattice_frm_halfband_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_halfbandEsq.m schurOneMAPlattice_frm_halfbandT.m \
schurOneMAPlattice_frm_halfbandAsq.m schurOneMAPlatticeP.m \
schurOneMAPlatticeT.m tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m \
Abcd2tf.m tf2pa.m schurOneMscale.m H2Asq.m H2P.m H2T.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
local_max.m print_polynomial.m print_pole_zero.m \
qroots.m qzsolve.oct"

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
cat > test_k2_coef.m << 'EOF'
k2 = [   0.5532412762,  -0.1240057803,   0.0419179206,  -0.0134482066, ... 
         0.0021226631 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_epsilon2_coef.m << 'EOF'
epsilon2 = [  1,  1, -1,  1, ... 
             -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon2_coef.m"; fail; fi

cat > test_u2_coef.m << 'EOF'
u2 = [  -0.0005007721,   0.0023497970,  -0.0069745550,   0.0130219803, ... 
        -0.0310071583,   0.0345787213,  -0.0508633423,   0.0580413146, ... 
         0.4385600600 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u2_coef.m"; fail; fi

cat > test_v2_coef.m << 'EOF'
v2 = [   0.0066076597,  -0.0044664688,   0.0066943329,  -0.0030982759, ... 
        -0.0069797361,   0.0306382594,  -0.0815581412,   0.3142361699 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMAPlattice_frm_halfband_socp_slb_test"
diff -Bb test_k2_coef.m $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2_coef.m"; fail; fi

diff -Bb test_epsilon2_coef.m $nstr"_epsilon2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon2_coef.m"; fail; fi

diff -Bb test_u2_coef.m $nstr"_u2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u2_coef.m"; fail; fi

diff -Bb test_v2_coef.m $nstr"_v2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v2_coef.m"; fail; fi

#
# this much worked
#
pass

