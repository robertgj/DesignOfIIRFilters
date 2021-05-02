#!/bin/sh

prog=mcclellanFIRsymmetric_multiband_test.m

depends="mcclellanFIRsymmetric_multiband_test.m test_common.m \
print_polynomial.m mcclellanFIRsymmetric.m local_max.m lagrange_interp.m \
xfr2tf.m directFIRsymmetricA.m"

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
hM = [   0.0020852534,  -0.0017262027,  -0.0000084962,   0.0003285677, ... 
        -0.0014901131,  -0.0085441600,   0.0063716710,   0.0041746799, ... 
         0.0017192812,   0.0043711270,  -0.0061979483,  -0.0006439915, ... 
        -0.0043622061,  -0.0027483676,  -0.0258056098,   0.0296490648, ... 
         0.0335773014,  -0.0180841232,   0.0066018472,  -0.0280836542, ... 
        -0.0023059288,  -0.0198877239,   0.0048779015,  -0.0319820481, ... 
         0.0791193238,   0.1774151448,  -0.1910626448,  -0.0521172035, ... 
        -0.1086275176,  -0.0549671680,   0.4144310402 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok mcclellanFIRsymmetric_multiband_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

