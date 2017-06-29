#!/bin/sh

prog=iir_sqp_slb_hilbert_test.m

depends="iir_sqp_slb_hilbert_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
Aerror.m Terror.m Perror.m armijo_kim.m fixResultNaN.m \
iirA.m iirE.m iirP.m iirP_hessP_DiagonalApprox.m iirT.m invSVD.m \
local_max.m iir_sqp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
iir_slb_update_constraints.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m updateWchol.m updateWbfgs.m \
xConstraints.m tf2x.m x2tf.m"
tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
Ud1=7,Vd1=2,Md1=4,Qd1=4,Rd1=2
d1 = [  -0.0125534624, ...
        -2.4112464683,   1.2021616747,   0.5756082996,  -0.8253308539, ... 
        -0.6588645220,   0.5783866727,  -0.1637264415, ...
         0.6855081703,  -0.0953723689, ...
         2.3675675404,   2.2137974443, ...
         2.0588908825,   1.0189218691, ...
         0.1998070736,   0.3441380790, ...
         1.9143778104,  -0.0320242450 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_hilbert_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

