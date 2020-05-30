#!/bin/sh

prog=saramakiFIRcascade_ApproxI_lowpass_test.m

depends="saramakiFIRcascade_ApproxI_lowpass_test.m test_common.m \
selesnickFIRsymmetric_lowpass.m directFIRsymmetricA.m \
halleyFIRsymmetricA.m chebyshevT.m chebyshevP.m lagrange_interp.m \
print_polynomial.m local_max.m local_peak.m xfr2tf.m"

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
cat > test_tap_coef.ok << 'EOF'
aN = [   0.3137313609,   1.2072011137,   0.9183896108,  -1.2711549242, ... 
        -1.4164223584,   0.5684985464,   0.6897566509 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_tap_coef.m "; fail; fi

cat > test_prototype_coef.ok << 'EOF'
hN = [   0.0107774477,   0.0177655796,  -0.0238617114,  -0.0700664677, ... 
         0.0371535282,   0.3045732560,   0.4573167353 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_prototype_coef.m "; fail; fi

cat > test_subfilter_coef.ok << 'EOF'
hM = [   0.0349913571,   0.1139326345,  -0.0329200706,  -0.0100592129, ... 
        -0.0267514167,  -0.0120584706,   0.0100933358,   0.0284182665, ... 
         0.0262381556,   0.0024703229,  -0.0273071240,  -0.0398277551, ... 
        -0.0215731935,   0.0186827541,   0.0524233219,   0.0497981852, ... 
         0.0028464710,  -0.0626863843,  -0.0973752026,  -0.0565442512, ... 
         0.0694019272,   0.2424103979,   0.3919484265,  -0.3131049496 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_subfilter_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_tap_coef.ok \
     saramakiFIRcascade_ApproxI_lowpass_test_tap_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_tap_coef.m"; fail; fi

diff -Bb test_prototype_coef.ok \
     saramakiFIRcascade_ApproxI_lowpass_test_prototype_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_prototype_coef.m"; fail; fi

diff -Bb test_subfilter_coef.ok \
     saramakiFIRcascade_ApproxI_lowpass_test_subfilter_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_subfilter_coef.m"; fail; fi

#
# this much worked
#
pass

