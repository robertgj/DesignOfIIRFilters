#!/bin/sh

prog=polyphase_allpassP_test.m

depends="test/polyphase_allpassP_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
allpassP.m parallel_allpassP.m a2tf.m tf2a.m qroots.oct"

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
delPdelRpa=-0.275099, approx=-0.275099, diff=-0.000000
Filter a: real pole/zero 2
delPdelRpa=-0.499235, approx=-0.499234, diff=-0.000000
Filter a: conjugate pole/zero 1 radius
delPdelrpa=0.654713, approx=0.654712, diff=0.000001
Filter a: conjugate pole/zero 2 radius
delPdelrpa=-0.871577, approx=-0.871577, diff=0.000000
Filter a: conjugate pole/zero 3 radius
delPdelrpa=-0.613381, approx=-0.613381, diff=-0.000000
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=2.111655, approx=2.111656, diff=-0.000000
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=0.395786, approx=0.395786, diff=-0.000000
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=0.099299, approx=0.099299, diff=-0.000000
Filter b: conjugate pole/zero 1 radius
delPdelrpb=3.032423, approx=3.032425, diff=-0.000002
Filter b: conjugate pole/zero 2 radius
delPdelrpb=-0.979888, approx=-0.979890, diff=0.000002
Filter b: conjugate pole/zero 3 radius
delPdelrpb=-0.690502, approx=-0.690502, diff=-0.000000
Filter b: conjugate pole/zero 4 radius
delPdelrpb=-0.532842, approx=-0.532842, diff=-0.000000
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=0.598547, approx=0.598546, diff=0.000002
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=0.834994, approx=0.834995, diff=-0.000001
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=0.170934, approx=0.170934, diff=-0.000000
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=0.035648, approx=0.035648, diff=-0.000000
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

