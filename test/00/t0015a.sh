#!/bin/sh

prog=local_peak_test.m

depends="iirA.m local_max.m \
test_common.m print_polynomial.m print_pole_zero.m \
local_peak.m local_peak_test.m fixResultNaN.m"
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
xpeak =  1
ypeak =  1
xpeak =  1
ypeak =  1
ipeak =  1
idxpeak =
     21
     83
    140
    351
    413
    478
    691
    817
   1024

idxtrough =
     1
    66
    98
   253
   390
   453
   582
   783
   913

xpeak =
 Columns 1 through 7:
     21.306     82.534    140.415    350.681    412.831    478.296    690.548
 Columns 8 and 9:
    817.067   1024.000

ypeak =
 Columns 1 through 8:
   0.92158   0.51419   0.81116   0.98906   0.67320   0.48302   1.05413   0.43795
 Column 9:
   1.34808

xpeak =
 Columns 1 through 7:
     21.306     82.534    140.415    350.681    412.831    478.296    690.548
 Columns 8 and 9:
    817.067   1024.000

ypeak =
 Columns 1 through 8:
   0.92158   0.51419   0.81116   0.98906   0.67320   0.48302   1.05413   0.43795
 Column 9:
   1.34808

ipeak =
     21     82    140    350    412    478    690    817   1024

xtrough =
     1.0000
    65.8337
    98.4863
   252.5867
   389.6962
   452.7632
   582.2224
   783.0198
   912.6768

ytrough =
  -0.54931
  -0.49949
  -0.50167
   1.58988
  -0.59296
  -0.38015
   1.66073
  -0.10620
   1.47290

itrough =
     1
    65
    98
   252
   389
   452
   582
   783
   912

xpeak =
 Columns 1 through 8:
   0.12472   0.50078   0.85627   2.14771   2.52944   2.93151   4.23515   5.01222
 Column 9:
   6.28319

ypeak =
 Columns 1 through 8:
   0.92158   0.51419   0.81116   0.98906   0.67320   0.48302   1.05413   0.43795
 Column 9:
   1.34808

ipeak =
     21     82    140    350    412    478    690    817   1024

xtrough =
   0.00000
   0.39820
   0.59875
   1.54523
   2.38734
   2.77469
   3.56982
   4.80310
   5.59945

ytrough =
  -0.54931
  -0.49949
  -0.50167
   1.58988
  -0.59296
  -0.38015
   1.66073
  -0.10620
   1.47290

itrough =
     1
    65
    98
   252
   389
   452
   582
   783
   912

wAl =
   0.38426
   0.94091
   1.94269
   2.29358
   2.83523

dAl =
  -0.096819907
   0.055345738
  -0.002220661
  -0.000036714
  -0.000088383

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

