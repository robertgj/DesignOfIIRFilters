#!/bin/sh

prog=iir_sqp_slb_fir_lowpass_test.m

depends="test/iir_sqp_slb_fir_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_set_empty_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m invSVD.m \
local_max.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m tf2x.m zp2x.m updateWchol.m \
updateWbfgs.m x2tf.m xConstraints.m qroots.m qzsolve.oct"

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
Ud1=0,Vd1=0,Md1=60,Qd1=0,Rd1=1
d1 = [   0.0005245855, ...
         0.4408050463,   0.8271665824,   0.8335930090,   0.8356698033, ... 
         0.8412453942,   0.8533284597,   0.8650523125,   0.8928995537, ... 
         0.9929307671,   0.9931369438,   0.9940083994,   0.9942130157, ... 
         0.9952210441,   0.9966122032,   0.9978841768,   0.9981251603, ... 
         0.9997431125,   1.0015336919,   1.0033705551,   1.0056909243, ... 
         1.0078237139,   1.0113222642,   1.0136258014,   1.0198384937, ... 
         1.0229081132,   1.0338388941,   1.3492160094,   1.4055874816, ... 
         1.4393341465,   1.4395686865, ...
         0.0030997651,   0.0752027667,   0.2260015439,   0.3770449168, ... 
         0.5231833763,   0.6653286094,   0.8091017069,   0.9523560432, ... 
         1.4143111197,   1.5078506301,   1.6060908730,   1.3308426389, ... 
         1.7068749416,   1.8093477015,   1.2709336763,   1.9129333538, ... 
         2.0174043115,   2.1226736666,   2.2290695400,   2.3364386330, ... 
         2.4452001856,   2.5563637643,   2.6703384656,   2.7891475778, ... 
         2.9174607184,   3.0613505046,   3.1415926534,   0.6634268131, ... 
         0.2188968967,   3.1415926533 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_sqp_slb_fir_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
