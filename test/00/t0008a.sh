#!/bin/sh

prog=iir_sqp_mmse_test.m

depends="test/iir_sqp_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_sqp_mmse.m iir_slb_update_constraints.m iir_slb_show_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m \
iirA.m iirE.m iirT.m iirP.m invSVD.m local_max.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m sqp_bfgs.m \
tf2x.m zp2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m xInitHd.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
qroots.oct"

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
x1 = [   0.0051943446,   0.7830647524,   1.0307854055,   1.0080505208, ... 
        -1.2670077324,   2.2711585402,   1.0077764402,   1.0393893005, ... 
         1.0355113069,   0.0000000000,   2.1396491811,   1.6539198506, ... 
         3.1387583692,   1.4763313817,   4.4865686251,   2.5408829580, ... 
         3.6472105104,   0.9671487591,   0.6474180510,   0.9524747861, ... 
         0.6184235108,   1.0946450129,   1.5169495694,   2.7338233154, ... 
         2.1709110586 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x1_coef.ok iir_sqp_mmse_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1_coef.ok"; fail; fi


#
# this much worked
#
pass

