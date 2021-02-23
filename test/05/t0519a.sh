#!/bin/sh

prog=directFIRnonsymmetric_kyp_lowpass_alternate_test.m

depends="directFIRnonsymmetric_kyp_lowpass_alternate_test.m test_common.m \
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
h = [  0.0019422298,  0.0169524216,  0.0338934627,  0.0342176022, ... 
       0.0046832482, -0.0410868558, -0.0593334717, -0.0052838723, ... 
       0.1230962369,  0.2669299689,  0.3391358977,  0.2886912126, ... 
       0.1437819132, -0.0065918097, -0.0795635268, -0.0579582065, ... 
       0.0069279975,  0.0470246234,  0.0341561745, -0.0067570343, ... 
      -0.0319700748, -0.0220656136,  0.0060294980,  0.0225055219, ... 
       0.0148463800, -0.0046559874, -0.0159734641, -0.0113913971, ... 
       0.0008966440,  0.0088607246,  0.0088974224 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_lowpass_alternate_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

