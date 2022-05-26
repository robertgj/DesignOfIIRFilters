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
Caught reprand exception for no arguments!
Caught reprand exception for 3 arguments!
ans = 1
ans = 1
ans = 1
ans = 0.1304
ans = 0.1304
ans =
   0.1304   0.5919   0.5370   0.9554

ans =
   0.1304
   0.5919
   0.5370
   0.9554

ans =
   0.1304   0.5919   0.5370   0.9554
   0.3888   0.5533   0.1437   0.6165
   0.6280   0.8849   0.8206   0.5632
   0.1277   0.2058   0.6102   0.2795

ans =
       1   16384

max(n1)=  9.999736466302e-01
min(n1)=  3.078602492268e-06
mean(n1)=  5.011120354351e-01
var(n1)=  8.352967703586e-02
std(n1)=  2.890150117829e-01
ans =
   16384       1

max(n2)=  9.999736466302e-01
min(n2)=  3.078602492268e-06
mean(n2)=  5.011120354351e-01
var(n2)=  8.352967703586e-02
std(n2)=  2.890150117829e-01
norm(n1(:)-n2(:))=  0.000000000000e+00
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

