#!/bin/sh

prog=ellipap1_test.m

depends="ellipap1_test.m test_common.m ellipap1.m"

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
n =  6
rp =  0.50000
rs =  40
Za =
   0.0000 + 3.1568i
   0.0000 + 1.3623i
   0.0000 + 1.1443i
  -0.0000 - 3.1568i
  -0.0000 - 1.3623i
  -0.0000 - 1.1443i

Pa =
  -0.38504 + 0.41148i
  -0.15288 + 0.87928i
  -0.03252 + 1.00653i
  -0.38504 - 0.41148i
  -0.15288 - 0.87928i
  -0.03252 - 1.00653i

Ka =  0.010000
Zb =
  -0.0000 - 3.1568i
   0.0000 + 3.1568i
  -0.0000 - 1.3623i
   0.0000 + 1.3623i
  -0.0000 - 1.1443i
   0.0000 + 1.1443i

Pb =
  -0.38504 - 0.41147i
  -0.38504 + 0.41147i
  -0.15288 - 0.87927i
  -0.15288 + 0.87927i
  -0.03252 - 1.00653i
  -0.03252 + 1.00653i

Kb =  0.010000
n =  7
rp =  0.10000
rs =  55.430
Zc =
   0.0000 + 2.3848i
   0.0000 + 1.4678i
   0.0000 + 1.2688i
  -0.0000 - 2.3848i
  -0.0000 - 1.4678i
  -0.0000 - 1.2688i

Pc =
  -0.36897 + 0.60399i
  -0.17136 + 0.91839i
  -0.04559 + 1.02656i
  -0.36897 - 0.60399i
  -0.17136 - 0.91839i
  -0.04559 - 1.02656i
  -0.49805 + 0.00000i

Kc =  0.011658
Zd =
  -0.0000 - 2.3848i
   0.0000 + 2.3848i
  -0.0000 - 1.4678i
   0.0000 + 1.4678i
  -0.0000 - 1.2688i
   0.0000 + 1.2688i

Pd =
  -0.36897 - 0.60399i
  -0.36897 + 0.60399i
  -0.17136 - 0.91839i
  -0.17136 + 0.91839i
  -0.04559 - 1.02656i
  -0.04559 + 1.02656i
  -0.49805 + 0.00000i

Kd =  0.011658
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
