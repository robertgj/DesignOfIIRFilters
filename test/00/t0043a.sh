#!/bin/sh

prog=Terror_test.m

depends="Terror_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
Terror.m iirT.m fixResultNaN.m"
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
Scale factor
delEdelK=0.000000, approx=0.000000, diff=0.000000
Real zero 1
delEdelR0=7.363749, approx=7.364324, diff=-0.000575
Real zero 2
delEdelR0=1.311754, approx=1.311840, diff=-0.000086
Real pole 1
delEdelRp=-4.992753, approx=-4.992656, diff=-0.000097
Real pole 2
delEdelRp=-4.992753, approx=-4.992656, diff=-0.000097
Conjugate zero 1
delEdelr0=-2.622937, approx=-2.622762, diff=-0.000175
delEdeltheta0=-0.067799, approx=-0.067775, diff=-0.000024
Conjugate zero 2
delEdelr0=-2.622937, approx=-2.622762, diff=-0.000175
delEdeltheta0=-0.067799, approx=-0.067775, diff=-0.000024
Conjugate zero 3
delEdelr0=-2.622937, approx=-2.622762, diff=-0.000175
delEdeltheta0=-0.067799, approx=-0.067775, diff=-0.000024
Conjugate zero 4
delEdelr0=-3.678962, approx=-3.679140, diff=0.000179
delEdeltheta0=-1.722298, approx=-1.722146, diff=-0.000152
Conjugate zero 5
delEdelr0=-3.132138, approx=-3.132041, diff=-0.000098
delEdeltheta0=-0.709502, approx=-0.709443, diff=-0.000059
Conjugate zero 6
delEdelr0=-2.901885, approx=-2.901743, diff=-0.000142
delEdeltheta0=-0.454408, approx=-0.454368, diff=-0.000041
Conjugate zero 7
delEdelr0=-2.796472, approx=-2.796315, diff=-0.000157
delEdeltheta0=-0.338487, approx=-0.338453, diff=-0.000034
Conjugate pole 1
delEdelrp=5.334724, approx=5.335123, diff=-0.000399
delEdelthetap=2.437158, approx=2.437022, diff=0.000135
Conjugate pole 2
delEdelrp=-4.695877, approx=-4.696035, diff=0.000158
delEdelthetap=4.268042, approx=4.268226, diff=-0.000184
Conjugate pole 3
delEdelrp=3.990675, approx=3.991304, diff=-0.000629
delEdelthetap=3.747157, approx=3.746992, diff=0.000164

Compare hessErrorT to the approximation (hessErrorTD-hessErrorT)./hessErrorT
ans =    2.8667e-03

Compare hessErrorT to the approximation (hessErrorTD10-hessErrorT)./hessErrorT
ans =    2.8664e-04
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

