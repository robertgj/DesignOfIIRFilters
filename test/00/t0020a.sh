#!/bin/sh

prog=iir_sqp_mmse_tarczynski_ex2_test.m

depends="test/iir_sqp_mmse_tarczynski_ex2_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_sqp_mmse.m armijo_kim.m fixResultNaN.m iirA.m iirE.m \
iirT.m invSVD.m showZPplot.m sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m x2tf.m \
xConstraints.m qroots.oct"

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
cat > test.x1.ok << 'EOF'
Ux1=3,Vx1=2,Mx1=20,Qx1=0,Rx1=2
x1 = [   0.0007253206, ...
        -1.4771474582,   0.3834394477,   0.3834394477, ...
        -0.2799988055,  -0.0201665080, ...
         0.5470100697,   0.6743450215,   1.4041700403,   1.4252804620, ... 
         1.4505136066,   1.4546575267,   1.4696758854,   1.5944394285, ... 
         1.6076004109,   1.6194780464, ...
         0.8971817372,   1.4761645128,   1.8434521712,   2.2463445219, ... 
         2.5534921522,   1.8597226189,   2.8504239788,   1.0851933041, ... 
         0.6685433030,   0.2126203265 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.x1.ok iir_sqp_mmse_tarczynski_ex2_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.x1.ok"; fail; fi


#
# this much worked
#
pass
