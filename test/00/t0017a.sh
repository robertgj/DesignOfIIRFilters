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
sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m \
qroots.m qzsolve.oct"

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
   0.0051958
   0.9526736
   0.3080069
   2.0022911
   0.1633832
   2.3738998
   2.1075460
   2.1900683
   2.8007126
   1.7384841
   0.4311601
   0.6913891
   0.5823258
   0.4298688
   1.5971491
   1.0880329
   0.4191643

E =  0.00039390
sqp_iter =  161
func_iter =  326
feasible = 1

Second MMSE pass
S frequency constraints before:
al=[  ]
au=[ 203 601 ]
sl=[  ]
su=[  ]
tl=[ 217 407 501 ]
tu=[ 325 468 ]
pl=[  ]
pu=[  ]
Current constraints:
au = [ 203 601 ]
f(au) = [ 0.101000 0.300000 ] (fs=1)
Au = [ 0.108018 -26.702932 ] (dB)
tl = [ 217 407 501 ]
f(tl) = [ 0.108000 0.203000 0.250000 ] (fs=1)
Tl = [ 5.971466 5.974619 5.917669 ] (Samples)
tu = [ 325 468 ]
f(tu) = [ 0.162000 0.233500 ] (fs=1)
Tu = [ 6.034661 6.037904 ] (Samples)
x3 =
   0.0091685
   0.9768931
   0.7061743
   1.2846301
   0.7744838
   2.1282903
   1.9234882
   3.8114183
   3.1651417
   2.4445107
   0.4737405
   0.8003652
   0.5470186
   0.1511808
   1.8707828
   1.2938756
   0.4798635

E =  0.00023166
sqp_iter =  102
func_iter =  210
feasible = 1
S frequency constraints after:
al=[  ]
au=[  ]
sl=[  ]
su=[  ]
tl=[ 1 272 461 ]
tu=[ 144 382 501 ]
pl=[  ]
pu=[  ]
Current constraints:
tl = [ 1 272 461 ]
f(tl) = [ 0.000000 0.135500 0.230000 ] (fs=1)
Tl = [ 5.963250 5.971184 5.972383 ] (Samples)
tu = [ 144 382 501 ]
f(tu) = [ 0.071500 0.190500 0.250000 ] (fs=1)
Tu = [ 6.032262 6.030984 6.074694 ] (Samples)
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

