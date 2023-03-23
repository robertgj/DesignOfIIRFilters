#!/bin/sh

prog=iir_socp_slb_bandpass_test.m

depends="test/iir_socp_slb_bandpass_test.m test_common.m \
../tarczynski_bandpass_test_x_coef.m \
print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m x2tf.m xConstraints.m \
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
cat > test.ok << 'EOF'
Ud1=2,Vd1=0,Md1=18,Qd1=10,Rd1=2
d1 = [   0.0199936670, ...
        -0.4571629443,   1.0570484535, ...
         0.9871000123,   0.9879559641,   0.9887744461,   0.9942778916, ... 
         0.9970865175,   1.0086318346,   1.0531298099,   1.2866446545, ... 
         1.2890907172, ...
         0.2822099075,   1.7626539703,   1.9839101447,   2.2896144657, ... 
         1.5982821434,   2.5227424547,   2.9031988368,   0.7774589684, ... 
         1.1094077441, ...
         0.5908883292,   0.6094930155,   0.6399358181,   0.7049597851, ... 
         0.7380112220, ...
         2.4583962833,   1.8619204494,   1.2710092987,   2.7532960159, ... 
         0.9759255590 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_socp_slb_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
