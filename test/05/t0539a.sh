#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_bandpass_test.m test_common.m \
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
h = [ -0.0105267281, -0.0023309565,  0.0034580276, -0.0067319729, ... 
       0.0098838215,  0.0629547660,  0.0322964099, -0.1186336998, ... 
      -0.1554347420,  0.0709832188,  0.2582547832,  0.0834520578, ... 
      -0.2122070654, -0.1911982218,  0.0608914696,  0.1436285708, ... 
       0.0264805958, -0.0287534963,  0.0076134600, -0.0127273992, ... 
      -0.0584945997, -0.0190542045,  0.0442401541,  0.0320493375, ... 
      -0.0079809371, -0.0076658025,  0.0012812453, -0.0105572048, ... 
      -0.0125438094,  0.0036449880,  0.0107185057 ];
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

