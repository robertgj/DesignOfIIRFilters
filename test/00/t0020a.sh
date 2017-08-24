#!/bin/sh

prog=iir_sqp_mmse_tarczynski_ex2_test.m

depends="iir_sqp_mmse_tarczynski_ex2_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_sqp_mmse.m Aerror.m Terror.m armijo_kim.m fixResultNaN.m iirA.m iirE.m \
iirT.m invSVD.m showZPplot.m sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m x2tf.m \
xConstraints.m"
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
x1 = [   0.0007292341, ...
        -1.4706927625,   0.3838338133,   0.3838338133, ...
        -0.2815820073,  -0.0198153668, ...
         1.4662082100,   1.4510324042,   1.6186770071,   1.6079007944, ... 
         1.5949916830,   1.4261984039,   1.4586639559,   1.4013749710, ... 
         0.6751615312,   0.5474124492, ...
         2.8474662327,   2.5510830490,   0.2129217568,   0.6689968318, ... 
         1.0848197242,   2.2454339928,   1.8604829111,   1.8423793572, ... 
         1.4767995380,   0.8977976997 ]';
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
