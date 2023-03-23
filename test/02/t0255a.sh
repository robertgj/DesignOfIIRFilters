#!/bin/sh

prog=schurOneMAPlattice_frm_halfband_socp_slb_test.m

depends="test/schurOneMAPlattice_frm_halfband_socp_slb_test.m \
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
k2 = [   0.5531474970,  -0.1244390352,   0.0416133287,  -0.0135756789, ... 
         0.0021334103 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_epsilon2_coef.m << 'EOF'
epsilon2 = [  1,  1, -1,  1, ... 
             -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon2_coef.m"; fail; fi

cat > test_u2_coef.m << 'EOF'
u2 = [  -0.0004599640,   0.0023567217,  -0.0070284251,   0.0129804885, ... 
        -0.0309283574,   0.0346723005,  -0.0508947335,   0.0580268416, ... 
         0.4385505465 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u2_coef.m"; fail; fi

cat > test_v2_coef.m << 'EOF'
v2 = [   0.0065942610,  -0.0044815273,   0.0066990076,  -0.0031543556, ... 
        -0.0069802168,   0.0307163651,  -0.0814993830,   0.3141056047 ]';
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

