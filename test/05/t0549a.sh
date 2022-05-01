#!/bin/sh

prog=iir_sqp_slb_lowpass_differentiator_test.m

depends="iir_sqp_slb_lowpass_differentiator_test.m \
../tarczynski_lowpass_differentiator_test_N0_coef.m \
../tarczynski_lowpass_differentiator_test_D0_coef.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_exchange_constraints.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m \
iirT.m iirP.m invSVD.m local_max.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m zp2x.m tf2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m \
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
cat > test_d1.ok << 'EOF'
Ud1=3,Vd1=1,Md1=8,Qd1=10,Rd1=1
d1 = [   0.0020937118, ...
        -1.4320103688,   1.0000000000,   1.7769542851, ...
         0.5341826058, ...
         0.9569910013,   0.9673039288,   0.9780719760,   1.7178633145, ...
         2.2172081829,   1.2234873349,   1.6446495774,   0.7004549010, ...
         0.5995830265,   0.6252324677,   0.7043856948,   0.9327785112, ... 
         0.9687500000, ...
         0.4093616854,   0.9069511669,   1.1798642092,   1.3618030791, ... 
         1.2247512242 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1.ok iir_sqp_slb_lowpass_differentiator_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d1.ok"; fail; fi


#
# this much worked
#
pass

