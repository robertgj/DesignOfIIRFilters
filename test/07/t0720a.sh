#!/bin/sh

prog=iir_sqp_slb_lowpass_R2_test.m

depends="test/iir_sqp_slb_lowpass_R2_test.m \
test_common.m print_polynomial.m xInitHd.m \
print_pole_zero.m iir_slb.m iir_sqp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m armijo_kim.m \
cl2bp.m fixResultNaN.m iirA.m iirE.m iirP.m iirT.m invSVD.m local_max.m \
showZPplot.m sqp_bfgs.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m"

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
cat > test.d1.ok << 'EOF'
Ud1=0,Vd1=0,Md1=12,Qd1=6,Rd1=2
d1 = [   0.0028845132, ...
         1.0003023818,   1.0056148719,   1.0144934348,   1.0190836996, ... 
         1.0227558014,   1.0244169054, ...
         0.9650107877,   1.2187197352,   2.4276185305,   2.5806769952, ... 
         1.9075833547,   2.9270112743, ...
         0.4522991375,   0.6589829899,   0.8905683607, ...
         0.4924931413,   1.1183530823,   1.3416993485 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="iir_sqp_slb_lowpass_R2_test"

diff -Bb test.d1.ok $nstr"_d1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.d1.ok"; fail; fi

#
# this much worked
#
pass
