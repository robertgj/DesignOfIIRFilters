#!/bin/sh

prog=deczky3_piqp_test.m

depends="test/deczky3_piqp_test.m \
test_common.m print_polynomial.m print_pole_zero.m fixResultNaN.m \
iirA.m iirE.m iirT.m iirP.m local_max.m iir_piqp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m xConstraints.m x2tf.m"

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
d1 = [   0.0025594754, ...
         1.0176154892,   1.0304943799,   1.3492655764,   1.8195349657, ... 
         2.3550885228, ...
         2.0577696928,   2.7532640563,   1.7692102743,   0.7062974351, ... 
         0.0001056239, ...
         0.5062682341,   0.5968927768,   0.6512637223, ...
         0.3446438636,   1.0617080491,   1.4210108400 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok deczky3_piqp_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
