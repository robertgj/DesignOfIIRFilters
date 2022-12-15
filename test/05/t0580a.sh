#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_double_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_double_bandpass_test.m \
test_common.m print_polynomial.m"

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
h = [ -0.0186228625,  0.0210252139,  0.0190383849, -0.0117229419, ... 
       0.0034191199, -0.0149057926,  0.0007668903, -0.0214845367, ... 
       0.0077469060, -0.0352403122,  0.0724124418,  0.1590721125, ... 
      -0.1765953554, -0.0463769641, -0.1008277833, -0.0489968839, ... 
       0.4010699738, -0.0517753685, -0.1157703954, -0.0550621468, ... 
      -0.1978441656,  0.1891844501,  0.0906331228, -0.0359937110, ... 
       0.0085162461, -0.0343898348, -0.0008133193, -0.0271642233, ... 
       0.0040832007, -0.0153506195,  0.0374983338,  0.0361249069, ... 
      -0.0324524171, -0.0024391217, -0.0098122923, -0.0007070099, ... 
      -0.0009896627,  0.0021990803,  0.0039240691,  0.0044838153, ... 
       0.0071788833, -0.0106611839 ];
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

