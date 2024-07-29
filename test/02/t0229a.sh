#!/bin/sh

prog=deczky1_sqp_test.m

depends="test/deczky1_sqp_test.m ../tarczynski_deczky1_test_x0_coef.m \
test_common.m delayz.m deczky1_slb.m deczky1_slb_constraints_are_empty.m \
deczky1_slb_exchange_constraints.m deczky1_slb_set_empty_constraints.m \
deczky1_slb_show_constraints.m deczky1_slb_update_constraints.m \
deczky1_sqp_mmse.m iirA.m iirE.m iirT.m iirP.m iirdelAdelw.m \
invSVD.m armijo_kim.m fixResultNaN.m sqp_bfgs.m updateWchol.m local_max.m \
updateWbfgs.m xConstraints.m x2tf.m print_polynomial.m print_pole_zero.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m"

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
Ud1=2,Vd1=0,Md1=10,Qd1=6,Rd1=1
d1 = [   0.0176236489, ...
        -0.7627569413,  -0.7463970678, ...
         0.8697453041,   0.9017718780,   0.9815720975,   1.6929042591, ... 
         1.7919687998, ...
         2.4550650417,   2.0635979979,   1.9021701231,   1.0722291019, ... 
         0.3574292783, ...
         0.2280054268,   0.5613271056,   0.9297198027, ...
         0.8020276432,   1.6604361616,   1.7266368892 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok deczky1_sqp_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
