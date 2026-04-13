#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_bandpass_test.m test_common.m delayz.m \
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
h = [ -0.0104144287, -0.0023682517,  0.0032719938, -0.0069032337, ... 
       0.0099100800,  0.0630395877,  0.0323190631, -0.1185518041, ... 
      -0.1553404800,  0.0708049984,  0.2578895633,  0.0833677232, ... 
      -0.2119296407, -0.1909549427,  0.0609505247,  0.1436757093, ... 
       0.0264655754, -0.0289756649,  0.0074300812, -0.0125615024, ... 
      -0.0581535367, -0.0188770198,  0.0442641978,  0.0320710858, ... 
      -0.0079896821, -0.0077190345,  0.0013262239, -0.0103678018, ... 
      -0.0123694247,  0.0037079774,  0.0107179911 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

cat > test_k_coef.ok << 'EOF'
k = [  0.99984130,  0.99993213,  0.99949925,  0.99898912, ... 
       0.99993604,  0.99892182,  0.99994838,  0.99999003, ... 
       0.99905269,  0.99976686,  0.98961337,  0.99761968, ... 
       0.99052503,  0.99134937,  0.99977155,  0.99984184, ... 
       0.99807139,  0.96873149,  0.91782545,  0.98563404, ... 
       0.80792761,  0.98751343,  0.92625404,  0.97087761, ... 
       0.99752954,  0.99617962,  0.99997130,  0.99995415, ... 
       0.99985791,  0.99995704, -0.01731047 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m "; fail; fi

cat > test_kc_coef.ok << 'EOF'
kc = [ -0.01781488, -0.01165046,  0.03164265,  0.04495254, ... 
       -0.01131018, -0.04642412, -0.01016102, -0.00446456, ... 
       -0.04351700,  0.02159221,  0.14375460,  0.06895627, ... 
       -0.13733232, -0.13124945,  0.02137392, -0.01778479, ... 
       -0.06207661,  0.24811145,  0.39698418, -0.16889503, ... 
       -0.58928175, -0.15753487,  0.37689980,  0.23957602, ... 
       -0.07024831, -0.08732793, -0.00757643, -0.00957614, ... 
       -0.01685729,  0.00926908,  0.99985016 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kc_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="directFIRnonsymmetric_kyp_bandpass_test"

diff -Bb test_h_coef.ok $nstr"_h_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

diff -Bb test_k_coef.ok $nstr"_k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k_coef.m"; fail; fi

diff -Bb test_kc_coef.ok $nstr"_kc_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_kc_coef.m"; fail; fi

#
# this much worked
#
pass

