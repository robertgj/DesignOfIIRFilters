#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_bandpass_test.m test_common.m delayz.m \
print_polynomial.m qroots.m qzsolve.oct"

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
h = [ -0.0105107063, -0.0023391167,  0.0034226662, -0.0067637393, ... 
       0.0098875336,  0.0629694886,  0.0322997863, -0.1186216989, ... 
      -0.1554211426,  0.0709502307,  0.2581899712,  0.0834376857, ... 
      -0.2121559210, -0.1911528883,  0.0609029867,  0.1436378297, ... 
       0.0264794641, -0.0287916342,  0.0075828679, -0.0126926634, ... 
      -0.0584265384, -0.0190183948,  0.0442458297,  0.0320555088, ... 
      -0.0079794523, -0.0076737856,  0.0012911068, -0.0105194292, ... 
      -0.0125094009,  0.0036561750,  0.0107145378 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_union_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

