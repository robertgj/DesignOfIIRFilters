#!/bin/sh

prog=iir_sqp_slb_hilbert_test.m

depends="iir_sqp_slb_hilbert_test.m \
../tarczynski_hilbert_test_D0_coef.m \
../tarczynski_hilbert_test_N0_coef.m \
test_common.m print_polynomial.m print_pole_zero.m \
armijo_kim.m fixResultNaN.m \
iirA.m iirE.m iirP.m iirT.m invSVD.m \
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
cat > test.ok << 'EOF'
Ud1=7,Vd1=2,Md1=4,Qd1=4,Rd1=2
d1 = [  -0.0115704965, ...
        -2.4419185992,  -0.8247813224,  -0.2322694063,  -0.2150899856, ... 
         0.3779355026,   0.4010581637,   1.2103016946, ...
        -0.0828109803,   0.6789170631, ...
         2.2591962697,   2.3930506461, ...
         1.0143945619,   2.0565002092, ...
         0.1688312043,   0.1903233109, ...
         0.2181731174,   1.9604135498 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_hilbert_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

