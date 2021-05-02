#!/bin/sh

prog=Abcd2ng_test.m
depends="Abcd2ng_test.m test_common.m Abcd2ng.m tf2Abcd.m svf.m KW.m"

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
Test 1:
ng = 0.2500
As = 0.7265
Bs = 0.6871
Cs = 0.3436
Ds = 0.1367
Ts = 1.4553
ng = 0.2500
est_varyd = 0.1042
varyd = 0.1041
Test 1a:
ng = 0.2500
As = 0.7265
Bs = 0.6871
Cs = 0.3436
Ds = 0.1367
ng = 0.2500
est_varyd = 0.1042
varyd = 0.1041
Test 1b:
ng = 0.2500
Test 2:
ng = 21.015
As =
        0   1.0000        0
        0        0   1.0000
   0.5321  -1.9294   2.3741

Bs =
          0
          0
   0.070452

Cs =
   0.063025   0.044043   0.221075

Ds = 2.8982e-03
ng = 21.015
est_varyd = 1.8346
varyd = 1.9277
Test 2a:
ng = 21.015
As =
        0   1.0000        0
        0        0   1.0000
   0.5321  -1.9294   2.3741

Bs =
          0
          0
   0.070452

Cs =
   0.063025   0.044043   0.221075

Ds = 2.8982e-03
Ts =
Diagonal Matrix
   14.194        0        0
        0   14.194        0
        0        0   14.194

ng = 21.015
est_varyd = 1.8346
varyd = 1.9277
Test 2b:
ng = 21.015
As =
        0   1.0000        0
        0        0   1.0000
   0.5321  -1.9294   2.3741

Bs =
          0
          0
   0.035226

Cs =
   0.126050   0.088086   0.442150

Ds = 2.8982e-03
Ts =
Diagonal Matrix
   28.388        0        0
        0   28.388        0
        0        0   28.388

ng = 21.015
est_varyd = 1.8346
varyd = 7.0991
Test 3:
ng = 8.3215
est_varyd = 0.7768
varyd = 0.7763
Test 3a:
ng = 67.497
est_varyd = 5.7081
varyd = 0.7763
Test 4:
ng = 145.47
est_varyd = 12.206
varyd = 12.108
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
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
