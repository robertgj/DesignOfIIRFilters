#!/bin/sh

prog=polyphase_allpassAsq_test.m

depends="polyphase_allpassAsq_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
allpassP.m parallel_allpassAsq.m a2tf.m tf2a.m qroots.m qzsolve.oct"

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
delAsqdelRpa=-0.027348, approx=-0.027348, diff=0.000000
Filter a: real pole/zero 2
delAsqdelRpa=-0.049629, approx=-0.049630, diff=0.000000
Filter a: conjugate pole/zero 1 radius
delAsqdelrpa=0.065086, approx=0.065085, diff=0.000001
Filter a: conjugate pole/zero 2 radius
delAsqdelrpa=-0.086644, approx=-0.086645, diff=0.000001
Filter a: conjugate pole/zero 3 radius
delAsqdelrpa=-0.060977, approx=-0.060977, diff=0.000000
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=0.209921, approx=0.209917, diff=0.000004
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=0.039345, approx=0.039345, diff=0.000000
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=0.009871, approx=0.009871, diff=0.000000
Filter b: conjugate pole/zero 1 radius
delAsqdelrpb=-0.301456, approx=-0.301465, diff=0.000009
Filter b: conjugate pole/zero 2 radius
delAsqdelrpb=0.097411, approx=0.097411, diff=0.000001
Filter b: conjugate pole/zero 3 radius
delAsqdelrpb=0.068643, approx=0.068643, diff=0.000000
Filter b: conjugate pole/zero 4 radius
delAsqdelrpb=0.052970, approx=0.052970, diff=0.000000
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=-0.059502, approx=-0.059502, diff=0.000000
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=-0.083007, approx=-0.083008, diff=0.000001
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=-0.016993, approx=-0.016993, diff=0.000000
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=-0.003544, approx=-0.003544, diff=0.000000
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

