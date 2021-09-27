#!/bin/sh

prog=iir_sqp_slb_test.m

depends="iir_sqp_slb_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m \
iirT.m iirP.m invSVD.m local_max.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m \
qroots.m qzsolve.oct"

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
tol=0.001,ctol=0.001,maxiter=2000,verbose=0
f = [   0.1495000000,   0.1500000000,   0.1505000000,   0.2995000000, ... 
        0.3000000000,   0.3005000000 ]';
Wa = [   1.0000000000,   1.0000000000,   0.0000000000,   0.0000000000, ... 
         1.0000000000,   1.0000000000 ]';
ft(ntp) = [   0.2500000000 ];
Test parameters:fap=0.15,dBap=1,Wap=1,fas=0.3,dBas=40,Was=1,tp=6,rtp=0.025,Wtp=0.1

First MMSE pass
x2 = [   0.0051958134,   0.9526735834,   0.3080068910,   2.0022911477, ... 
         0.1633831789,   2.3738997676,   2.1075459640,   2.1900682776, ... 
         2.8007125650,   1.7384841277,   0.4311600635,   0.6913891384, ... 
         0.5823257602,   0.4298688380,   1.5971490869,   1.0880329459, ... 
         0.4191643481 ]';
E=0.000393899,sqp_iter=161,func_iter=326,feasible=1

Second MMSE pass
S frequency constraints before:
al = [ ];
au = [ 203, 601 ]';
sl = [ ];
su = [ ];
tl = [ 217, 407, 501 ]';
tu = [ 325, 468 ]';
pl = [ ];
pu = [ ];
Current constraints:
au = [ 203, 601 ]';
f(au)(fs=1) = [   0.1010000000,   0.3000000000 ]';
Au(dB) = [   0.1080182220, -26.7029317348 ]';
tl = [ 217, 407, 501 ]';
f(tl)(fs=1) = [   0.1080000000,   0.2030000000,   0.2500000000 ]';
Tl(samples) = [   5.9714664713,   5.9746194388,   5.9176692287 ]';
tu = [ 325, 468 ]';
f(tu)(fs=1) = [   0.1620000000,   0.2335000000 ]';
Tu(samples) = [   6.0346612482,   6.0379036454 ]';
x3 = [   0.0153733670,   0.9983922087,  -0.2187204951,   0.9764538563, ... 
         0.9392141314,   1.9998201484,   1.9383262944,   2.0605822359, ... 
         3.9281363924,   2.8668642235,   0.4735381781,   0.6509056865, ... 
         0.5617187276,   0.2991358726,   1.6568919146,   1.1122923562, ... 
        -0.0380967577 ]';
E=0.000116739,sqp_iter=233,func_iter=479,feasible=1
S frequency constraints after:
al = [ ];
au = [ 1, 240 ]';
sl = [ ];
su = [ ];
tl = [ 1, 249, 419 ]';
tu = [ 134, 342, 478 ]';
pl = [ ];
pu = [ ];
Current constraints:
au = [ 1, 240 ]';
f(au)(fs=1) = [   0.0000000000,   0.1195000000 ]';
Au(dB) = [   0.0610914163,   0.0458089102 ]';
tl = [ 1, 249, 419 ]';
f(tl)(fs=1) = [   0.0000000000,   0.1240000000,   0.2090000000 ]';
Tl(samples) = [   5.9690806055,   5.9779926514,   5.9855136131 ]';
tu = [ 134, 342, 478 ]';
f(tu)(fs=1) = [   0.0665000000,   0.1705000000,   0.2385000000 ]';
Tu(samples) = [   6.0308504838,   6.0156484027,   6.0155073280 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

