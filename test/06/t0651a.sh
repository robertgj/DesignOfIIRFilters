#!/bin/sh

prog=iir_socp_mmse_test.m

depends="test/iir_socp_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_socp_mmse.m iir_slb_update_constraints.m iir_slb_show_constraints.m \
cl2bp.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m local_max.m zp2x.m x2tf.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m tf2x.m \
xConstraints.m iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
qroots.oct"

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
cat > test_x1_coef.ok << 'EOF'
x1 = [   0.0001625213,   0.0288699348,   1.9210795913,   2.0965669005, ... 
        -0.2823248418,   1.7056191633,   1.3639292701,   1.2743225339, ... 
         1.2743225370,   0.0000000000,   2.0722639517,   0.0070243274, ... 
         2.3030910325,   2.3060277134,   3.7836794517,   3.1415329168, ... 
         3.1417808127,   0.9552267685,   0.9687500020,  -0.1742022468, ... 
         0.7904839516,   1.0307265478,   3.6571419229,   3.5433853858, ... 
        -1.8016366837 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x1_coef.ok iir_socp_mmse_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1_coef.ok"; fail; fi


#
# this much worked
#
pass

