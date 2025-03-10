#!/bin/sh

prog=iir_sqp_slb_hilbert_test.m

depends="test/iir_sqp_slb_hilbert_test.m \
../tarczynski_hilbert_test_D0_coef.m \
../tarczynski_hilbert_test_N0_coef.m \
test_common.m print_polynomial.m print_pole_zero.m \
armijo_kim.m fixResultNaN.m iirA.m iirE.m iirP.m iirT.m invSVD.m \
local_max.m iir_sqp_mmse.m iir_slb.m iir_slb_exchange_constraints.m \
iir_slb_show_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_update_constraints.m showZPplot.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m xConstraints.m tf2x.m zp2x.m x2tf.m \
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
cat > test.ok << 'EOF'
Ud1=7,Vd1=4,Md1=4,Qd1=2,Rd1=2
d1 = [   0.0097214827, ...
        -2.5499210935,  -0.8187128758,  -0.6533887915,  -0.1699507204, ... 
         0.5446741523,   0.6040251951,   1.2207969563, ...
         0.0318104932,   0.0778485845,   0.4468547469,   0.6660207676, ...
         2.2930747306,   2.5067221381, ...
         1.0288556457,   2.0718916077, ...
         0.1144217003, ...
         1.9808036063 ]';
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

