#!/bin/sh

prog=deczky3a_sqp_test.m

depends="test/deczky3a_sqp_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
armijo_kim.m \
fixResultNaN.m iirA.m iirE.m iirT.m iirP.m invSVD.m local_max.m iir_sqp_mmse.m \
iir_slb.m iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m sqp_bfgs.m \
updateWchol.m updateWbfgs.m xConstraints.m x2tf.m"

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
cat > test.ok << 'EOF'
Ud1=0,Vd1=0,Md1=10,Qd1=6,Rd1=1
d1 = [   0.0019384234, ...
         0.9605213189,   0.9740029718,   0.9937061599,   1.9512802273, ... 
         2.6128234661, ...
         2.8135156189,   2.2258286413,   1.9213235090,   0.7293668141, ... 
         0.0001870793, ...
         0.5185717755,   0.6136982888,   0.7296383737, ...
         0.3574817497,   1.0447104541,   1.4314407986 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok deczky3a_sqp_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
