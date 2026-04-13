#!/bin/sh

prog=directFIRnonsymmetric_kyp_highpass_test.m

depends="test/directFIRnonsymmetric_kyp_highpass_test.m test_common.m delayz.m \
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
h = [ -0.0045825373,  0.0366769551, -0.0153828542, -0.0294812090, ... 
      -0.0162398888,  0.0277251738,  0.0611648176,  0.0216629085, ... 
      -0.1115244845, -0.2636171176,  0.6221374460, -0.2922988020, ... 
      -0.1264764380,  0.0268273519,  0.0839883538,  0.0416027601, ... 
      -0.0269684460, -0.0480611787, -0.0142321503,  0.0132826796, ... 
       0.0414622760,  0.0065630023, -0.0258400673, -0.0203957930, ... 
       0.0025292031,  0.0177806606,  0.0121691664, -0.0046188815, ... 
      -0.0178808969, -0.0014014366,  0.0133256214 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_highpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

