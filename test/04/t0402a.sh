#!/bin/sh

prog=schurOneMAPlattice_frm_socp_mmse_test.m

depends=" schurOneMAPlattice_frm_socp_mmse_test.m test_common.m \
schurOneMAPlattice_frm_socp_mmse.m \
schurOneMAPlattice_frm_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_slb_set_empty_constraints.m \
schurOneMAPlattice_frm.m \
schurOneMAPlattice_frmEsq.m schurOneMAPlattice_frmT.m \
schurOneMAPlattice_frmAsq.m schurOneMAPlattice_frmP.m \
schurOneMAPlatticeP.m schurOneMAPlatticeT.m tf2schurOneMlattice.m \
schurOneMAPlattice2Abcd.m Abcd2tf.m tf2pa.m schurOneMscale.m \
H2Asq.m H2P.m H2T.m schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
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
cat > test_k1_coef.m << 'EOF'
k1 = [   0.2112977157,   0.5211716121,  -0.1369832335,  -0.0408377003, ... 
         0.0535597550,  -0.0253686205,   0.0139648860,  -0.0088973953, ... 
         0.0048998110,   0.0008152451 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_u1_coef.m << 'EOF'
u1 = [   0.6396848074,   0.2922132733,  -0.1196523640,  -0.0659678722, ... 
         0.0770863749,  -0.0007048649,  -0.0478673797,   0.0476098294, ... 
         0.0325119367,  -0.0662492193,   0.0042534730,   0.0503806006, ... 
        -0.0072427204,  -0.0174327228,   0.0177086039,   0.0018191769, ... 
        -0.0281259248,   0.0008538825,   0.0325772515,  -0.0119745985, ... 
        -0.0159712382 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u1_coef.m"; fail; fi

cat > test_v1_coef.m << 'EOF'
v1 = [  -0.0314213168,  -0.0717746911,   0.0679669032,  -0.0079431625, ... 
        -0.0537453216,   0.0586142497,  -0.0094629305,  -0.0827786886, ... 
         0.1765889790,   0.4802014692,   0.1396037176,  -0.0420930715, ... 
        -0.0082166209,   0.0010174935,   0.0115319596,  -0.0080870769, ... 
        -0.0241971421,   0.0645002446,   0.1856577650,   0.0620672869, ... 
        -0.0217278606 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k1_coef.m schurOneMAPlattice_frm_socp_mmse_test_k1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.m"; fail; fi

diff -Bb test_u1_coef.m schurOneMAPlattice_frm_socp_mmse_test_u1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u1_coef.m"; fail; fi

diff -Bb test_v1_coef.m schurOneMAPlattice_frm_socp_mmse_test_v1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v1_coef.m"; fail; fi

#
# this much worked
#
pass

