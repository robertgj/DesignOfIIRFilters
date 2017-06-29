#!/bin/sh

prog=iirA_test.m

depends="iirA_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iirA.m x2tf.m fixResultNaN.m"
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
Caught error : Gradient of Rp==0 undefined when R>=2!
Caught error : Gradient of rp==0 undefined when R>=2!
delAdelK=12.713419, approx=12.713419, diff=0.000000
Real zero 1
delAdelR0=-0.079497, approx=-0.079496, diff=-0.000001
Real zero 2
delAdelR0=-0.072124, approx=-0.072124, diff=-0.000000
Real pole 1
delAdelRp=-0.058871, approx=-0.058871, diff=-0.000000
Real pole 2
delAdelRp=0.023025, approx=0.023025, diff=0.000001
Conjugate zero 1
delAdelr0=-0.133051, approx=-0.133051, diff=-0.000001
delAdeltheta0=-0.037017, approx=-0.037017, diff=0.000000
Conjugate zero 2
delAdelr0=-0.131130, approx=-0.131129, diff=-0.000001
delAdeltheta0=-0.039965, approx=-0.039965, diff=0.000000
Conjugate zero 3
delAdelr0=-0.141575, approx=-0.141575, diff=-0.000000
delAdeltheta0=0.099651, approx=0.099651, diff=-0.000001
Conjugate zero 4
delAdelr0=-0.038303, approx=-0.038303, diff=-0.000001
delAdeltheta0=0.111521, approx=0.111521, diff=-0.000000
Conjugate zero 5
delAdelr0=0.010758, approx=0.010759, diff=-0.000001
delAdeltheta0=0.105567, approx=0.105567, diff=-0.000000
Conjugate zero 6
delAdelr0=0.022657, approx=0.022658, diff=-0.000001
delAdeltheta0=0.102974, approx=0.102974, diff=-0.000000
Conjugate zero 7
delAdelr0=0.140896, approx=0.140896, diff=-0.000001
delAdeltheta0=0.020468, approx=0.020467, diff=0.000000
Conjugate zero 8
delAdelr0=0.141749, approx=0.141750, diff=-0.000001
delAdeltheta0=0.017691, approx=0.017690, diff=0.000000
Conjugate zero 9
delAdelr0=0.143723, approx=0.143723, diff=-0.000001
delAdeltheta0=0.008127, approx=0.008127, diff=0.000000
Conjugate zero 10
delAdelr0=0.113847, approx=0.113848, diff=-0.000001
delAdeltheta0=0.082903, approx=0.082902, diff=0.000000
Conjugate pole 1
delAdelrp=0.106910, approx=0.106909, diff=0.000001
delAdelthetap=-0.171958, approx=-0.171955, diff=-0.000003
Conjugate pole 2
delAdelrp=0.051048, approx=0.051046, diff=0.000002
delAdelthetap=-0.194892, approx=-0.194889, diff=-0.000003
Conjugate pole 3
delAdelrp=0.001928, approx=0.001927, diff=0.000000
delAdelthetap=0.063274, approx=0.063275, diff=-0.000000
Conjugate pole 4
delAdelrp=-0.072828, approx=-0.072828, diff=0.000000
delAdelthetap=0.042673, approx=0.042673, diff=-0.000000

Compare hessA to the approximation (hessAD-hessA)./hessA
ans =    1.7166e-04
EOF

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

