#!/bin/sh

prog=iir_socp_slb_hilbert_R2_test.m
depends="test/iir_socp_slb_hilbert_R2_test.m \
../tarczynski_hilbert_R2_test_D0_coef.m \
../tarczynski_hilbert_R2_test_N0_coef.m \
test_common.m print_polynomial.m print_pole_zero.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
local_max.m iir_socp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
iir_slb_update_constraints.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m \
xConstraints.m tf2x.m zp2x.m x2tf.m qroots.oct"

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
Ud1=7,Vd1=4,Md1=4,Qd1=2,Rd1=2
d1 = [   0.0143069760, ...
        -2.3562082439,  -0.8241737196,  -0.7245359557,  -0.1759120693, ... 
         0.5312076004,   0.6976570359,   1.2086622450, ...
        -0.1726229628,   0.1921060713,   0.5549839829,   0.6682903423, ...
         2.1476140113,   2.3065114651, ...
         0.9949101999,   2.0703499524, ...
         0.2132466963, ...
         1.5681520803 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output test.d1.ok cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_hilbert_R2_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

