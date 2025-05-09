#!/bin/sh

prog=deczky3_socp_bfgs_test.m

depends="test/deczky3_socp_bfgs_test.m test_common.m print_polynomial.m \
print_pole_zero.m \
armijo_kim.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m \
local_max.m iir_slb.m iir_socp_bfgs.m updateWbfgs.m updateWchol.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m xConstraints.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m x2tf.m"

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

# the output should look like this
#
cat > test_d2_coef.m << 'EOF'
Ud2=0,Vd2=0,Md2=10,Qd2=6,Rd2=1
d2 = [   0.0028603138, ...
         1.1153501977,   1.1326296806,   1.1339461180,   1.8249222537, ... 
         2.1304788384, ...
         2.7293068379,   2.0494180703,   1.8375924429,   0.7412322936, ... 
         0.2300983416, ...
         0.5590030319,   0.6426477668,   0.7101804871, ...
         0.3514324633,   1.0470003089,   1.4478422721 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d2_coef.m deczky3_socp_bfgs_test_d2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

