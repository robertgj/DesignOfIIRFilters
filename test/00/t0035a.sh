#!/bin/sh

prog=parallel_allpassAsq_test.m

depends="parallel_allpassAsq_test.m \
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
Filter a: real pole/zero 1
delAsqdelRpa=-0.932731, approx=-0.932731, diff=-0.000001
Filter a: real pole/zero 2
delAsqdelRpa=-5.520407, approx=-5.520406, diff=-0.000001
Filter a: real pole/zero 3
delAsqdelRpa=-1.343599, approx=-1.343598, diff=-0.000001
Filter a: conjugate pole/zero 1 radius
delAsqdelrpa=-2.009905, approx=-2.009904, diff=-0.000001
Filter a: conjugate pole/zero 2 radius
delAsqdelrpa=-3.555307, approx=-3.555309, diff=0.000002
Filter a: conjugate pole/zero 3 radius
delAsqdelrpa=-2.577442, approx=-2.577451, diff=0.000009
Filter a: conjugate pole/zero 4 radius
delAsqdelrpa=6.355584, approx=6.355586, diff=-0.000001
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=0.197856, approx=0.197856, diff=-0.000000
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=1.448851, approx=1.448853, diff=-0.000001
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=4.050227, approx=4.050230, diff=-0.000002
Filter a: conjugate pole/zero 4 angle
delPdelthetapa=4.707773, approx=4.707768, diff=0.000004
Filter b: conjugate pole/zero 1 radius
delAsqdelrpb=-2.612708, approx=-2.612708, diff=-0.000000
Filter b: conjugate pole/zero 2 radius
delAsqdelrpb=-2.221465, approx=-2.221465, diff=-0.000001
Filter b: conjugate pole/zero 3 radius
delAsqdelrpb=-1.898186, approx=-1.898185, diff=-0.000001
Filter b: conjugate pole/zero 4 radius
delAsqdelrpb=-3.836398, approx=-3.836404, diff=0.000005
Filter b: conjugate pole/zero 5 radius
delAsqdelrpb=1.375689, approx=1.375683, diff=0.000006
Filter b: conjugate pole/zero 6 radius
delAsqdelrpb=10.031163, approx=10.031164, diff=-0.000001
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=0.563619, approx=0.563620, diff=-0.000001
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=0.337374, approx=0.337374, diff=-0.000000
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=0.092643, approx=0.092643, diff=-0.000000
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=2.531817, approx=2.531820, diff=-0.000002
Filter b: conjugate pole/zero 5 angle
delPdelthetapb=5.287462, approx=5.287462, diff=0.000001
Filter b: conjugate pole/zero 6 angle
delPdelthetapb=2.491775, approx=2.491769, diff=0.000005
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

