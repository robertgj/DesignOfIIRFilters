#!/bin/sh

prog=mzsolve_test.m
depends="test/mzsolve_test.m test_common.m check_octave_file.m mzsolve.oct"

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
Using mzsolve octfile
mzsolve did catch complex coefficients
d =
   0.1983 + 0.9000i
   0.1983 - 0.9000i
  -0.1307 +      0i
  -0.0668 +      0i
   0.0285 + 0.5469i
   0.0285 - 0.5469i
   0.4061 + 0.5846i
   0.4061 - 0.5846i
   0.5880 + 0.5244i
   0.5880 - 0.5244i

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.coef"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi


#
# this much worked
#
pass

