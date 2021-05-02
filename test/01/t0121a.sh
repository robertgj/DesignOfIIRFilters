#!/bin/sh

prog=butt6OneMSD_test.m

depends="butt6OneMSD_test.m test_common.m print_polynomial.m \
schurOneMscale.m tf2schurOneMlattice.m schurOneMlatticeFilter.m \
flt2SD.m x2nextra.m crossWelch.m tf2pa.m qroots.m p2n60.m \
qzsolve.oct spectralfactor.oct schurexpand.oct schurdecomp.oct bin2SD.oct"

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
fc = 0.050000
n60 = 73
nbits = 8
scale = 128
ndigits = 2
n = [  0.0000597958,  0.0002989789,  0.0005979578,  0.0005979578, ... 
       0.0002989789,  0.0000597958 ];
d = [  1.0000000000, -3.9845431196,  6.4348670903, -5.2536151704, ... 
       2.1651329097, -0.3599282451 ];
A1ksd = [  -0.93750000,   0.62500000 ];
A1ksd = [  -0.93750000,   0.62500000 ];
A1csd = [   0.07812500,  -1.50000000,   0.62500000 ];
A2ksd = [  -0.93750000,   0.62500000 ];
A2csd = [  -0.93750000,   0.62500000 ];
A1stdxf =
   110.27   122.99

A2stdxf =
   156.68   154.54   133.27

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

