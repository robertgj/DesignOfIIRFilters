#!/bin/sh

prog=butt6OneMSD_test.m

depends="butt6OneMSD_test.m test_common.m \
spectralfactor.oct schurexpand.oct schurdecomp.oct bin2SD.oct \
schurOneMscale.m tf2schurOneMlattice.m schurOneMlatticeFilter.m flt2SD.m \
x2nextra.m crossWelch.m tf2pa.m qroots.m qzsolve.oct"

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
fc =    5.0000e-02
n =

   5.9796e-05   2.9898e-04   5.9796e-04   5.9796e-04   2.9898e-04   5.9796e-05

d =

   1.0000e+00  -3.9845e+00   6.4349e+00  -5.2536e+00   2.1651e+00  -3.5993e-01

nbits =    8.0000e+00
scale =    1.2800e+02
ndigits =    2.0000e+00
A1ksd =

  -9.375000000000000e-01   6.250000000000000e-01

A1csd =

   7.812500000000000e-02  -1.500000000000000e+00   6.250000000000000e-01

A2ksd =

  -9.687500000000000e-01   9.375000000000000e-01  -6.250000000000000e-01

A2csd =

 Columns 1 through 3:

   2.343750000000000e-02  -7.500000000000000e-01   3.750000000000000e-01

 Column 4:

  -6.250000000000000e-01

ans =

   1.1052e+02   1.2300e+02

ans =

   1.5710e+02   1.5472e+02   1.3331e+02

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

