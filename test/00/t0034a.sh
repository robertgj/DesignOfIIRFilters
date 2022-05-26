#!/bin/sh

prog=parallel_allpassP_test.m

depends="test/parallel_allpassP_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
allpassP.m parallel_allpassP.m a2tf.m tf2a.m qroots.m qzsolve.oct"

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
verbose = 1
Filter a: real pole/zero 1
delPdelRpa=-0.240969, approx=-0.240969, diff=-0.000000
Filter a: real pole/zero 2
delPdelRpa=-1.426185, approx=-1.426184, diff=-0.000001
Filter a: real pole/zero 3
delPdelRpa=-0.347116, approx=-0.347116, diff=-0.000000
Filter a: conjugate pole/zero 1 radius
delPdelrpa=-0.519255, approx=-0.519254, diff=-0.000000
Filter a: conjugate pole/zero 2 radius
delPdelrpa=-0.918506, approx=-0.918506, diff=0.000000
Filter a: conjugate pole/zero 3 radius
delPdelrpa=-0.665876, approx=-0.665879, diff=0.000002
Filter a: conjugate pole/zero 4 radius
delPdelrpa=1.641951, approx=1.641952, diff=-0.000001
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=0.051116, approx=0.051116, diff=-0.000000
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=0.374308, approx=0.374308, diff=-0.000000
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=1.046367, approx=1.046368, diff=-0.000001
Filter a: conjugate pole/zero 4 angle
delPdelthetapa=1.216243, approx=1.216242, diff=0.000001
Filter b: conjugate pole/zero 1 radius
delPdelrpb=0.674987, approx=0.674987, diff=0.000000
Filter b: conjugate pole/zero 2 radius
delPdelrpb=0.573911, approx=0.573910, diff=0.000000
Filter b: conjugate pole/zero 3 radius
delPdelrpb=0.490392, approx=0.490392, diff=0.000000
Filter b: conjugate pole/zero 4 radius
delPdelrpb=0.991125, approx=0.991126, diff=-0.000001
Filter b: conjugate pole/zero 5 radius
delPdelrpb=-0.355406, approx=-0.355405, diff=-0.000001
Filter b: conjugate pole/zero 6 radius
delPdelrpb=-2.591529, approx=-2.591531, diff=0.000002
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=-0.145610, approx=-0.145610, diff=0.000000
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=-0.087160, approx=-0.087160, diff=0.000000
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=-0.023934, approx=-0.023934, diff=0.000000
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=-0.654089, approx=-0.654090, diff=0.000001
Filter b: conjugate pole/zero 5 angle
delPdelthetapb=-1.366004, approx=-1.366004, diff=0.000000
Filter b: conjugate pole/zero 6 angle
delPdelthetapb=-0.643744, approx=-0.643743, diff=-0.000001
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

