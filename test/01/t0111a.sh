#!/bin/sh

prog=reprand_test.m

depends="test/reprand_test.m test_common.m check_octave_file.m reprand.oct"

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
cat > test.ok << 'EOF'
Using reprand octfile
Caught reprand exception for no input arguments!
Caught reprand exception for 3 arguments!
Caught reprand exception for array of 3 arguments!
ans = 1
ans = 1
ans = 1
r1 = 0.1304
r2 = 0.5919
r3 =
   0.5370   0.9554   0.3888   0.5533

r4 =
   0.1437
   0.6165
   0.6280
   0.8849

r5 =
   0.820557   0.563199   0.127732   0.205758
   0.610204   0.279487   0.736367   0.024376
   0.548099   0.327713   0.191691   0.745022
   0.233184   0.691969   0.518537   0.642747

ans = 1
ans = 1
ans = 1
ans =
       1   16384

max(n1)=  9.999736466302e-01
min(n1)=  3.078602492268e-06
mean(n1)=  5.011639894368e-01
var(n1)=  8.356043697316e-02
std(n1)=  2.890682220051e-01
ans =
   16384       1

max(n2)=  9.999968233472e-01
min(n2)=  2.496853509035e-04
mean(n2)=  4.992470965958e-01
var(n2)=  8.292523080078e-02
std(n2)=  2.879674127411e-01
norm(n1(:)-n2(:))=  5.245378411172e+01
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

