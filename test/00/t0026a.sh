#!/bin/sh

prog=iir_sqp_slb_hilbert_test.m

depends="iir_sqp_slb_hilbert_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
Aerror.m Terror.m Perror.m armijo_kim.m fixResultNaN.m \
iirA.m iirE.m iirP.m iirP_hessP_DiagonalApprox.m iirT.m invSVD.m \
local_max.m iir_sqp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
iir_slb_update_constraints.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m updateWchol.m updateWbfgs.m \
xConstraints.m tf2x.m zp2x.m x2tf.m qroots.m qzsolve.oct"

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
cat > test.ok << 'EOF'
Ud1=7,Vd1=2,Md1=4,Qd1=4,Rd1=2
d1 = [  -0.0108024626, ...
        -2.4849821048,  -0.8202693105,  -0.2369673486,  -0.2033599242, ... 
         0.3783234200,   0.3890942840,   1.2167902430, ...
        -0.0547064839,   0.6716812713, ...
         2.2847856526,   2.4211131479, ...
         1.0125957306,   2.0609605170, ...
         0.1570162810,   0.1832556416, ...
         0.1949795444,   2.0043647143 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_hilbert_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

