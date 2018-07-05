#!/bin/sh

prog=iirP_test.m

depends="iirP_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iirP.m x2tf.m iirP_hessP_DiagonalApprox.m"
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
delPdelK=0.000000, approx=0.000000, diff=0.000000
Real zero 1
delPdelR0=1.332898, approx=1.332907, diff=-0.000009
Real zero 2
delPdelR0=0.285469, approx=0.285471, diff=-0.000002
Real pole 1
delPdelRp=-0.610036, approx=-0.610033, diff=-0.000003
Real pole 2
delPdelRp=-1.010705, approx=-1.010707, diff=0.000002
Conjugate zero 1
delPdelr0=0.615474, approx=0.615477, diff=-0.000003
delPdeltheta0=0.080134, approx=0.080135, diff=-0.000001
Conjugate zero 2
delPdelr0=0.622528, approx=0.622531, diff=-0.000003
delPdeltheta0=0.088102, approx=0.088103, diff=-0.000001
Conjugate zero 3
delPdelr0=-0.097313, approx=-0.097331, diff=0.000018
delPdeltheta0=-1.001010, approx=-1.001005, diff=-0.000005
Conjugate zero 4
delPdelr0=-0.678371, approx=-0.678385, diff=0.000014
delPdeltheta0=-0.669734, approx=-0.669728, diff=-0.000005
Conjugate zero 5
delPdelr0=-0.771948, approx=-0.771957, diff=0.000009
delPdeltheta0=-0.502975, approx=-0.502971, diff=-0.000004
Conjugate zero 6
delPdelr0=-0.781012, approx=-0.781020, diff=0.000008
delPdeltheta0=-0.462422, approx=-0.462418, diff=-0.000004
Conjugate zero 7
delPdelr0=-0.584898, approx=-0.584894, diff=-0.000003
delPdeltheta0=-0.040976, approx=-0.040975, diff=-0.000001
Conjugate zero 8
delPdelr0=-0.581395, approx=-0.581392, diff=-0.000004
delPdeltheta0=-0.035102, approx=-0.035101, diff=-0.000001
Conjugate zero 9
delPdelr0=-0.573159, approx=-0.573155, diff=-0.000004
delPdeltheta0=-0.015792, approx=-0.015791, diff=-0.000001
Conjugate zero 10
delPdelr0=-0.582942, approx=-0.582939, diff=-0.000002
delPdeltheta0=-0.078192, approx=-0.078192, diff=-0.000001
Conjugate pole 1
delPdelrp=1.566462, approx=1.566469, diff=-0.000007
delPdelthetap=-0.070743, approx=-0.070742, diff=-0.000001
Conjugate pole 2
delPdelrp=1.971972, approx=1.971970, diff=0.000002
delPdelthetap=-0.535413, approx=-0.535404, diff=-0.000010
Conjugate pole 3
delPdelrp=-1.259154, approx=-1.259162, diff=0.000009
delPdelthetap=0.629387, approx=0.629391, diff=-0.000005
Conjugate pole 4
delPdelrp=-1.355572, approx=-1.355571, diff=-0.000001
delPdelthetap=0.304096, approx=0.304099, diff=-0.000003

Compare hessP to the approximation (hessPD-hessP)./hessP
ans =  0.00019588
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

