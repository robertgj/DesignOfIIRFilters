#!/bin/sh

prog=parallel_allpass_mmse_error_test.m

depends="parallel_allpass_mmse_error_test.m test_common.m \
print_polynomial.m print_pole_zero.m parallel_allpass_mmse_error.m \
allpassP.m allpassT.m parallel_allpassAsq.m parallel_allpassT.m a2tf.m tf2a.m \
qroots.m qzsolve.oct"

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
fap =  0.1500
Wap =  1
fas =  0.2000
Was =  400
ftp =  0.1750
Wtp =  100
tp =  28.750
Filter a: real pole/zero 1
delEdelRpa=4673.940449, approx=4673.963635, diff=-0.023186
Filter a: real pole/zero 2
delEdelRpa=361.157769, approx=361.143444, diff=0.014325
Filter a: real pole/zero 3
delEdelRpa=1489.506878, approx=1489.509756, diff=-0.002878
Filter a: conjugate pole/zero 1 radius
delEdelrpa=-3077.566820, approx=-3077.589619, diff=0.022799
Filter a: conjugate pole/zero 2 radius
delEdelrpa=3071.420711, approx=3071.452615, diff=-0.031904
Filter a: conjugate pole/zero 3 radius
delEdelrpa=-7175.177916, approx=-7175.204188, diff=0.026271
Filter a: conjugate pole/zero 4 radius
delEdelrpa=1576.248297, approx=1576.269966, diff=-0.021669
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=-376.626350, approx=-376.605160, diff=-0.021190
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=-3836.954243, approx=-3836.975284, diff=0.021041
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=-391.589395, approx=-391.575202, diff=-0.014192
Filter a: conjugate pole/zero 4 angle
delPdelthetapa=1905.953966, approx=1905.942594, diff=0.011372
Filter b: conjugate pole/zero 1 radius
delEdelrpb=5578.027612, approx=5578.045279, diff=-0.017667
Filter b: conjugate pole/zero 2 radius
delEdelrpb=-6054.692939, approx=-6054.697249, diff=0.004310
Filter b: conjugate pole/zero 3 radius
delEdelrpb=14726.941308, approx=14726.929221, diff=0.012087
Filter b: conjugate pole/zero 4 radius
delEdelrpb=-5583.923578, approx=-5583.929036, diff=0.005458
Filter b: conjugate pole/zero 5 radius
delEdelrpb=-2157.991949, approx=-2157.988612, diff=-0.003336
Filter b: conjugate pole/zero 6 radius
delEdelrpb=-6573.070980, approx=-6573.073100, diff=0.002121
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=-2102.987896, approx=-2102.982835, diff=-0.005061
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=-1201.734673, approx=-1201.741044, diff=0.006371
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=-9963.253300, approx=-9963.255827, diff=0.002527
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=-2728.243718, approx=-2728.240968, diff=-0.002749
Filter b: conjugate pole/zero 5 angle
delPdelthetapb=-928.716030, approx=-928.719131, diff=0.003102
Filter b: conjugate pole/zero 6 angle
delPdelthetapb=-2367.480766, approx=-2367.476314, diff=-0.004452
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

