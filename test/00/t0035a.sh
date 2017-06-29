#!/bin/sh

prog=parallel_allpassAsq_test.m

depends="parallel_allpassAsq_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
allpassP.m parallel_allpassAsq.m a2tf.m tf2a.m"
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
Filter a: real pole/zero 1
delAsqdelRpa=-1.380102, approx=-1.380101, diff=-0.000000
Filter a: real pole/zero 2
delAsqdelRpa=-0.233183, approx=-0.233183, diff=-0.000000
Filter a: real pole/zero 3
delAsqdelRpa=-0.335900, approx=-0.335900, diff=-0.000000
Filter a: conjugate pole/zero 1 radius
delAsqdelrpa=1.588896, approx=1.588896, diff=-0.000000
Filter a: conjugate pole/zero 2 radius
delAsqdelrpa=-0.644360, approx=-0.644363, diff=0.000002
Filter a: conjugate pole/zero 3 radius
delAsqdelrpa=-0.888827, approx=-0.888827, diff=0.000000
Filter a: conjugate pole/zero 4 radius
delAsqdelrpa=-0.502476, approx=-0.502476, diff=-0.000000
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=1.176943, approx=1.176942, diff=0.000001
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=1.012557, approx=1.012557, diff=-0.000001
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=0.362213, approx=0.362213, diff=-0.000000
Filter a: conjugate pole/zero 4 angle
delPdelthetapa=0.049464, approx=0.049464, diff=-0.000000
Filter b: conjugate pole/zero 1 radius
delAsqdelrpb=-0.474547, approx=-0.474546, diff=-0.000000
Filter b: conjugate pole/zero 2 radius
delAsqdelrpb=-0.555366, approx=-0.555366, diff=-0.000000
Filter b: conjugate pole/zero 3 radius
delAsqdelrpb=-0.653177, approx=-0.653177, diff=-0.000000
Filter b: conjugate pole/zero 4 radius
delAsqdelrpb=-0.959100, approx=-0.959101, diff=0.000001
Filter b: conjugate pole/zero 5 radius
delAsqdelrpb=0.343922, approx=0.343921, diff=0.000001
Filter b: conjugate pole/zero 6 radius
delAsqdelrpb=2.507791, approx=2.507791, diff=-0.000000
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=0.023161, approx=0.023161, diff=-0.000000
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=0.084343, approx=0.084344, diff=-0.000000
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=0.140905, approx=0.140905, diff=-0.000000
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=0.632954, approx=0.632955, diff=-0.000001
Filter b: conjugate pole/zero 5 angle
delPdelthetapb=1.321866, approx=1.321865, diff=0.000000
Filter b: conjugate pole/zero 6 angle
delPdelthetapb=0.622944, approx=0.622942, diff=0.000001
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

