#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_double_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_double_bandpass_test.m \
test_common.m delayz.m print_polynomial.m"

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
h = [ -0.0195793412,  0.0210365264,  0.0192671237, -0.0118109999, ... 
       0.0035862575, -0.0150595245,  0.0009765008, -0.0217049961, ... 
       0.0079615322, -0.0361308690,  0.0722130350,  0.1603170500, ... 
      -0.1768658327, -0.0461452720, -0.1011380019, -0.0489544776, ... 
       0.4009500695, -0.0519276087, -0.1159923893, -0.0556179111, ... 
      -0.1961751674,  0.1890353021,  0.0901939899, -0.0360864377, ... 
       0.0081480030, -0.0340587684, -0.0011185657, -0.0269505506, ... 
       0.0037099707, -0.0144583177,  0.0377540428,  0.0352441659, ... 
      -0.0323044223, -0.0027535774, -0.0095224762, -0.0007689169, ... 
      -0.0008990172,  0.0022020776,  0.0039543716,  0.0048000869, ... 
       0.0064247428, -0.0106062646 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok \
         directFIRnonsymmetric_kyp_union_double_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

