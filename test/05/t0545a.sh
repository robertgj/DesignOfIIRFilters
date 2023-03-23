#!/bin/sh

prog=directFIRnonsymmetric_kyp_highpass_test.m

depends="test/directFIRnonsymmetric_kyp_highpass_test.m test_common.m \
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
h = [ -0.0045825352,  0.0366768451, -0.0153827183, -0.0294813114, ... 
      -0.0162397525,  0.0277250218,  0.0611649083,  0.0216628149, ... 
      -0.1115244180, -0.2636171081,  0.6221374979, -0.2922988982, ... 
      -0.1264764867,  0.0268274527,  0.0839883189,  0.0416028249, ... 
      -0.0269685198, -0.0480611381, -0.0142322338,  0.0132827072, ... 
       0.0414623810,  0.0065629447, -0.0258400656, -0.0203958772, ... 
       0.0025293169,  0.0177805595,  0.0121693140, -0.0046190103, ... 
      -0.0178807973, -0.0014015693,  0.0133257264 ];
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

