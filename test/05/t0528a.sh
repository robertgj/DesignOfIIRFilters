#!/bin/sh

prog=directFIRnonsymmetric_socp_mmse_test.m

depends="directFIRnonsymmetric_socp_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
directFIRnonsymmetricAsq.m \
directFIRnonsymmetricEsq.m \
directFIRnonsymmetricP.m \
directFIRnonsymmetricT.m \
directFIRnonsymmetric_slb.m \
directFIRnonsymmetric_slb_constraints_are_empty.m \
directFIRnonsymmetric_slb_exchange_constraints.m \
directFIRnonsymmetric_slb_set_empty_constraints.m \
directFIRnonsymmetric_slb_show_constraints.m \
directFIRnonsymmetric_slb_update_constraints.m \
directFIRnonsymmetric_socp_mmse.m"

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
cat > test_h_coef.m << 'EOF'
h = [   0.0125387278,  -0.0436824775,  -0.0091592145,   0.0085590246, ... 
       -0.0421382931,  -0.1084524875,  -0.0839644946,   0.0598418608, ... 
        0.2044231560,   0.1891715931,  -0.0030926699,  -0.2024604056, ... 
       -0.2240911873,  -0.0660475523,   0.1002947185,   0.1302609100, ... 
        0.0508131011,  -0.0115200912,  -0.0006845229,   0.0246813075, ... 
        0.0033058386,  -0.0396578062,  -0.0447304503,  -0.0125116138, ... 
        0.0060971186,  -0.0056463498,  -0.0121882554,   0.0055163046, ... 
        0.0188358152,   0.0077315053,  -0.0025235858 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.m directFIRnonsymmetric_socp_mmse_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb" test_h_coef.m; fail; fi

#
# this much worked
#
pass
