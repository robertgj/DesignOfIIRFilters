#!/bin/sh

prog=Aerror_test.m

depends="Aerror_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
Aerror.m iirA.m fixResultNaN.m"
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
delEdelK=-123.994981, approx=-123.216092, diff=-0.778888
Real zero 1
delEdelR0=0.017297, approx=0.017296, diff=0.000001
Real zero 2
delEdelR0=0.006605, approx=0.006605, diff=0.000000
Real pole 1
delEdelRp=-0.008891, approx=-0.008892, diff=0.000001
Real pole 2
delEdelRp=-0.008891, approx=-0.008892, diff=0.000001
Conjugate zero 1
delEdelr0=-0.013153, approx=-0.013153, diff=0.000000
delEdeltheta0=-0.000653, approx=-0.000652, diff=-0.000000
Conjugate zero 2
delEdelr0=-0.013153, approx=-0.013153, diff=0.000000
delEdeltheta0=-0.000653, approx=-0.000652, diff=-0.000000
Conjugate zero 3
delEdelr0=-0.013153, approx=-0.013153, diff=0.000000
delEdeltheta0=-0.000653, approx=-0.000652, diff=-0.000000
Conjugate zero 4
delEdelr0=-0.006999, approx=-0.007000, diff=0.000001
delEdeltheta0=-0.008466, approx=-0.008466, diff=0.000000
Conjugate zero 5
delEdelr0=-0.011049, approx=-0.011049, diff=0.000001
delEdeltheta0=-0.005165, approx=-0.005164, diff=-0.000000
Conjugate zero 6
delEdelr0=-0.012074, approx=-0.012075, diff=0.000001
delEdeltheta0=-0.003757, approx=-0.003757, diff=-0.000000
Conjugate zero 7
delEdelr0=-0.012499, approx=-0.012499, diff=0.000000
delEdeltheta0=-0.002964, approx=-0.002964, diff=-0.000000
Conjugate pole 1
delEdelrp=0.007593, approx=0.007593, diff=0.000000
delEdelthetap=0.004799, approx=0.004798, diff=0.000000
Conjugate pole 2
delEdelrp=-0.007284, approx=-0.007284, diff=0.000000
delEdelthetap=0.006725, approx=0.006725, diff=0.000000
Conjugate pole 3
delEdelrp=0.004189, approx=0.004190, diff=-0.000000
delEdelthetap=0.006481, approx=0.006481, diff=0.000000

Compare hessErrorA to the approximation (hessErrorAD-hessErrorA)./hessErrorA
ans =    1.2861e-02

Compare hessErrorA to the approximation (hessErrorAD10-hessErrorA)./hessErrorA
ans =    1.2861e-03
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

