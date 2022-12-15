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
h = [  0.0034598688,  0.0172014397,  0.0172772884,  0.0064788701, ... 
      -0.0131227316, -0.0220082912, -0.0063222791,  0.0237641587, ... 
       0.0363004430,  0.0074192064, -0.0463409811, -0.0689453878, ... 
      -0.0082758549,  0.1315725285,  0.2789173913,  0.3419208535, ... 
       0.2789173913,  0.1315725285, -0.0082758549, -0.0689453878, ... 
      -0.0463409811,  0.0074192064,  0.0363004430,  0.0237641587, ... 
      -0.0063222791, -0.0220082912, -0.0131227316,  0.0064788701, ... 
       0.0172772884,  0.0172014397,  0.0034598688 ];
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
