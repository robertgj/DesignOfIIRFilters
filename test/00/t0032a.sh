#!/bin/sh

prog=allpassP_test.m

depends="test/allpassP_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
allpassP.m a2tf.m"
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
P=[  0.000  0.000 ]';
gradP=[  0.000  0.000 ]';
diagHessP=[  0.000  0.000 ]';
Real pole/zero 1
delPdelRp=0.423473, approx=0.423472, diff=0.000000
Real pole/zero 2
delPdelRp=2.665795, approx=2.665794, diff=0.000002
Real pole/zero 3
delPdelRp=0.862104, approx=0.862103, diff=0.000001
Real pole/zero 4
delPdelRp=0.746200, approx=0.746199, diff=0.000001
Real pole/zero 5
delPdelRp=1.003215, approx=1.003214, diff=0.000001
Conjugate pole/zero 1
delPdelrp=0.353727, approx=0.353733, diff=-0.000006
delPdelthetap=6.479071, approx=6.479068, diff=0.000003
Conjugate pole/zero 2
delPdelrp=1.245057, approx=1.245056, diff=0.000001
delPdelthetap=0.176204, approx=0.176203, diff=0.000000
Conjugate pole/zero 3
delPdelrp=-1.080106, approx=-1.080101, diff=-0.000005
delPdelthetap=2.664360, approx=2.664358, diff=0.000002
Conjugate pole/zero 4
delPdelrp=1.432029, approx=1.432029, diff=-0.000000
delPdelthetap=-0.418913, approx=-0.418913, diff=0.000000
Conjugate pole/zero 5
delPdelrp=0.844797, approx=0.844799, diff=-0.000002
delPdelthetap=-0.922739, approx=-0.922739, diff=0.000000
Real pole/zero 1
del2PdelRp2=-0.475645, approx=-0.475644, diff=-0.000000
Real pole/zero 2
del2PdelRp2=-3.736090, approx=-3.736091, diff=0.000001
Real pole/zero 3
del2PdelRp2=-1.275848, approx=-1.275846, diff=-0.000001
Real pole/zero 4
del2PdelRp2=-1.050581, approx=-1.050580, diff=-0.000001
Real pole/zero 5
del2PdelRp2=-1.556471, approx=-1.556470, diff=-0.000002
Conjugate pole/zero 1
del2Pdelrp2=11.596320, approx=11.596260, diff=0.000060
del2Pdelthetap2=-6.257635, approx=-6.257709, diff=0.000074
Conjugate pole/zero 2
del2Pdelrp2=-1.190830, approx=-1.190830, diff=-0.000000
del2Pdelthetap2=-0.324821, approx=-0.324821, diff=-0.000000
Conjugate pole/zero 3
del2Pdelrp2=10.678965, approx=10.678944, diff=0.000021
del2Pdelthetap2=-4.492491, approx=-4.492493, diff=0.000002
Conjugate pole/zero 4
del2Pdelrp2=0.175816, approx=0.175813, diff=0.000003
del2Pdelthetap2=-0.600942, approx=-0.600943, diff=0.000000
Conjugate pole/zero 5
del2Pdelrp2=3.589795, approx=3.589788, diff=0.000006
del2Pdelthetap2=-0.069642, approx=-0.069641, diff=-0.000001
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

