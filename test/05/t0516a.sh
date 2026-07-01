#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_test.m

depends="test/directFIRnonsymmetric_kyp_lowpass_test.m test_common.m delayz.m \
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
h = [ -0.0008714886,  0.0164379379,  0.0341327100,  0.0365353685, ... 
       0.0084393134, -0.0377934790, -0.0579357617, -0.0056438390, ... 
       0.1223519179,  0.2670039769,  0.3399771474,  0.2893237362, ... 
       0.1434423001, -0.0075449187, -0.0800715981, -0.0574395432, ... 
       0.0079450239,  0.0474687822,  0.0335713264, -0.0077309628, ... 
      -0.0322913606, -0.0213940540,  0.0069543104,  0.0226555112, ... 
       0.0139608491, -0.0057629831, -0.0160917225, -0.0099293954, ... 
       0.0033555178,  0.0105451634,  0.0110786113 ];
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

