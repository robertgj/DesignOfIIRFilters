#!/bin/sh

prog=iir_sqp_mmse_test.m

depends="iir_sqp_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_sqp_mmse.m iir_sqp_octave.m \
Aerror.m Terror.m armijo_kim.m cl2bp.m fixResultNaN.m \
iirA.m iirE.m iirT.m invSVD.m local_max.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m sqp_bfgs.m \
tf2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m xInitHd.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m"
tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
x1= = [   0.0082057576,   1.6578849295,   1.0085597137,   0.9853126478, ... 
         -0.9700403091,   1.0326268574,   1.0835387184,   1.2938271179, ... 
          1.0140173219,   0.0000000000,   1.7934633832,   1.4437534850, ... 
          2.7163767004,   1.8961781270,   4.0258680988,   2.6747321034, ... 
          2.5726251780,   0.9687500000,   0.6446878334,   0.9687500000, ... 
          0.6498912766,   1.1292768730,   1.5571814762,   3.6390867318, ... 
          2.2355572770 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x1_coef.ok iir_sqp_mmse_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1_coef.ok"; fail; fi


#
# this much worked
#
pass

