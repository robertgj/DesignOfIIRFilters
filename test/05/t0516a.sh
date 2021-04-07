#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_test.m

depends="directFIRnonsymmetric_kyp_lowpass_test.m test_common.m \
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
h = [ -0.0017716071,  0.0154204219,  0.0327022298,  0.0352753733, ... 
       0.0075395646, -0.0385336369, -0.0589254320, -0.0071542814, ... 
       0.1204451010,  0.2651235829,  0.3384792648,  0.2882746309, ... 
       0.1426440972, -0.0082774685, -0.0807618341, -0.0580541560, ... 
       0.0073215004,  0.0466188538,  0.0323513936, -0.0091635193, ... 
      -0.0335255258, -0.0220796399,  0.0068421961,  0.0227753007, ... 
       0.0138973187, -0.0062029867, -0.0167943442, -0.0106193587, ... 
       0.0028762660,  0.0103491169,  0.0109482292 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

