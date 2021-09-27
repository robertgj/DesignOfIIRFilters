#!/bin/sh

prog=directFIRnonsymmetric_kyp_highpass_test.m

depends="directFIRnonsymmetric_kyp_highpass_test.m test_common.m \
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
h = [ -0.0051682232,  0.0377046325, -0.0150541435, -0.0306548982, ... 
      -0.0172516896,  0.0289067848,  0.0624230117,  0.0227810927, ... 
      -0.1137943745, -0.2719471525,  0.6378398067, -0.2975000294, ... 
      -0.1311057003,  0.0266958884,  0.0872777369,  0.0429369807, ... 
      -0.0272122085, -0.0521248189, -0.0154962722,  0.0230177684, ... 
       0.0337810155,  0.0059548228, -0.0232351672, -0.0194928103, ... 
       0.0013316629,  0.0171827730,  0.0113154511, -0.0032890486, ... 
      -0.0149404208, -0.0068107164,  0.0161614545 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_highpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

