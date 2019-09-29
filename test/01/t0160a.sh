#!/bin/sh

prog=allpass2ndOrderCascadeDelay_socp_test.m

depends="allpass2ndOrderCascadeDelay_socp_test.m \
test_common.m stability2ndOrderCascade.m print_polynomial.m \
allpass2ndOrderCascade.m allpass2ndOrderCascadeDelay_socp.m \
local_max.m fixResultNaN.m casc2tf.m tf2casc.m qroots.m qzsolve.oct SeDuMi_1_3/"

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
cat > test_a1_coef.m << 'EOF'
a1 = [  -0.4212475191,   1.0771982506,   0.3177671212,  -1.0446316296, ... 
         0.3104468932,   0.7163932591,   0.3312240914,   0.0836798442, ... 
         0.3761881148,  -0.9054554964,   0.8005915009 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

cat > test_a1sqm_coef.m << 'EOF'
a1sqm = [  -0.8079712556,   0.7379074511,   0.1462308074,  -0.1919638180, ... 
            0.2801222740,   0.5463645207,   0.1500432850,   0.2645641440, ... 
            0.1733748910,  -1.0781165851,   0.8564450529 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1sqm_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m allpass2ndOrderCascadeDelay_socp_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

diff -Bb test_a1sqm_coef.m allpass2ndOrderCascadeDelay_socp_test_a1sqm_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1sqm_coef.m"; fail; fi


#
# this much worked
#
pass

