#!/bin/sh

prog=polyphase_allpass_mmse_error_test.m
depends="test/polyphase_allpass_mmse_error_test.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m \
parallel_allpass_mmse_error.m parallel_allpassAsq.m parallel_allpassT.m \
allpassP.m allpassT.m a2tf.m tf2a.m qroots.oct"

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
fap = 0.2200
Wap = 1
fas = 0.2800
Was = 1000
ftp = 0.2200
Wtp = 10
td = 22
Filter a: real pole/zero 1
delEdelRpa=1.62535, approx=1.62535, diff=-2.9488e-07
Filter a: conjugate pole/zero 1 radius
delEdelrpa=-3.02654, approx=-3.02654, diff=-3.54896e-06
Filter a: conjugate pole/zero 2 radius
delEdelrpa=6.43966, approx=6.43966, diff=7.70053e-08
Filter a: conjugate pole/zero 3 radius
delEdelrpa=4.94033, approx=4.94033, diff=-3.75053e-06
Filter a: conjugate pole/zero 4 radius
delEdelrpa=3.89296, approx=3.89296, diff=-3.37411e-06
Filter a: conjugate pole/zero 5 radius
delEdelrpa=3.39443, approx=3.39443, diff=-1.41682e-06
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=-17.961, approx=-17.961, diff=-6.1116e-07
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=-4.96794, approx=-4.96794, diff=-1.0181e-06
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=-1.77341, approx=-1.7734, diff=-1.84052e-07
Filter a: conjugate pole/zero 4 angle
delPdelthetapa=-0.755748, approx=-0.755748, diff=-5.05094e-07
Filter a: conjugate pole/zero 5 angle
delPdelthetapa=-0.298144, approx=-0.298144, diff=-7.89414e-08
Filter b: real pole/zero 1
delEdelRpb=18.8642, approx=18.8642, diff=2.97532e-07
Filter b: real pole/zero 2
delEdelRpb=1.63218, approx=1.63218, diff=-9.5917e-07
Filter b: real pole/zero 3
delEdelRpb=11.7132, approx=11.7132, diff=5.79355e-07
Filter b: conjugate pole/zero 1 radius
delEdelrpb=4.42468, approx=4.42468, diff=-2.21659e-06
Filter b: conjugate pole/zero 2 radius
delEdelrpb=5.16951, approx=5.16951, diff=-7.39148e-07
Filter b: conjugate pole/zero 3 radius
delEdelrpb=4.06655, approx=4.06655, diff=-6.78973e-07
Filter b: conjugate pole/zero 4 radius
delEdelrpb=3.45063, approx=3.45063, diff=-6.81637e-07
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=-7.32226, approx=-7.32226, diff=-3.90267e-07
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=-2.37141, approx=-2.37141, diff=3.49518e-08
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=-0.923714, approx=-0.923714, diff=6.07756e-08
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=-0.344381, approx=-0.34438, diff=-4.76044e-07
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

