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
H2Asq.m H2P.m H2T.m H2dAsqdw.m tf2Abcd.m print_polynomial.m delayz.m \
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
k1 = [  -0.9073833932,   0.9058282212,  -0.8984820471,   0.8496113825, ... 
        -0.6556082085,   0.3126325918,  -0.0197329247 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_c1_coef.m << 'EOF'
c1 = [   0.4733218433,   0.2810219838,   1.0075291178,   0.1037638146, ... 
         0.0696348210,  -0.0334325076,  -0.0395727063,  -0.0326796331 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c1_coef.m"; fail; fi

cat > test_kk1_coef.m << 'EOF'
kk1 = [  -0.8765003127,  -0.8095119761,  -0.7535056287,  -0.5332391881, ... 
         -0.2184706150,  -0.0045560288 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kk1_coef.m"; fail; fi

cat > test_ck1_coef.m << 'EOF'
ck1 = [   0.2431112245,   0.0000000000,   0.1309104015,   0.0000000000, ... 
         -0.0063383279,   0.0000000000 ]';
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

