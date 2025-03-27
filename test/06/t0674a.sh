#!/bin/sh

prog=schurOneMlatticePipelined_socp_mmse_test.m

depends="test/schurOneMlatticePipelined_socp_mmse_test.m test_common.m \
schurOneMlatticePipelined_socp_mmse.m \
schurOneMlatticePipelined_slb_set_empty_constraints.m \
schurOneMlatticePipelined2Abcd.m \
schurOneMlatticePipelinedEsq.m \
schurOneMlatticePipelinedAsq.m \
schurOneMlatticePipelinedT.m \
schurOneMlatticePipelinedP.m \
schurOneMlatticePipelineddAsqdw.m \
tf2schurOneMlattice.m tf2schurOneMlatticePipelined.m schurOneMscale.m \
H2Asq.m H2P.m H2T.m H2dAsqdw.m tf2Abcd.m print_polynomial.m \
Abcd2H.oct Abcd2tf.oct schurOneMlattice2Abcd.oct schurdecomp.oct \
schurexpand.oct"

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
k1 = [  -0.8999837938,   0.8195585679,  -0.9716946445,   0.8482263571, ... 
        -0.9118265820,   0.8457912075,  -0.6180400601,   0.4036905590, ... 
        -0.0707006590,   0.0522330374 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_c1_coef.m << 'EOF'
c1 = [  -0.2234903012,   0.2370491735,   1.8226674573,   0.2230127962, ... 
         0.4541478181,   0.0548929922,  -0.0081407816,  -0.0492729014, ... 
        -0.0722788942,  -0.0556796552,  -0.0297505864 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c1_coef.m"; fail; fi

cat > test_kk1_coef.m << 'EOF'
kk1 = [  -0.9888854742,  -0.8971909861,  -0.9212305326,  -0.6813558123, ... 
         -0.7316167458,  -0.5232645374,  -0.3193228679,  -0.0195288051, ... 
          0.0305311926 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kk1_coef.m"; fail; fi

cat > test_ck1_coef.m << 'EOF'
ck1 = [   0.1921691026,  -1.6980370526,   0.1183579327,  -0.3543530692, ... 
          0.1783637346,  -0.0159002840,   0.0087781547,  -0.0000323642, ... 
         -0.0037589588 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ck1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k1_coef.m schurOneMlatticePipelined_socp_mmse_test_k1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.m"; fail; fi

diff -Bb test_c1_coef.m schurOneMlatticePipelined_socp_mmse_test_c1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c1_coef.m"; fail; fi

diff -Bb test_kk1_coef.m schurOneMlatticePipelined_socp_mmse_test_kk1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_kk1_coef.m"; fail; fi

diff -Bb test_ck1_coef.m schurOneMlatticePipelined_socp_mmse_test_ck1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ck1_coef.m"; fail; fi

#
# this much worked
#
pass

