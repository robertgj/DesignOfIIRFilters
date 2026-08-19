#!/bin/sh

prog=directFIRnonsymmetric_qcqp_lowpass_test.m

depends="test/directFIRnonsymmetric_qcqp_lowpass_test.m test_common.m \
print_polynomial.m directFIRnonsymmetricEsqPW.m delayz.m"

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
h = [  -0.0014565890,  -0.0071395884,  -0.0076876682,   0.0073214721, ... 
        0.0234667707,   0.0053924662,  -0.0456243533,  -0.0523066449, ... 
        0.0692182548,   0.2812290322,   0.4128196938,   0.3285649955, ... 
        0.0932647180,  -0.0856748762,  -0.0848903126,   0.0167469542, ... 
        0.0644409978,   0.0171538434,  -0.0382894887,  -0.0296937865, ... 
        0.0140381762,   0.0275080257,   0.0026037338,  -0.0177372842, ... 
       -0.0097598735,   0.0070952971,   0.0093275201,   0.0001025507, ... 
       -0.0051937117,  -0.0029032924,   0.0001233901 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_qcqp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

