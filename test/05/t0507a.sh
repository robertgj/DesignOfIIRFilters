#!/bin/sh

prog=sedumi_minphase_test.m
depends="sedumi_minphase_test.m sedumi_minphase_test_data.mat \
test_common.m print_polynomial.m qroots.m qzsolve.oct"

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
cat > test_h_coef.ok << 'EOF'
h = [  -0.0250545106,  -0.0615715055,  -0.1195110248,  -0.1796169332, ... 
       -0.2258186829,  -0.2343941305,  -0.1960909481,  -0.1170261138, ... 
       -0.0205311775,   0.0605715264,   0.1002036603,   0.0890372474, ... 
        0.0398179311,  -0.0191505578,  -0.0589890291,  -0.0628578173, ... 
       -0.0342176871,   0.0076497566,   0.0391427434,   0.0449975871, ... 
        0.0257683124,  -0.0045280812,  -0.0278474974,  -0.0322528204, ... 
       -0.0181583029,   0.0037842907,   0.0201567340,   0.0224946706, ... 
        0.0118164136,  -0.0036514267,  -0.0143700372,  -0.0148591080, ... 
       -0.0068007329,   0.0035889030,   0.0100003682,   0.0091328044, ... 
        0.0033524267,  -0.0032620575,  -0.0065716531,  -0.0050444467, ... 
       -0.0013057414,   0.0026813944,   0.0040026754,   0.0023363412, ... 
        0.0009234865,  -0.0031553196,  -0.0035462688,   0.0016757831 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -bB test_h_coef.ok sedumi_minphase_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass

