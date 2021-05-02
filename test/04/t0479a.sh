#!/bin/sh

prog=nuevoFIRsymmetric_flat_bandpass_test.m

depends="nuevoFIRsymmetric_flat_bandpass_test.m test_common.m \
herrmannFIRsymmetric_flat_lowpass.m directFIRsymmetricA.m print_polynomial.m"

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
hM = [ -0.000000115775, -0.000000977656, -0.000001682143,  0.000008798903, ... 
        0.000035928853, -0.000008798903, -0.000247553748, -0.000258101150, ... 
        0.000888689188,  0.001935758628, -0.001537852688, -0.007637447678, ... 
       -0.001205449691,  0.020284404047,  0.017043474829, -0.039348693565, ... 
       -0.068841149448,  0.057879182976,  0.303865710623,  0.434291748796 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

cat > test_hza.ok << 'EOF'
hza = [ -1.000000000000,  0.000000000000,  1.000000000000,  0.000000000000, ... 
         1.000000000000,  0.000000000000, -1.000000000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hza.ok"; fail; fi

cat > test_hzb.ok << 'EOF'
hzb = [ -0.004136886270, -0.017852189988, -0.038019167415, -0.047930433674, ... 
        -0.031132075251,  0.011819680270,  0.059109120400,  0.079676236949, ... 
         0.059109120400,  0.011819680270, -0.031132075251, -0.047930433674, ... 
        -0.038019167415, -0.017852189988, -0.004136886270 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hzb.ok"; fail; fi

cat > test_hMf.ok << 'EOF'
hMf = [        1,        0,       -8,       -8, ... 
              29,       63,      -50,     -250, ... 
             -40,      665,      558,    -1289, ... 
           -2256,     1897,     9957,    14231 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hMf.ok"; fail; fi

cat > test_hzbf.ok << 'EOF'
hzbf = [     -136,     -585,    -1246,    -1571, ... 
            -1020,      387,     1937,     2611, ... 
             1937,      387,    -1020,    -1571, ... 
            -1246,     -585,     -136 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hzbf.ok"; fail; fi


#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok nuevoFIRsymmetric_flat_bandpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

diff -Bb test_hza.ok nuevoFIRsymmetric_flat_bandpass_test_hza_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hza.ok"; fail; fi

diff -Bb test_hzb.ok nuevoFIRsymmetric_flat_bandpass_test_hzb_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hzb.ok"; fail; fi

diff -Bb test_hMf.ok nuevoFIRsymmetric_flat_bandpass_test_hMf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hMf.ok"; fail; fi

diff -Bb test_hzbf.ok nuevoFIRsymmetric_flat_bandpass_test_hzbf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hzbf.ok"; fail; fi

#
# this much worked
#
pass

