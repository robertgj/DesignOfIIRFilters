#!/bin/sh

prog=Abcd2ng_test.m
depends="Abcd2ng_test.m test_common.m Abcd2ng.m tf2Abcd.m svf.m KW.m"

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
Test 1:
ng =  0.25000
As =  0.72654
Bs =  0.68712
Cs =  0.34356
Ds =  0.13673
Ts =  1.4553
ng =  0.25000
est_varyd =  0.10417
varyd =  0.10406
Test 1a:
ng =  0.25000
As =  0.72654
Bs =  0.68712
Cs =  0.34356
Ds =  0.13673
ng =  0.25000
est_varyd =  0.10417
varyd =  0.10406
Test 1b:
ng =  0.25000
Test 2:
ng =  21.015
As =

   0.00000   1.00000   0.00000
   0.00000   0.00000   1.00000
   0.53208  -1.92936   2.37409

Bs =

   0.000000
   0.000000
   0.070452

Cs =

   0.063025   0.044043   0.221075

Ds =  0.0028982
ng =  21.015
est_varyd =  1.8346
varyd =  1.9277
Test 2a:
ng =  21.015
As =

   0.00000   1.00000   0.00000
   0.00000   0.00000   1.00000
   0.53208  -1.92936   2.37409

Bs =

   0.000000
   0.000000
   0.070452

Cs =

   0.063025   0.044043   0.221075

Ds =  0.0028982
Ts =

Diagonal Matrix

   14.194        0        0
        0   14.194        0
        0        0   14.194

ng =  21.015
est_varyd =  1.8346
varyd =  1.9277
Test 2b:
ng =  21.015
As =

   0.00000   1.00000   0.00000
   0.00000   0.00000   1.00000
   0.53208  -1.92936   2.37409

Bs =

   0.000000
   0.000000
   0.035226

Cs =

   0.126050   0.088086   0.442150

Ds =  0.0028982
Ts =

Diagonal Matrix

   28.388        0        0
        0   28.388        0
        0        0   28.388

ng =  21.015
est_varyd =  1.8346
varyd =  7.0991
Test 3:
ng =  8.3215
est_varyd =  0.77680
varyd =  0.77632
Test 3a:
ng =  67.497
est_varyd =  5.7081
varyd =  0.77632
Test 4:
ng =  145.47
est_varyd =  12.206
varyd =  12.108
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc
octave-cli -q $prog > test.out 2>&1

if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
