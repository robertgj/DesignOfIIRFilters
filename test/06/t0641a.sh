#!/bin/sh

prog=iir_socp_slb_lowpass_differentiator_test.m

depends="test/iir_socp_slb_lowpass_differentiator_test.m \
../tarczynski_lowpass_differentiator_test_N0_coef.m \
../tarczynski_lowpass_differentiator_test_D0_coef.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_exchange_constraints.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
fixResultNaN.m iirA.m iirE.m iirT.m iirP.m local_max.m showZPplot.m \
zp2x.m tf2x.m x2tf.m xConstraints.m qroots.m \
qzsolve.oct"

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
cat > test_d1z.ok << 'EOF'
Ud1z=2,Vd1z=1,Md1z=10,Qd1z=10,Rd1z=1
d1z = [   0.0023951162, ...
         -1.1049079725,   1.0000000000, ...
          0.4642018165, ...
          0.8578420939,   1.1224301744,   1.6708540412,   1.8577157726, ... 
          1.9756793005, ...
          2.6013504796,   2.6638740913,   1.5271870389,   0.8309831824, ... 
          0.3697122913, ...
          0.2907584361,   0.2982873927,   0.5517846130,   0.6916003063, ... 
          0.9157796254, ...
          0.3757904876,   0.9520007744,   1.2277555727,   1.8467624265, ... 
          2.1359278920 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d1z.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1z.ok iir_socp_slb_lowpass_differentiator_test_d1z_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d1z.ok"; fail; fi

#
# this much worked
#
pass

