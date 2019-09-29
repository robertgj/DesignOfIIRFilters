#!/bin/sh

prog=iirT_test.m

depends="iirT_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iirT.m x2tf.m fixResultNaN.m"
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
delTdelK=0.000000, approx=0.000000, diff=0.000000
Real zero 1
delTdelR0=-0.057960, approx=-0.057930, diff=-0.000030
Real zero 2
delTdelR0=-0.474407, approx=-0.474409, diff=0.000003
Real pole 1
delTdelRp=-1.711070, approx=-1.711066, diff=-0.000004
Real pole 2
delTdelRp=2.079381, approx=2.079361, diff=0.000020
Conjugate zero 1
delTdelr0=-1.023688, approx=-1.023692, diff=0.000004
delTdeltheta0=-0.159615, approx=-0.159616, diff=0.000002
Conjugate zero 2
delTdelr0=-1.035084, approx=-1.035087, diff=0.000004
delTdeltheta0=-0.176108, approx=-0.176109, diff=0.000002
Conjugate zero 3
delTdelr0=-1.865366, approx=-1.865383, diff=0.000016
delTdeltheta0=1.475183, approx=1.475192, diff=-0.000009
Conjugate zero 4
delTdelr0=0.266704, approx=0.266733, diff=-0.000029
delTdeltheta0=1.376137, approx=1.376129, diff=0.000008
Conjugate zero 5
delTdelr0=0.854478, approx=0.854503, diff=-0.000025
delTdeltheta0=1.080557, approx=1.080548, diff=0.000008
Conjugate zero 6
delTdelr0=0.952294, approx=0.952317, diff=-0.000023
delTdeltheta0=0.997626, approx=0.997618, diff=0.000008
Conjugate zero 7
delTdelr0=0.972737, approx=0.972732, diff=0.000005
delTdeltheta0=0.080365, approx=0.080364, diff=0.000001
Conjugate zero 8
delTdelr0=0.966767, approx=0.966762, diff=0.000005
delTdeltheta0=0.068722, approx=0.068721, diff=0.000001
Conjugate zero 9
delTdelr0=0.952642, approx=0.952637, diff=0.000005
delTdeltheta0=0.030786, approx=0.030785, diff=0.000001
Conjugate zero 10
delTdelr0=1.066565, approx=1.066561, diff=0.000004
delTdeltheta0=0.180553, approx=0.180551, diff=0.000002
Conjugate pole 1
delTdelrp=8.650642, approx=8.650669, diff=-0.000027
delTdelthetap=-0.713785, approx=-0.713768, diff=-0.000017
Conjugate pole 2
delTdelrp=10.752245, approx=10.752102, diff=0.000143
delTdelthetap=-5.869993, approx=-5.869846, diff=-0.000148
Conjugate pole 3
delTdelrp=-0.738933, approx=-0.738995, diff=0.000062
delTdelthetap=2.758626, approx=2.758640, diff=-0.000014
Conjugate pole 4
delTdelrp=-3.006315, approx=-3.006345, diff=0.000030
delTdelthetap=1.345774, approx=1.345785, diff=-0.000012

Compare hessT to the approximation (hessTD-hessT)./hessT
ans =  0.00010468
EOF

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

