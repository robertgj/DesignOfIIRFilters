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
d1 = [   0.0015347528, ...
         0.9831259171,   0.9865862455,   1.0000549581,   1.0588399235, ... 
         1.2178165199,   1.3676396170, ...
         2.4732268884,   1.2469818524,   0.9665196706,   2.0777243688, ... 
         2.7566056975,   2.9958632972, ...
         0.4293178287,   0.6391970557,   0.8827491826, ...
         0.4992229735,   1.1330235684,   1.3538904996 ]';
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
