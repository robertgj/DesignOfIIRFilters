#!/bin/sh

prog=ellipap1_test.m

depends="ellipap1_test.m test_common.m ellipap1.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
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
n =    6.0000e+00
rp =    5.0000e-01
rs =    4.0000e+01
Za =

   0.0000e+00 + 3.1568e+00i
   0.0000e+00 + 1.3623e+00i
   0.0000e+00 + 1.1443e+00i
  -0.0000e+00 - 3.1568e+00i
  -0.0000e+00 - 1.3623e+00i
  -0.0000e+00 - 1.1443e+00i

Pa =

  -3.8504e-01 + 4.1148e-01i
  -1.5288e-01 + 8.7928e-01i
  -3.2516e-02 + 1.0065e+00i
  -3.8504e-01 - 4.1148e-01i
  -1.5288e-01 - 8.7928e-01i
  -3.2516e-02 - 1.0065e+00i

Ka =    1.0000e-02
Zb =

  -0.0000e+00 - 3.1568e+00i
   0.0000e+00 + 3.1568e+00i
  -0.0000e+00 - 1.3623e+00i
   0.0000e+00 + 1.3623e+00i
  -0.0000e+00 - 1.1443e+00i
   0.0000e+00 + 1.1443e+00i

Pb =

  -3.8504e-01 - 4.1147e-01i
  -3.8504e-01 + 4.1147e-01i
  -1.5288e-01 - 8.7927e-01i
  -1.5288e-01 + 8.7927e-01i
  -3.2516e-02 - 1.0065e+00i
  -3.2516e-02 + 1.0065e+00i

Kb =    1.0000e-02
n =    7.0000e+00
rp =    1.0000e-01
rs =    5.5430e+01
Zc =

   0.0000e+00 + 2.3848e+00i
   0.0000e+00 + 1.4678e+00i
   0.0000e+00 + 1.2688e+00i
  -0.0000e+00 - 2.3848e+00i
  -0.0000e+00 - 1.4678e+00i
  -0.0000e+00 - 1.2688e+00i

Pc =

  -3.6897e-01 + 6.0399e-01i
  -1.7136e-01 + 9.1839e-01i
  -4.5592e-02 + 1.0266e+00i
  -3.6897e-01 - 6.0399e-01i
  -1.7136e-01 - 9.1839e-01i
  -4.5592e-02 - 1.0266e+00i
  -4.9805e-01 + 0.0000e+00i

Kc =    1.1658e-02
Zd =

  -0.0000e+00 - 2.3848e+00i
   0.0000e+00 + 2.3848e+00i
  -0.0000e+00 - 1.4678e+00i
   0.0000e+00 + 1.4678e+00i
  -0.0000e+00 - 1.2688e+00i
   0.0000e+00 + 1.2688e+00i

Pd =

  -3.6897e-01 - 6.0399e-01i
  -3.6897e-01 + 6.0399e-01i
  -1.7136e-01 - 9.1839e-01i
  -1.7136e-01 + 9.1839e-01i
  -4.5593e-02 - 1.0266e+00i
  -4.5593e-02 + 1.0266e+00i
  -4.9805e-01 + 0.0000e+00i

Kd =    1.1658e-02
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
