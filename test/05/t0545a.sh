#!/bin/sh

prog=directFIRnonsymmetric_kyp_highpass_test.m

depends="directFIRnonsymmetric_kyp_highpass_test.m test_common.m \
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
h = [ -0.0058344443,  0.0388411459, -0.0158120044, -0.0302726315, ... 
      -0.0177149777,  0.0293048673,  0.0620069160,  0.0234357072, ... 
      -0.1141158071, -0.2722140777,  0.6381487786, -0.2977109213, ... 
      -0.1309140530,  0.0265888771,  0.0875992161,  0.0423755220, ... 
      -0.0268116091, -0.0524691192, -0.0151729231,  0.0230203083, ... 
       0.0338286732,  0.0055939405, -0.0232078223, -0.0190488829, ... 
       0.0008936417,  0.0176620721,  0.0107643716, -0.0029244003, ... 
      -0.0152648999, -0.0063814603,  0.0159108196 ];
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

