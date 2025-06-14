#!/bin/sh

prog=iir_socp_slb_lowpass_R2_test.m

depends="test/iir_socp_slb_lowpass_R2_test.m \
test_common.m iir_socp_mmse.m iir_slb.m iir_slb_exchange_constraints.m \
iir_slb_show_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_update_constraints.m \
local_max.m xConstraints.m x2tf.m xInitHd.m iirA.m iirE.m iirP.m iirT.m \
fixResultNaN.m print_polynomial.m print_pole_zero.m showZPplot.m"

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
d1 = [   0.0034966427, ...
         0.9977358567,   0.9996098640,   0.9999984551,   0.9999993691, ... 
         1.0000234922,   1.0000530201, ...
         0.9623337038,   1.7893116877,   1.1609939282,   2.4246470024, ... 
         2.9628683136,   2.5898388944, ...
         0.4846775314,   0.6841759164,   0.8991355655, ...
         0.4891849365,   1.1124996121,   1.3338403119 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.cost.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="iir_socp_slb_lowpass_R2_test"

diff -Bb test.d1.ok $nstr"_d1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.d1.ok"; fail; fi

#
# this much worked
#
pass
