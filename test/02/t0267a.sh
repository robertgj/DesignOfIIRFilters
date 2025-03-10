#!/bin/sh

prog=schurOneMAPlattice_frm_hilbert_socp_mmse_test.m

depends="test/schurOneMAPlattice_frm_hilbert_socp_mmse_test.m test_common.m \
schurOneMAPlattice_frm_hilbert_socp_mmse.m \
schurOneMAPlattice_frm_hilbert_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_hilbert_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_hilbertEsq.m schurOneMAPlattice_frm_hilbertT.m \
schurOneMAPlattice_frm_hilbertAsq.m schurOneMAPlattice_frm_hilbertP.m \
schurOneMAPlatticeP.m schurOneMAPlatticeT.m tf2schurOneMlattice.m \
schurOneMAPlattice2Abcd.m Abcd2tf.m tf2pa.m schurOneMscale.m \
H2Asq.m H2P.m H2T.m schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
print_polynomial.m print_pole_zero.m qroots.oct"

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
cat > test_k1_coef.m << 'EOF'
k1 = [  -0.5099436897,  -0.0872481082,  -0.0155261157,   0.0041218038, ... 
         0.0081475995 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_u1_coef.m << 'EOF'
u1 = [  -0.0009414888,  -0.0035972626,  -0.0084814489,  -0.0139396819, ... 
        -0.0260180192,  -0.0354290821,  -0.0470579277,  -0.0524673226, ... 
         0.4454570629 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u1_coef.m"; fail; fi

cat > test_v1_coef.m << 'EOF'
v1 = [   0.0030475645,   0.0038389395,   0.0045772678,  -0.0005084086, ... 
        -0.0120880178,  -0.0353881633,  -0.0848593894,  -0.3122680929 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k1_coef.m schurOneMAPlattice_frm_hilbert_socp_mmse_test_k1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.m"; fail; fi

diff -Bb test_u1_coef.m schurOneMAPlattice_frm_hilbert_socp_mmse_test_u1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u1_coef.m"; fail; fi

diff -Bb test_v1_coef.m schurOneMAPlattice_frm_hilbert_socp_mmse_test_v1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v1_coef.m"; fail; fi

#
# this much worked
#
pass

