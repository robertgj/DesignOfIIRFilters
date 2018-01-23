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
ctol =  0.0010000
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
   0.0070065
   0.9218481
   0.6060830
   1.8661433
  -0.0152563
   2.1934712
   2.0722992
   2.1054381
   3.2896604
   1.5643768
   0.4686098
   0.7150188
   0.5781565
   0.3904605
   1.6351238
   1.1377136
   0.4015617
E =    2.6155e-04
sqp_iter =  191
func_iter =  385
feasible = 1

Second MMSE pass
S frequency constraints before:
al=[ ]
au=[ 224 601 ]
sl=[ ]
su=[ ]
tl=[ 1 237 418 501 ]
tu=[ 122 338 475 ]
pl=[ ]
pu=[ ]
Current constraints:
au = [ 224 601 ]
au = [ 0.111500 0.300000 ] (fs=1)
Au = [ 0.066354 -28.227954 ] (dB)
tl = [ 1 237 418 501 ]
tl = [ 0.000000 0.118000 0.208500 0.250000 ] (fs=1)
Tl = [ 5.982961 5.976243 5.975326 5.939707 ] (Samples)
tu = [ 122 338 475 ]
tu = [ 0.060500 0.168500 0.237000 ] (fs=1)
Tu = [ 6.019701 6.030296 6.032665 ] (Samples)
x3 =
   0.012616
   0.993811
   1.117414
   0.922665
   0.293884
   2.058634
   1.956782
   2.468857
   3.377285
   0.718612
   0.473067
   0.624414
   0.545646
   0.334645
   1.650738
   1.061537
  -0.036451
E =    1.4083e-04
sqp_iter =  226
func_iter =  455
feasible = 1
S frequency constraints after:
al=[ ]
au=[ 1 ]
sl=[ ]
su=[ ]
tl=[ 410 ]
tu=[ 322 476 ]
pl=[ ]
pu=[ ]
Current constraints:
au = [ 1 ]
au = [ 0.000000 ] (fs=1)
Au = [ 0.067302 ] (dB)
tl = [ 410 ]
tl = [ 0.204500 ] (fs=1)
Tl = [ 5.980938 ] (Samples)
tu = [ 322 476 ]
tu = [ 0.160500 0.237500 ] (fs=1)
Tu = [ 6.015425 6.014548 ] (Samples)
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

