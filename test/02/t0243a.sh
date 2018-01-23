#!/bin/sh

prog=iir_sqp_slb_pink_test.m

depends="iir_sqp_slb_pink_test.m test_common.m print_polynomial.m \
print_pole_zero.m Aerror.m Perror.m Terror.m armijo_kim.m fixResultNaN.m \
iirA.m iirE.m iirP.m iirP_hessP_DiagonalApprox.m iirT.m invSVD.m \
local_max.m iir_sqp_mmse.m iir_slb.m iir_slb_exchange_constraints.m \
iir_slb_show_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_update_constraints.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m xConstraints.m tf2x.m x2tf.m"
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
Ud1=3,Vd1=1,Md1=8,Qd1=10,Rd1=1
d1 = [   0.0008367464, ...
        -2.7692217585,   0.7592558968,   0.8792894753, ...
         0.9611520802, ...
         3.2110775827,   3.1183966691,   0.5006873588,   0.9710176057, ...
         1.8874484822,   0.6946552665,   6.2832215720,  -0.0298047817, ...
         0.3346391445,   0.9687500000,   0.3483258224,   0.5109820327, ... 
         0.7590213362, ...
         2.4095949593,   0.0249009393,   1.2407259967,   0.3499517155, ... 
         0.0000118828 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_pink_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

