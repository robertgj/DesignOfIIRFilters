#!/bin/sh

prog=iir_sqp_slb_fir_bandpass_test.m

depends="iir_sqp_slb_fir_bandpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iirA.m iirE.m iirT.m iirP.m local_max.m iir_sqp_mmse.m iir_slb.m \
Aerror.m Terror.m armijo_kim.m fixResultNaN.m goldensection.m quadratic.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m invSVD.m xConstraints.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m showResponseBands.m tf2x.m zp2x.m x2tf.m \
showResponse.m showResponsePassBands.m showZPplot.m qroots.m qzsolve.oct"

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
Ud1=2,Vd1=0,Md1=28,Qd1=0,Rd1=1
d1 = [   0.0118898373, ...
         0.9687500000,   0.9687500000, ...
         0.7706482969,   0.7720155930,   0.8511678882,   0.8532692263, ... 
         0.9687500000,   0.9687500000,   0.9687500000,   0.9687500000, ... 
         0.9687500000,   0.9687500000,   0.9687500000,   0.9687500000, ... 
         0.9687500000,   0.9687500000, ...
         3.1409317024,   3.1377409792,   0.7996716560,   1.0546602168, ... 
         2.7611597648,   3.0547428487,   3.0795963114,   1.8934642422, ... 
         2.1072644531,   2.3430454955,   1.6610904530,   0.2379008206, ... 
         0.2978732184,   1.5874858044 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_fir_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

