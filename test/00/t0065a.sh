#!/bin/sh

prog=allpassT_test.m

depends="allpassT_test.m test_common.m allpassT.m a2tf.m"
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
Real pole/zero 1
delTdelRp=-2.152070, approx=-2.152069, diff=-0.000001
Real pole/zero 2
delTdelRp=-0.347760, approx=-0.347778, diff=0.000018
Real pole/zero 3
delTdelRp=-4.005686, approx=-4.005683, diff=-0.000002
Real pole/zero 4
delTdelRp=-3.582300, approx=-3.582297, diff=-0.000002
Real pole/zero 5
delTdelRp=-4.444352, approx=-4.444350, diff=-0.000002
Conjugate pole/zero 1
delTdelrp=-85.276554, approx=-85.276220, diff=-0.000335
delTdelthetap=-21.596431, approx=-21.596651, diff=0.000220
Conjugate pole/zero 2
delTdelrp=-6.210501, approx=-6.210499, diff=-0.000002
delTdelthetap=-1.056645, approx=-1.056644, diff=-0.000001
Conjugate pole/zero 3
delTdelrp=-12.237157, approx=-12.237160, diff=0.000003
delTdelthetap=-16.181559, approx=-16.181561, diff=0.000003
Conjugate pole/zero 4
delTdelrp=-6.485402, approx=-6.485405, diff=0.000003
delTdelthetap=2.449627, approx=2.449629, diff=-0.000002
Conjugate pole/zero 5
delTdelrp=-7.424372, approx=-7.424366, diff=-0.000007
delTdelthetap=3.108550, approx=3.108548, diff=0.000002
Real pole/zero 1
del2TdelRp2=2.332420, approx=2.332419, diff=0.000002
Real pole/zero 2
del2TdelRp2=-35.771492, approx=-35.771415, diff=-0.000078
Real pole/zero 3
del2TdelRp2=4.358388, approx=4.358388, diff=0.000001
Real pole/zero 4
del2TdelRp2=4.078659, approx=4.078657, diff=0.000002
Real pole/zero 5
del2TdelRp2=4.344463, approx=4.344464, diff=-0.000001
Conjugate pole/zero 1
del2Tdelrp2=669.227733, approx=669.224129, diff=0.003604
del2Tdelthetap2=-440.398016, approx=-440.396646, diff=-0.001370
Conjugate pole/zero 2
del2Tdelrp2=4.323099, approx=4.323101, diff=-0.000003
del2Tdelthetap2=2.024476, approx=2.024475, diff=0.000001
Conjugate pole/zero 3
del2Tdelrp2=-6.242217, approx=-6.241952, diff=-0.000264
del2Tdelthetap2=-5.095096, approx=-5.094947, diff=-0.000149
Conjugate pole/zero 4
del2Tdelrp2=-5.900180, approx=-5.900168, diff=-0.000012
del2Tdelthetap2=3.538190, approx=3.538192, diff=-0.000002
Conjugate pole/zero 5
del2Tdelrp2=13.461093, approx=13.461058, diff=0.000036
del2Tdelthetap2=-3.438810, approx=-3.438816, diff=0.000005
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

