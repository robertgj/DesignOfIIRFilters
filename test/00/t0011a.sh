#!/bin/sh

prog=errorE_test.m

depends="obsolete/errorE_test.m obsolete/errorE.m \
test_common.m print_polynomial.m print_pole_zero.m \
iirA.m iirT.m fixResultNaN.m"

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
delEdelK=-19.799442, approx=-19.787039, diff=-0.012403
Real zero 1
delEdelR0=1.163578, approx=1.163587, diff=-0.000009
Real zero 2
delEdelR0=0.210844, approx=0.210845, diff=-0.000001
Real pole 1
delEdelRp=-0.787004, approx=-0.787003, diff=-0.000002
Real pole 2
delEdelRp=-0.787004, approx=-0.787003, diff=-0.000002
Conjugate zero 1
delEdelr0=-0.421589, approx=-0.421586, diff=-0.000003
delEdeltheta0=-0.010964, approx=-0.010963, diff=-0.000000
Conjugate zero 2
delEdelr0=-0.421589, approx=-0.421586, diff=-0.000003
delEdeltheta0=-0.010964, approx=-0.010963, diff=-0.000000
Conjugate zero 3
delEdelr0=-0.421589, approx=-0.421586, diff=-0.000003
delEdeltheta0=-0.010964, approx=-0.010963, diff=-0.000000
Conjugate zero 4
delEdelr0=-0.588845, approx=-0.588847, diff=0.000003
delEdeltheta0=-0.277568, approx=-0.277566, diff=-0.000002
Conjugate zero 5
delEdelr0=-0.502665, approx=-0.502664, diff=-0.000002
delEdeltheta0=-0.114535, approx=-0.114535, diff=-0.000001
Conjugate zero 6
delEdelr0=-0.466034, approx=-0.466032, diff=-0.000002
delEdeltheta0=-0.073408, approx=-0.073407, diff=-0.000001
Conjugate zero 7
delEdelr0=-0.449245, approx=-0.449242, diff=-0.000002
delEdeltheta0=-0.054701, approx=-0.054700, diff=-0.000001
Conjugate pole 1
delEdelrp=0.847970, approx=0.847976, diff=-0.000006
delEdelthetap=0.391964, approx=0.391962, diff=0.000002
Conjugate pole 2
delEdelrp=-0.762374, approx=-0.762377, diff=0.000003
delEdelthetap=0.674495, approx=0.674498, diff=-0.000003
Conjugate pole 3
delEdelrp=0.626208, approx=0.626218, diff=-0.000010
delEdelthetap=0.601829, approx=0.601827, diff=0.000003

Compare hessE to the approximation (hessED-hessE)./hessE
ans =  0.0012822

Compare hessE to the approximation (hessED10-hessE)./hessE
ans =    1.2822e-04
ans =  10.258
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

