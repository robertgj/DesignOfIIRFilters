#!/bin/sh

prog=iir_sqp_slb_bandpass_test.m

depends="iir_sqp_slb_bandpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m iirP.m \
iirT.m invSVD.m local_max.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m"

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
d1 = [   0.0119781326, ...
        -0.9501855104,   0.9700299868, ...
         0.9804479114,   0.9805467038,   0.9820771057,   0.9824927256, ... 
         0.9838266661,   0.9929262243,   0.9947340864,   1.3537452101, ... 
         1.4193911854, ...
         2.6756962684,   2.1929278453,   2.4486799014,   1.9388563901, ... 
         1.7375703245,   0.2813703054,   1.5933065256,   0.8426117431, ... 
         1.0914178023, ...
         0.5675646352,   0.6204192910,   0.6463715135,   0.7112138600, ... 
         0.7464164828, ...
         1.9315692344,   2.4222482068,   1.3926168007,   2.7966923684, ... 
         1.0540496530 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
