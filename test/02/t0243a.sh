#!/bin/sh

prog=iir_sqp_slb_pink_test.m

depends="test/iir_sqp_slb_pink_test.m \
../tarczynski_pink_test_D0_coef.m \
../tarczynski_pink_test_N0_coef.m \
test_common.m delayz.m print_polynomial.m \
print_pole_zero.m armijo_kim.m fixResultNaN.m \
iirA.m iirE.m iirP.m iirT.m invSVD.m \
local_max.m iir_sqp_mmse.m iir_slb.m iir_slb_exchange_constraints.m \
iir_slb_show_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_update_constraints.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m xConstraints.m tf2x.m zp2x.m x2tf.m \
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
cat > test_d1.ok << 'EOF'
Ud1=1,Vd1=1,Md1=10,Qd1=10,Rd1=1
d1 = [   0.0007847649, ...
        -2.7898326859, ...
         0.9603761920, ...
         0.5954738344,   0.8634508970,   0.9664216577,   3.1643155177, ... 
         3.2555424341, ...
         0.1529973957,   0.0383217294,   0.0288461345,   0.6944226529, ... 
         1.8837603478, ...
         0.3277267610,   0.3387753203,   0.5646355641,   0.8131311598, ... 
         0.9619069402, ...
         2.3946036767,   1.2002243116,   0.2832374746,   0.0252899558, ... 
         0.0205770419 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1.ok iir_sqp_slb_pink_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

