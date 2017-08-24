#!/bin/sh

prog=polyphase_allpass_mmse_error_test.m
depends="polyphase_allpass_mmse_error_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
parallel_allpass_mmse_error.m parallel_allpassAsq.m parallel_allpassT.m \
allpassP.m allpassT.m a2tf.m tf2a.m"

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
verbose = 1
fap =  0.22000
Wap =  1
fas =  0.28000
Was =  1000
ftp =  0.22000
Wtp =  10
td =  22
Filter a: real pole/zero 1
delEdelRpa=1.62556, approx=1.62556, diff=-2.0739e-06
Filter a: conjugate pole/zero 1 radius
delEdelrpa=-3.02676, approx=-3.02676, diff=-3.52267e-06
Filter a: conjugate pole/zero 2 radius
delEdelrpa=6.44049, approx=6.44049, diff=-2.82004e-06
Filter a: conjugate pole/zero 3 radius
delEdelrpa=4.94096, approx=4.94096, diff=-3.94368e-06
Filter a: conjugate pole/zero 4 radius
delEdelrpa=3.89346, approx=3.89346, diff=-3.50884e-06
Filter a: conjugate pole/zero 5 radius
delEdelrpa=3.39486, approx=3.39486, diff=-3.19446e-06
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=-17.9634, approx=-17.9634, diff=-8.32661e-07
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=-4.96857, approx=-4.96857, diff=-7.83297e-07
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=-1.77363, approx=-1.77363, diff=-3.283e-07
Filter a: conjugate pole/zero 4 angle
delPdelthetapa=-0.755846, approx=-0.755845, diff=-9.63503e-07
Filter a: conjugate pole/zero 5 angle
delPdelthetapa=-0.298183, approx=-0.298183, diff=-5.9748e-07
Filter b: real pole/zero 1
delEdelRpb=18.8616, approx=18.8616, diff=-1.4036e-08
Filter b: real pole/zero 2
delEdelRpb=11.7116, approx=11.7116, diff=3.84855e-08
Filter b: real pole/zero 3
delEdelRpb=1.63197, approx=1.63197, diff=-1.56855e-07
Filter b: conjugate pole/zero 1 radius
delEdelrpb=4.42407, approx=4.42407, diff=-1.64191e-06
Filter b: conjugate pole/zero 2 radius
delEdelrpb=5.16884, approx=5.16885, diff=-1.04625e-06
Filter b: conjugate pole/zero 3 radius
delEdelrpb=4.06603, approx=4.06603, diff=-2.94469e-06
Filter b: conjugate pole/zero 4 radius
delEdelrpb=3.45018, approx=3.45018, diff=-5.9869e-07
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=-7.32132, approx=-7.32132, diff=-3.6375e-07
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=-2.37111, approx=-2.37111, diff=-8.28468e-07
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=-0.923596, approx=-0.923596, diff=-3.52548e-07
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=-0.344337, approx=-0.344336, diff=-8.08206e-07
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

