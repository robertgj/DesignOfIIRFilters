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
warning: Using diagonal-only approximation to hessP!
warning: called from
    Perror at line 100 column 3
    Perror_test at line 56 column 34
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
ans =  21.307

Compare hessErrorP to the approximation (hessErrorPD10-hessErrorP)./hessErrorP
ans =
   0.00000
  -6.58988
  -0.33475
   4.27580
   4.27580
  -0.59606
  -0.59606
  -0.59606
   0.81585
  -0.25436
  -0.44344
  -0.50949
  -0.09833
  -0.09833
  -0.09833
  -0.51159
  -0.21877
  -0.15638
  -0.13253
   0.06012
  -3.80028
  -1.39607
   0.68547
   1.29400
   1.12741

hessErrorP10_del =
            NaN
   0.0000154410
   0.0000086558
   0.0000119992
   0.0000119992
  -0.0000070788
  -0.0000070788
  -0.0000070788
  -0.0000250476
   0.0000228292
   0.0000018408
  -0.0000023401
  -0.0000012504
  -0.0000012504
  -0.0000012504
  -0.0000078000
  -0.0000067303
  -0.0000056145
  -0.0000046181
   0.0004975547
   0.0000061749
  -0.0000269051
  -0.0000066576
   0.0000076202
  -0.0000072304

ans =  0.00049755
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

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

