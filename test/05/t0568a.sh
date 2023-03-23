#!/bin/sh

prog=directFIRsymmetric_kyp_lowpass_test.m
depends="test/directFIRsymmetric_kyp_lowpass_test.m \
test_common.m print_polynomial.m directFIRsymmetricEsqPW.m"

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
cat > test_h_coef.ok << 'EOF'
h = [  0.0034598702,  0.0172014340,  0.0172772925,  0.0064788662, ... 
      -0.0131227290, -0.0220082923, -0.0063222787,  0.0237641580, ... 
       0.0363004437,  0.0074192062, -0.0463409802, -0.0689453886, ... 
      -0.0082758570,  0.1315725282,  0.2789173887,  0.3419208547, ... 
       0.2789173887,  0.1315725282, -0.0082758570, -0.0689453886, ... 
      -0.0463409802,  0.0074192062,  0.0363004437,  0.0237641580, ... 
      -0.0063222787, -0.0220082923, -0.0131227290,  0.0064788662, ... 
       0.0172772925,  0.0172014340,  0.0034598702 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRsymmetric_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass
