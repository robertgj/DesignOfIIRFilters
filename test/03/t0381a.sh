#!/bin/sh

prog=allpass_phase_socp_mmse_test.m
depends="allpass_phase_socp_mmse_test.m allpass_phase_socp_mmse.m \
test_common.m tf2x.m zp2x.m tf2a.m a2tf.m iirA.m iirT.m iirP.m fixResultNaN.m \
allpassP.m allpassT.m print_polynomial.m print_allpass_pole.m aConstraints.m \
qroots.m qzsolve.oct SeDuMi_1_3/"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test_a1_coef.ok << 'EOF'
% All-pass single-vector representation
Va1=1,Qa1=2,Ra1=1
a1 = [  -0.8501360569, ...
         0.5112528607, ...
         1.7874917758 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_8_nbits_cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.ok allpass_phase_socp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_8_nbits_cost.ok"; fail; fi

#
# this much worked
#
pass
