#!/bin/sh

prog=reprand_test.m

depends="reprand_test.m test_common.m check_octave_file.m reprand.oct"

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
echo $here
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
ans =  0.13044
ans =  0.13044
ans =
   0.13044   0.59194   0.53698   0.95537

ans =
   0.13044
   0.59194
   0.53698
   0.95537

ans =
   0.13044   0.59194   0.53698   0.95537
   0.38884   0.55330   0.14369   0.61653
   0.62797   0.88493   0.82056   0.56320
   0.12773   0.20576   0.61020   0.27949

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
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

