#!/bin/sh

prog=schurOneMAPlattice_frm_halfband_socp_mmse_test.m

depends="test/schurOneMAPlattice_frm_halfband_socp_mmse_test.m test_common.m \
schurOneMAPlattice_frm_halfband_socp_mmse.m \
schurOneMAPlattice_frm_halfband_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_halfband_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_halfbandEsq.m schurOneMAPlattice_frm_halfbandT.m \
schurOneMAPlattice_frm_halfbandAsq.m schurOneMAPlatticeP.m \
schurOneMAPlatticeT.m tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m \
Abcd2tf.m tf2pa.m schurOneMscale.m H2Asq.m H2P.m H2T.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
print_polynomial.m print_pole_zero.m qroots.m qzsolve.oct"

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
cat > test_r1_coef.m << 'EOF'
r1 = [   1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
         0.0035706175,  -0.0098219303 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r1_coef.m"; fail; fi

cat > test_k1_coef.m << 'EOF'
k1 = [   0.5058213990,  -0.0784713968,   0.0091879026,   0.0081425563, ... 
        -0.0098219303 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_epsilon1_coef.m << 'EOF'
epsilon1 = [   0.5058213990,  -0.0784713968,   0.0091879026,   0.0081425563, ... 
              -0.0098219303 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon1_coef.m"; fail; fi

cat > test_u1_coef.m << 'EOF'
u1 = [  -0.0019232288,   0.0038937068,  -0.0073554558,   0.0124707197, ... 
        -0.0274067156,   0.0373112692,  -0.0500281266,   0.0547645647, ... 
         0.4439780707 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u1_coef.m"; fail; fi

cat > test_v1_coef.m << 'EOF'
v1 = [   0.0038703625,  -0.0055310972,   0.0065538587,   0.0002190941, ... 
        -0.0109227368,   0.0338245953,  -0.0817426036,   0.3116242327 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMAPlattice_frm_halfband_socp_mmse_test"
diff -Bb test_r1_coef.m $nstr"_r1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r1_coef.m"; fail; fi

diff -Bb test_k1_coef.m $nstr"_k1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.m"; fail; fi

diff -Bb test_epsilon1_coef.m $nstr"_epsilon1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon1_coef.m"; fail; fi

diff -Bb test_u1_coef.m $nstr"_u1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u1_coef.m"; fail; fi

diff -Bb test_v1_coef.m $nstr"_v1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v1_coef.m"; fail; fi

#
# this much worked
#
pass

