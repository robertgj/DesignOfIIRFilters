#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_test.m

depends="test/directFIRnonsymmetric_kyp_lowpass_test.m test_common.m \
print_polynomial.m konopacki.m directFIRnonsymmetricEsqPW.m"

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
h = [ -0.0008739628,  0.0164442967,  0.0341368296,  0.0365351166, ... 
       0.0084233754, -0.0378224961, -0.0579627953, -0.0056519543, ... 
       0.1223672254,  0.2670300828,  0.3399958593,  0.2893246897, ... 
       0.1434323887, -0.0075528889, -0.0800716260, -0.0574366632, ... 
       0.0079436071,  0.0474642917,  0.0335721892, -0.0077203383, ... 
      -0.0322780202, -0.0213933925,  0.0069364396,  0.0226280730, ... 
       0.0139426422, -0.0057591371, -0.0160689036, -0.0099024981, ... 
       0.0033706187,  0.0105515144,  0.0110751172 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

