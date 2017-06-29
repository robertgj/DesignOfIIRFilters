#!/bin/sh

prog=parallel_allpass_mmse_error_test.m

depends="parallel_allpass_mmse_error_test.m test_common.m \
print_polynomial.m print_pole_zero.m parallel_allpass_mmse_error.m \
allpassP.m allpassT.m parallel_allpassAsq.m parallel_allpassT.m a2tf.m tf2a.m"
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
verbose =  1
fap =  0.15000
Wap =  1
fas =  0.20000
Was =  400
ftp =  0.17500
Wtp =  100
tp =  28.750
Filter a: real pole/zero 1
delEdelRpa=-13.559392, approx=-13.559406, diff=0.000014
Filter a: real pole/zero 2
delEdelRpa=14.743526, approx=14.745057, diff=-0.001531
Filter a: real pole/zero 3
delEdelRpa=219.551689, approx=219.552136, diff=-0.000447
Filter a: conjugate pole/zero 1 radius
delEdelrpa=59.285387, approx=59.286218, diff=-0.000830
Filter a: conjugate pole/zero 2 radius
delEdelrpa=-49.227486, approx=-49.225840, diff=-0.001647
Filter a: conjugate pole/zero 3 radius
delEdelrpa=-347.714083, approx=-347.709071, diff=-0.005013
Filter a: conjugate pole/zero 4 radius
delEdelrpa=1540.775789, approx=1540.783307, diff=-0.007518
Filter a: conjugate pole/zero 1 angle
delPdelthetapa=50.493286, approx=50.493234, diff=0.000052
Filter a: conjugate pole/zero 2 angle
delPdelthetapa=101.499284, approx=101.499724, diff=-0.000439
Filter a: conjugate pole/zero 3 angle
delPdelthetapa=389.546779, approx=389.548173, diff=-0.001393
Filter a: conjugate pole/zero 4 angle
delPdelthetapa=-192.615267, approx=-192.614955, diff=-0.000312
Filter b: conjugate pole/zero 1 radius
delEdelrpb=16.889434, approx=16.893678, diff=-0.004243
Filter b: conjugate pole/zero 2 radius
delEdelrpb=2052.950838, approx=2052.961642, diff=-0.010804
Filter b: conjugate pole/zero 3 radius
delEdelrpb=1759.505702, approx=1759.519161, diff=-0.013459
Filter b: conjugate pole/zero 4 radius
delEdelrpb=-1719.040736, approx=-1719.038171, diff=-0.002565
Filter b: conjugate pole/zero 5 radius
delEdelrpb=-457.465827, approx=-457.462539, diff=-0.003289
Filter b: conjugate pole/zero 6 radius
delEdelrpb=78.041933, approx=78.048795, diff=-0.006862
Filter b: conjugate pole/zero 1 angle
delPdelthetapb=216.934817, approx=216.938398, diff=-0.003580
Filter b: conjugate pole/zero 2 angle
delPdelthetapb=165.608493, approx=165.609759, diff=-0.001266
Filter b: conjugate pole/zero 3 angle
delPdelthetapb=-1793.736962, approx=-1793.734561, diff=-0.002400
Filter b: conjugate pole/zero 4 angle
delPdelthetapb=-197.552781, approx=-197.549210, diff=-0.003570
Filter b: conjugate pole/zero 5 angle
delPdelthetapb=326.023379, approx=326.024957, diff=-0.001578
Filter b: conjugate pole/zero 6 angle
delPdelthetapb=92.168594, approx=92.169522, diff=-0.000928
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

