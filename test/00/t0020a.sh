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
x1 = [   0.0007402580, ...
        -1.4828851415,   0.3838193509,   0.3838193510, ...
        -0.2847251560,  -0.0188954226, ...
         0.5472460777,   0.6772946132,   1.3976136170,   1.4225447085, ... 
         1.4466551512,   1.4591287873,   1.4719814067,   1.5938155430, ... 
         1.6013771461,   1.6138480001, ...
         0.8972756089,   1.4770396949,   1.8351853805,   2.2457387807, ... 
         2.5559841909,   1.8689391245,   2.8540823426,   1.0878341366, ... 
         0.6705754680,   0.2128541969 ]';
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
