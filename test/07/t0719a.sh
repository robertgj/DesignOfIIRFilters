#!/bin/sh

prog=iir_socp_slb_lowpass_R2_test.m

depends="test/iir_socp_slb_lowpass_R2_test.m \
test_common.m iir_socp_mmse.m iir_slb.m iir_slb_exchange_constraints.m \
iir_slb_show_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_update_constraints.m \
local_max.m xConstraints.m x2tf.m xInitHd.m iirA.m iirE.m iirP.m iirT.m \
fixResultNaN.m print_polynomial.m print_pole_zero.m showZPplot.m"

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
d1 = [   0.0030994526, ...
         0.9994472906,   0.9999909752,   0.9999914206,   0.9999919528, ... 
         0.9999983282,   1.1592750809, ...
         0.9624706803,   2.5678145269,   2.4083338374,   2.9102149241, ... 
         1.1623074069,   1.7625323518, ...
         0.4845845955,   0.6842957526,   0.8991711568, ...
         0.4895834463,   1.1125948478,   1.3338065195 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="iir_socp_slb_lowpass_R2_test"

diff -Bb test.d1.ok $nstr"_d1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.d1.ok"; fail; fi

#
# this much worked
#
pass
