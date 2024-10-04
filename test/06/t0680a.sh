#!/bin/sh

prog=tarczynski_bandpass_R1_test.m

depends="test/tarczynski_bandpass_R1_test.m test_common.m delayz.m print_polynomial.m \
print_pole_zero.m WISEJ.m x2tf.m tf2Abcd.m tf2x.m zp2x.m qroots.m qzsolve.oct"

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
cat > test_D0.ok << 'EOF'
D0 = [   1.0000000000,  -5.9204941612,  18.3063969119, -37.7408052011, ... 
        57.2157222347, -66.6708692516,  61.0341039005, -44.1433460119, ... 
        25.0671495374, -10.9277019121,   3.4981367365,  -0.7453981097, ... 
         0.0838688345,   0.0007259461,   0.0000748843,   0.0001188773, ... 
         0.0012387306,   0.0008240226,  -0.0001184262,  -0.0001333666, ... 
         0.0008663117 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D0.ok"; fail; fi

cat > test_N0.ok << 'EOF'
N0 = [  -0.0022760395,   0.0031512874,  -0.0000957656,  -0.0035120549, ... 
         0.0014392883,   0.0021942822,  -0.0013296777,   0.0013447725, ... 
         0.0008115980,  -0.0039962563,  -0.0009372660,   0.0038757297, ... 
         0.0016714370,  -0.0022714092,  -0.0022523838,   0.0004529609, ... 
         0.0018199040,   0.0004937453,  -0.0007957843,  -0.0003389143, ... 
         0.0003765445 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_D0.ok tarczynski_bandpass_R1_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D0.ok"; fail; fi

diff -Bb test_N0.ok tarczynski_bandpass_R1_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N0.ok"; fail; fi

#
# this much worked
#
pass

