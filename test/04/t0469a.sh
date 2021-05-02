#!/bin/sh

prog=mcclellanFIRsymmetric_flat_differentiator_fail_test.m

depends="mcclellanFIRsymmetric_flat_differentiator_fail_test.m test_common.m \
mcclellanFIRsymmetric.m lagrange_interp.m local_max.m directFIRsymmetricA.m \
xfr2tf.m print_polynomial.m"

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
cat > test_hM.ok << 'EOF'
hM = [     -1.3043010,    -18.4176587,   -131.4337766,   -629.0608228, ... 
        -2263.1151388,  -6504.5325845, -15501.6827209, -31391.5504706, ... 
       -54926.4452397, -84009.8621257, -113220.6322627, -135154.6891011, ... 
       -143326.9987599 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok \
mcclellanFIRsymmetric_flat_differentiator_fail_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

