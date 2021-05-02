#!/bin/sh

prog=directFIRnonsymmetric_socp_lowpass_test.m
depends="directFIRnonsymmetric_socp_lowpass_test.m test_common.m \
directFIRnonsymmetricEsqPW.m print_polynomial.m"

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
h = [  -0.0042477821,  -0.0100321651,  -0.0055113226,   0.0139949470, ... 
        0.0257508711,  -0.0019173741,  -0.0535366135,  -0.0483407796, ... 
        0.0812247585,   0.2838583335,   0.4006985881,   0.3186391905, ... 
        0.1007575061,  -0.0709997118,  -0.0845585932,   0.0021185804, ... 
        0.0562731786,   0.0269180573,  -0.0254789957,  -0.0320020865, ... 
        0.0013673636,   0.0230306848,   0.0110861041,  -0.0097336498, ... 
       -0.0124726072,  -0.0004610972,   0.0074359811,   0.0044293255, ... 
       -0.0015263431,  -0.0031482038,  -0.0014018788 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -bB test_h_coef.ok directFIRnonsymmetric_socp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass

