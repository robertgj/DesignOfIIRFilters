#!/bin/sh

prog=directFIRsymmetric_sdp_bandpass_test.m

depends="directFIRsymmetric_sdp_bandpass_test.m test_common.m \
print_polynomial.m directFIRsymmetricA.m directFIRsymmetric_sdp_basis.m \
directFIRsymmetricEsqPW.m local_max.m"

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
cat > test_hM15.ok << 'EOF'
hM15 = [  -0.0050212210,  -0.0004914749,  -0.0030950499,  -0.0113105537, ... 
           0.0059867975,   0.0160489505,  -0.0010735510,   0.0273233039, ... 
           0.0504467254,  -0.0193569773,  -0.0283613449,   0.0179456384, ... 
          -0.1414980800,  -0.2449774952,   0.1224896489,   0.4343808808 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM15.ok"; fail; fi

cat > test_hM16.ok << 'EOF'
hM16 = [  -0.0008351348,  -0.0054454580,  -0.0011921861,  -0.0049780307, ... 
          -0.0125508412,   0.0061337601,   0.0144382329,  -0.0011940030, ... 
           0.0301591095,   0.0509451233,  -0.0190933524,  -0.0248451934, ... 
           0.0185013400,  -0.1444429682,  -0.2441145679,   0.1213269401, ... 
           0.4293744717 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM16.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM15.ok directFIRsymmetric_sdp_bandpass_test_hM15_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM15.ok"; fail; fi

diff -Bb test_hM16.ok directFIRsymmetric_sdp_bandpass_test_hM16_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM16.ok"; fail; fi

#
# this much worked
#
pass

