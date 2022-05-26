#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_test.m

depends="test/directFIRnonsymmetric_kyp_lowpass_test.m test_common.m \
print_polynomial.m"

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
h = [ -0.0023662932,  0.0146336075,  0.0318179853,  0.0347157199, ... 
       0.0074935791, -0.0382567401, -0.0587372915, -0.0073013038, ... 
       0.1200768355,  0.2648504641,  0.3384933976,  0.2884460008, ... 
       0.1427249947, -0.0083692582, -0.0808540027, -0.0579331536, ... 
       0.0076237937,  0.0468265244,  0.0322427339, -0.0095033788, ... 
      -0.0337559833, -0.0219250275,  0.0073005502,  0.0232055585, ... 
       0.0140244705, -0.0063448394, -0.0169278240, -0.0105233595, ... 
       0.0031907526,  0.0107458268,  0.0111728102 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

