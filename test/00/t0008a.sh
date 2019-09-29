#!/bin/sh

prog=iir_sqp_mmse_test.m

depends="iir_sqp_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_sqp_mmse.m iir_sqp_octave.m iirP_hessP_DiagonalApprox.m \
Aerror.m Terror.m Perror.m armijo_kim.m cl2bp.m fixResultNaN.m \
iirA.m iirE.m iirT.m iirP.m invSVD.m local_max.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m sqp_bfgs.m \
tf2x.m zp2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m xInitHd.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
qroots.m qzsolve.oct"

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
cat > test_x1_coef.ok << 'EOF'
x1= = [   0.0158917950,   1.3805654699,   1.0120344531,   0.9913602494, ... 
         -0.9703044734,   1.0112074081,   1.0318292898,   1.0403776169, ... 
          1.0144641862,   0.0000000000,   1.7744990860,   1.4391381526, ... 
          2.7150394227,   1.8682795152,   4.0945148935,   3.6328675689, ... 
          2.5315538984,   0.9687500000,   0.6856217467,   0.9687500000, ... 
          0.6839309146,   1.1566721716,   1.5452839818,   3.6571004810, ... 
          2.2347436707 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x1_coef.ok iir_sqp_mmse_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1_coef.ok"; fail; fi


#
# this much worked
#
pass

