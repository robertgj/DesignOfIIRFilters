#!/bin/sh

prog=fir_socp_slb_lowpass_test.m

depends="fir_socp_slb_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m \
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
cat > test.d1.ok << 'EOF'
Ud1=2,Vd1=0,Md1=28,Qd1=0,Rd1=1
d1 = [   0.0013053648, ...
       -21.0875500909,  -0.9590495719, ...
         0.7323932303,   0.7344054159,   0.7375198375,   0.8693610065, ... 
         0.9026743675,   0.9133356958,   0.9167356729,   0.9212172641, ... 
         0.9221027437,   0.9239875880,   0.9301201781,   0.9333740536, ... 
         0.9917957640,   1.3100866088, ...
         0.4066814032,   0.7658890258,   0.2275235077,   1.5050755758, ... 
         1.6875513751,   1.8835070834,   2.9241063806,   2.5101026565, ... 
         2.7188136850,   2.3000365946,   2.0842481409,   1.4175030894, ... 
         1.2770073402,   0.3727675893 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok fir_socp_slb_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
