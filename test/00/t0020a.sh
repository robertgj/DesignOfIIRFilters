#!/bin/sh

prog=iir_sqp_mmse_tarczynski_ex2_test.m

depends="iir_sqp_mmse_tarczynski_ex2_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_sqp_mmse.m Aerror.m Terror.m armijo_kim.m fixResultNaN.m iirA.m iirE.m \
iirT.m invSVD.m showZPplot.m sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m x2tf.m \
xConstraints.m qroots.m qzsolve.oct"

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
cat > test.x1.ok << 'EOF'
Ux1=3,Vx1=2,Mx1=20,Qx1=0,Rx1=2
x1 = [   0.0007284179, ...
        -1.4714295893,   0.3837672013,   0.3837672013, ...
        -0.2813064757,  -0.0198520460, ...
         0.5473333261,   0.6749732829,   1.4011268507,   1.4262036800, ... 
         1.4508467031,   1.4593352951,   1.4665517411,   1.5954735335, ... 
         1.6080735861,   1.6179179045, ...
         0.8977245732,   1.4766584241,   1.8431553308,   2.2454091799, ... 
         2.5512336262,   1.8596988558,   2.8478478354,   1.0849400446, ... 
         0.6694755118,   0.2132656643 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.x1.ok iir_sqp_mmse_tarczynski_ex2_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.x1.ok"; fail; fi


#
# this much worked
#
pass
