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
h = [ -0.0000680542,  0.0013300443, -0.0029234323,  0.0019914653, ... 
       0.0047716746, -0.0286118700, -0.0020999092,  0.0454408250, ... 
       0.0218980918,  0.0115385701,  0.0648003500,  0.0356108832, ... 
      -0.1459964457, -0.1776833295,  0.0746522890,  0.3741896586, ... 
       0.0756000375, -0.1769051895, -0.1456941684,  0.0344971139, ... 
       0.0630158395,  0.0075268835,  0.0190070860,  0.0431728307, ... 
      -0.0014694061, -0.0311438188,  0.0101134277, -0.0006627163, ... 
      -0.0000227944,  0.0000003023,  0.0000000582 ];
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

