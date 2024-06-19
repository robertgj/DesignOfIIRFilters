#!/bin/sh

prog=affineFIRsymmetric_lowpass_test.m

depends="test/affineFIRsymmetric_lowpass_test.m affineFIRsymmetric_lowpass.m \
test_common.m print_polynomial.m frefine.m local_max.m directFIRsymmetricA.m \
qroots.m \
qzsolve.oct"

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
cat > test_hM.ok << 'EOF'
hM = [  -0.0015354915,  -0.0027935586,  -0.0005350974,   0.0025612838, ... 
         0.0019847095,  -0.0030146978,  -0.0039715920,   0.0023433449, ... 
         0.0066374062,  -0.0004379921,  -0.0091369881,  -0.0033095998, ... 
         0.0108888765,   0.0088870186,  -0.0107796012,  -0.0162298272, ... 
         0.0077051550,   0.0247940105,  -0.0002036318,  -0.0338385150, ... 
        -0.0137467925,   0.0423716626,   0.0385605735,  -0.0493950809, ... 
        -0.0899799941,   0.0540125856,   0.3127505254,   0.4443748462 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok affineFIRsymmetric_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

