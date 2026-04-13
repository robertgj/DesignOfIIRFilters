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
h = [  0.0018104598, -0.0005644451, -0.0042213442, -0.0019648005, ... 
      -0.0142539627,  0.0196284833,  0.0148865157, -0.0076760241, ... 
       0.0031584178, -0.0139663961,  0.0003406905, -0.0263491435, ... 
       0.0066789133, -0.0281538193,  0.0743832754,  0.1474433986, ... 
      -0.1690025027, -0.0418372593, -0.1062556421, -0.0479752181, ... 
       0.3961256096, -0.0506776301, -0.1101652248, -0.0514645382, ... 
      -0.2107376536,  0.1924950295,  0.1038449862, -0.0474323731, ... 
       0.0083499992, -0.0345421069, -0.0006138971, -0.0230547131, ... 
       0.0046233526, -0.0210905311,  0.0354576950,  0.0497044091, ... 
      -0.0406447869, -0.0079615243, -0.0043195733, -0.0019159558, ... 
       0.0011428023,  0.0010373709,  0.0027906635,  0.0029766020, ... 
       0.0123688900, -0.0121424645, -0.0072640278,  0.0046574034, ... 
      -0.0002035822 ];
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

