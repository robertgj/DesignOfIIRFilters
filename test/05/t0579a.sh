#!/bin/sh

prog=directFIRsymmetric_kyp_union_bandpass_test.m

depends="test/directFIRsymmetric_kyp_union_bandpass_test.m test_common.m \
print_polynomial.m"

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
h = [ -0.0036557908, -0.0004086785, -0.0042607560, -0.0113101881, ... 
       0.0043983263,  0.0110408381, -0.0026789639,  0.0290416700, ... 
       0.0494235766, -0.0168198497, -0.0197507120,  0.0205026012, ... 
      -0.1438552771, -0.2434078538,  0.1190166406,  0.4236649212, ... 
       0.1190166406, -0.2434078538, -0.1438552771,  0.0205026012, ... 
      -0.0197507120, -0.0168198497,  0.0494235766,  0.0290416700, ... 
      -0.0026789639,  0.0110408381,  0.0043983263, -0.0113101881, ... 
      -0.0042607560, -0.0004086785, -0.0036557908 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRsymmetric_kyp_union_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

