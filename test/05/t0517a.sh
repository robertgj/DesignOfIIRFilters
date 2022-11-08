#!/bin/sh

prog=directFIRnonsymmetric_kyp_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_bandpass_test.m test_common.m \
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
h = [ -0.0104461275, -0.0023684654,  0.0033115044, -0.0068637915, ... 
       0.0099002908,  0.0630129663,  0.0323085685, -0.1185767992, ... 
      -0.1553736764,  0.0708348596,  0.2579693763,  0.0833862427, ... 
      -0.2119975286, -0.1910149048,  0.0609336136,  0.1436574461, ... 
       0.0264605977, -0.0289247081,  0.0074784699, -0.0125967015, ... 
      -0.0582337854, -0.0189173310,  0.0442601423,  0.0320662643, ... 
      -0.0079850720, -0.0077000870,  0.0013204994, -0.0104113355, ... 
      -0.0124087082,  0.0036952872,  0.0107223262 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

cat > test_k_coef.ok << 'EOF'
k = [  0.99984087,  0.99993210,  0.99949529,  0.99898091, ... 
       0.99993537,  0.99890707,  0.99994710,  0.99999118, ... 
       0.99906301,  0.99976703,  0.98960098,  0.99761085, ... 
       0.99047429,  0.99127516,  0.99976777,  0.99985447, ... 
       0.99808508,  0.96878197,  0.91776103,  0.98561724, ... 
       0.80748769,  0.98748735,  0.92608564,  0.97084788, ... 
       0.99752958,  0.99619696,  0.99997179,  0.99995232, ... 
       0.99985556,  0.99995671, -0.01737960 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k_coef.m "; fail; fi

cat > test_kc_coef.ok << 'EOF'
kc = [ -0.01783898, -0.01165297,  0.03176746,  0.04513469, ... 
       -0.01136886, -0.04674049, -0.01028611, -0.00420008, ... 
       -0.04327945,  0.02158421,  0.14383983,  0.06908399, ... 
       -0.13769780, -0.13180876,  0.02154989, -0.01705987, ... 
       -0.06185603,  0.24791428,  0.39713310, -0.16899305, ... 
       -0.58988443, -0.15769823,  0.37731337,  0.23969645, ... 
       -0.07024766, -0.08712989, -0.00751152, -0.00976557, ... 
       -0.01699592,  0.00930454,  0.99984896 ]';
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

