#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_double_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_double_bandpass_test.m \
test_common.m print_polynomial.m"

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
h = [ -0.0186124819,  0.0210325260,  0.0190355932, -0.0117254249, ... 
       0.0034180605, -0.0149033367,  0.0007651875, -0.0214873419, ... 
       0.0077409415, -0.0352281572,  0.0724281623,  0.1590574086, ... 
      -0.1766048216, -0.0463787737, -0.1008243938, -0.0489957896, ... 
       0.4010665999, -0.0517746396, -0.1157623490, -0.0550441610, ... 
      -0.1978632162,  0.1891652043,  0.0906404259, -0.0359886056, ... 
       0.0085201845, -0.0343939427, -0.0008097798, -0.0271589158, ... 
       0.0040899413, -0.0153625718,  0.0374773441,  0.0361368770, ... 
      -0.0324421926, -0.0024392389, -0.0098153783, -0.0007074472, ... 
      -0.0009847705,  0.0021989406,  0.0039196562,  0.0044734656, ... 
       0.0071846774, -0.0106510859 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok \
         directFIRnonsymmetric_kyp_union_double_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

