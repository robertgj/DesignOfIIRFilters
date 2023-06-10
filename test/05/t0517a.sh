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
h = [ -0.0104426599, -0.0023700297,  0.0033046546, -0.0068698457, ... 
       0.0099013332,  0.0630160748,  0.0323092889, -0.1185743724, ... 
      -0.1553709783,  0.0708281777,  0.2579564372,  0.0833835929, ... 
      -0.2119871428, -0.1910059833,  0.0609354176,  0.1436585796, ... 
       0.0264597672, -0.0289325724,  0.0074722915, -0.0125900594, ... 
      -0.0582208399, -0.0189108722,  0.0442605799,  0.0320668015, ... 
      -0.0079852641, -0.0077018450,  0.0013223367, -0.0104041511, ... 
      -0.0124022460,  0.0036973932,  0.0107216954 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

cat > test_k_coef.ok << 'EOF'
k = [  0.99984094,  0.99993210,  0.99949592,  0.99898222, ... 
       0.99993546,  0.99890929,  0.99994730,  0.99999102, ... 
       0.99906142,  0.99976707,  0.98960333,  0.99761228, ... 
       0.99048226,  0.99128708,  0.99976826,  0.99985255, ... 
       0.99808258,  0.96877481,  0.91776840,  0.98562096, ... 
       0.80755549,  0.98749070,  0.92611279,  0.97085202, ... 
       0.99753003,  0.99619469,  0.99997170,  0.99995256, ... 
       0.99985593,  0.99995673, -0.01737131 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m "; fail; fi

cat > test_kc_coef.ok << 'EOF'
kc = [ -0.01783534, -0.01165280,  0.03174760,  0.04510568, ... 
       -0.01136135, -0.04669294, -0.01026595, -0.00423867, ... 
       -0.04331597,  0.02158244,  0.14382368,  0.06906328, ... 
       -0.13764044, -0.13171909,  0.02152720, -0.01717209, ... 
       -0.06189643,  0.24794225,  0.39711605, -0.16897134, ... 
       -0.58979160, -0.15767723,  0.37724674,  0.23967969, ... 
       -0.07024122, -0.08715586, -0.00752327, -0.00974003, ... 
       -0.01697424,  0.00930240,  0.99984911 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_kc_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
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

