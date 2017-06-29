#!/bin/sh

prog=Perror_test.m

depends="Perror_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
Perror.m iirP.m iirP_hessP_DiagonalApprox.m fixResultNaN.m"
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
delEdelR0=-2.790065, approx=-2.790394, diff=0.000330
Real zero 2
delEdelR0=-0.281828, approx=-0.281845, diff=0.000017
Real pole 1
delEdelRp=1.978803, approx=1.979016, diff=-0.000214
Real pole 2
delEdelRp=1.978803, approx=1.979016, diff=-0.000214
Conjugate zero 1
delEdelr0=0.563446, approx=0.563416, diff=0.000030
delEdeltheta0=0.013849, approx=0.013844, diff=0.000005
Conjugate zero 2
delEdelr0=0.563446, approx=0.563416, diff=0.000030
delEdeltheta0=0.013849, approx=0.013844, diff=0.000005
Conjugate zero 3
delEdelr0=0.563446, approx=0.563416, diff=0.000030
delEdeltheta0=0.013849, approx=0.013844, diff=0.000005
Conjugate zero 4
delEdelr0=0.813902, approx=0.813942, diff=-0.000041
delEdeltheta0=0.336319, approx=0.336293, diff=0.000026
Conjugate zero 5
delEdelr0=0.673335, approx=0.673322, diff=0.000013
delEdeltheta0=0.142043, approx=0.142032, diff=0.000011
Conjugate zero 6
delEdelr0=0.622949, approx=0.622927, diff=0.000022
delEdeltheta0=0.091813, approx=0.091805, diff=0.000008
Conjugate zero 7
delEdelr0=0.600325, approx=0.600299, diff=0.000025
delEdeltheta0=0.068675, approx=0.068668, diff=0.000007
Conjugate pole 1
delEdelrp=-1.372798, approx=-1.372795, diff=-0.000003
delEdelthetap=-0.446044, approx=-0.446010, diff=-0.000034
Conjugate pole 2
delEdelrp=0.005857, approx=0.005667, diff=0.000190
delEdelthetap=-1.273254, approx=-1.273189, diff=-0.000065
Conjugate pole 3
delEdelrp=-1.314919, approx=-1.314989, diff=0.000070
delEdelthetap=-0.680936, approx=-0.680880, diff=-0.000056

Compare hessErrorP to the approximation (hessErrorPD-hessErrorP)./hessErrorP
ans =    2.1307e+01

Compare hessErrorP to the approximation (hessErrorPD10-hessErrorP)./hessErrorP
ans =

   0.0000e+00
  -6.5899e+00
  -3.3475e-01
   4.2758e+00
   4.2758e+00
  -5.9606e-01
  -5.9606e-01
  -5.9606e-01
   8.1585e-01
  -2.5436e-01
  -4.4344e-01
  -5.0949e-01
  -9.8328e-02
  -9.8328e-02
  -9.8328e-02
  -5.1159e-01
  -2.1877e-01
  -1.5638e-01
  -1.3253e-01
   6.0125e-02
  -3.8003e+00
  -1.3961e+00
   6.8547e-01
   1.2940e+00
   1.1274e+00

hessErrorP10_del =

          NaN
   1.5441e-05
   8.6558e-06
   1.1999e-05
   1.1999e-05
  -7.0788e-06
  -7.0788e-06
  -7.0788e-06
  -2.5048e-05
   2.2829e-05
   1.8408e-06
  -2.3401e-06
  -1.2504e-06
  -1.2504e-06
  -1.2504e-06
  -7.8000e-06
  -6.7303e-06
  -5.6145e-06
  -4.6181e-06
   4.9755e-04
   6.1749e-06
  -2.6905e-05
  -6.6576e-06
   7.6202e-06
  -7.2304e-06

ans =    4.9755e-04
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

