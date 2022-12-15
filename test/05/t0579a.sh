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
h = [ -0.0036611398, -0.0004105686, -0.0042589355, -0.0113141889, ... 
       0.0043989735,  0.0110545993, -0.0026755532,  0.0290357276, ... 
       0.0494315054, -0.0168218612, -0.0197748491,  0.0204983495, ... 
      -0.1438458163, -0.2434186060,  0.1190199349,  0.4236932778, ... 
       0.1190199349, -0.2434186060, -0.1438458163,  0.0204983495, ... 
      -0.0197748491, -0.0168218612,  0.0494315054,  0.0290357276, ... 
      -0.0026755532,  0.0110545993,  0.0043989735, -0.0113141889, ... 
      -0.0042589355, -0.0004105686, -0.0036611398 ];
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

