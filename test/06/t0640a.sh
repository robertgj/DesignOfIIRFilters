#!/bin/sh

prog=iir_socp_slb_hilbert_R2_test.m
depends="test/iir_socp_slb_hilbert_R2_test.m \
../tarczynski_hilbert_R2_test_D0_coef.m \
../tarczynski_hilbert_R2_test_N0_coef.m \
test_common.m print_polynomial.m print_pole_zero.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
local_max.m iir_socp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
iir_slb_update_constraints.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m \
xConstraints.m tf2x.m zp2x.m x2tf.m qroots.oct"

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
Ud1=7,Vd1=4,Md1=4,Qd1=2,Rd1=2
d1 = [   0.0143272389, ...
        -2.3554105393,  -0.8241868064,  -0.7247906281,  -0.1758122320, ... 
         0.5309802615,   0.6980418742,   1.2086387233, ...
        -0.1717035446,   0.1907664683,   0.5554353848,   0.6683160625, ...
         2.1471556943,   2.3057682617, ...
         0.9947949807,   2.0702703087, ...
         0.2123841118, ...
         1.5675196971 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output test.d1.ok cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_hilbert_R2_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

