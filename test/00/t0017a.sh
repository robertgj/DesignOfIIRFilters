#!/bin/sh

prog=iir_sqp_slb_test.m

depends="iir_sqp_slb_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
Aerror.m Terror.m armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m \
iirT.m iirP.m iir_sqp_octave.m invSVD.m local_max.m local_peak.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m"
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
tol =  0.0010000
maxiter =  2000
verbose = 0
U = 0
V = 0
Q =  6
M =  10
R =  1
fap =  0.15000
dBap =  1
Wap =  1
fas =  0.30000
dBas =  36
Was =  1
ftp =  0.25000
tp =  6
tpr =  0.025000
Wtp =  0.10000
ans =
   0.15000
   0.30000
ans =
   1
   0
   0
   1
ans =  0.25000

First MMSE pass
x2 =
   0.012261
   0.990843
   0.770025
   1.179490
  -0.153214
   2.079862
   2.192146
   2.056922
   3.688314
   1.287905
   0.464790
   0.704089
   0.567933
   0.275746
   1.636924
   1.123074
   0.098346
E =    1.4443e-04
sqp_iter =  285
func_iter =  579
feasible = 1

Second MMSE pass
S frequency constraints before:
al=[ ]
au=[ 1 232 601 ]
sl=[ ]
su=[ ]
tl=[ 1 237 413 501 ]
tu=[ 125 335 471 ]
pl=[ ]
pu=[ ]
Current constraints:
au = [ 1 232 601 ]
au = [ 0.000000 0.115500 0.300000 ] (fs=1)
Au = [ 0.029163 0.082549 -30.960810 ] (dB)
tl = [ 1 237 413 501 ]
tl = [ 0.000000 0.118000 0.206000 0.250000 ] (fs=1)
Tl = [ 5.980838 5.978526 5.979197 5.925624 ] (Samples)
tu = [ 125 335 471 ]
tu = [ 0.062000 0.167000 0.235000 ] (fs=1)
Tu = [ 6.019237 6.021688 6.030286 ] (Samples)
x3 =
   0.0095645
   0.9937282
   0.8523102
   1.1010551
   0.0277233
   2.1768542
   1.9592212
   2.6439878
   3.1146934
   1.4529074
   0.4551939
   0.6434035
   0.5322231
   0.2680076
   1.6782059
   1.1156395
   0.0077584
E =    2.1680e-04
sqp_iter =  79
func_iter =  161
feasible = 1
S frequency constraints after:
al=[ ]
au=[ 204 ]
sl=[ ]
su=[ ]
tl=[ ]
tu=[ 477 ]
pl=[ ]
pu=[ ]
Current constraints:
au = [ 204 ]
au = [ 0.101500 ] (fs=1)
Au = [ 0.026079 ] (dB)
tu = [ 477 ]
tu = [ 0.238000 ] (fs=1)
Tu = [ 6.013522 ] (Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

