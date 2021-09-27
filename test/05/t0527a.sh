#!/bin/sh

prog=iir_socp_slb_fir_lowpass_alternate_test.m

depends="iir_socp_slb_fir_lowpass_alternate_test.m \
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
d1 = [  0.00676413, ...
       -0.96240677,  2.25045573, ...
        0.79848921,  0.80499220,  0.80659847,  0.94484490, ... 
        0.94488428,  0.94690528,  0.94866939,  0.94919328, ... 
        0.95040056,  0.95702592,  0.96336898,  0.98015993, ... 
        0.99655465,  1.67755300, ...
        0.16053270,  0.47496034,  0.81357275,  2.13933742, ... 
        2.34590542,  2.54649853,  2.74502668,  2.94385143, ... 
        1.93566106,  1.74795746,  1.55796617,  1.38980675, ... 
        1.27393915,  0.40022725 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_fir_lowpass_alternate_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
