#!/bin/sh

prog=iir_socp_mmse_test.m

depends="test/iir_socp_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_socp_mmse.m iir_slb_update_constraints.m iir_slb_show_constraints.m \
cl2bp.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m local_max.m zp2x.m x2tf.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m tf2x.m \
xConstraints.m iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
qroots.m qzsolve.oct"

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
x1 = [   0.0001620868,   0.0288748061,   1.9201929739,   2.0963077497, ... 
        -0.2822256158,   1.7053682785,   1.3637741283,   1.2741857506, ... 
         1.2741857537,   0.0000000000,   2.0731248601,   0.0068116357, ... 
         2.3028908331,   2.3060757598,   3.7837384645,   3.1415329089, ... 
         3.1417808375,   0.9551535829,   0.9687500008,  -0.1728700578, ... 
         0.7907625460,   1.0321808193,   3.6571032427,   3.5434792433, ... 
        -1.8025034995 ]';
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

