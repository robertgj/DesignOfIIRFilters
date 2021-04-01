#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_test.m

depends="directFIRnonsymmetric_kyp_bandpass_test.m test_common.m \
direct_form_scale.m complementaryFIRlattice.m complementaryFIRlatticeAsq.m \
complementaryFIRlatticeT.m minphase.m complementaryFIRlattice2Abcd.m \
H2Asq.m H2T.m print_polynomial.m complementaryFIRlatticeFilter.m crossWelch.m \
complementaryFIRdecomp.oct Abcd2H.oct"

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
h = [ -0.0103310127, -0.0024160216,  0.0030905421, -0.0070636223, ... 
       0.0099298789,  0.0631108126,  0.0323281574, -0.1184997765, ... 
      -0.1552819422,  0.0706210002,  0.2575417225,  0.0832848226, ... 
      -0.2116737559, -0.1907370412,  0.0609805327,  0.1436884371, ... 
       0.0264315396, -0.0291922816,  0.0072528344, -0.0124054574, ... 
      -0.0578311278, -0.0187255316,  0.0442572887,  0.0320728432, ... 
      -0.0080021297, -0.0077760986,  0.0013598187, -0.0101904258, ... 
      -0.0122064094,  0.0037555734,  0.0106945538 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

cat > test_k_coef.ok << 'EOF'
k = [  0.99984301,  0.99993221,  0.99951439,  0.99902002, ... 
       0.99993823,  0.99897432,  0.99995311,  0.99998553, ... 
       0.99901520,  0.99976735,  0.98966449,  0.99765216, ... 
       0.99070633,  0.99162054,  0.99978172,  0.99979392, ... 
       0.99801382,  0.96858042,  0.91799643,  0.98572635, ... 
       0.80945641,  0.98758425,  0.92684310,  0.97094841, ... 
       0.99754041,  0.99612265,  0.99996900,  0.99995983, ... 
       0.99986687,  0.99995730, -0.01711675 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m "; fail; fi

cat > test_kc_coef.ok << 'EOF'
kc = [ -0.01771890, -0.01164338,  0.03116060,  0.04426055, ... 
       -0.01111479, -0.04528037, -0.00968435, -0.00537890, ... 
       -0.04436930,  0.02156948,  0.14340222,  0.06848487, ... 
       -0.13601824, -0.12918477,  0.02089274, -0.02030067, ... 
       -0.06299530,  0.24870055,  0.39658864, -0.16835549, ... 
       -0.58717997, -0.15709028,  0.37544889,  0.23928891, ... 
       -0.07009371, -0.08797533, -0.00787393, -0.00896300, ... 
       -0.01631691,  0.00924059,  0.99985350 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kc_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog #>test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

diff -Bb test_k_coef.ok directFIRnonsymmetric_kyp_bandpass_test_k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k_coef.m"; fail; fi

diff -Bb test_kc_coef.ok directFIRnonsymmetric_kyp_bandpass_test_kc_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_kc_coef.m"; fail; fi

#
# this much worked
#
pass

