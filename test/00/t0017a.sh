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
Wa = [   0.1591549431,   0.1591549431,   0.0000000000,   0.0000000000, ... 
         0.1591549431,   0.1591549431 ]';
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
x3 = [   0.0139724732,   0.9832489183,  -0.0842298081,   1.0893379741, ... 
         0.8449709041,   2.0256100189,   1.9300571573,   2.1806664624, ... 
         3.7018130018,   2.5937536511,   0.4730503631,   0.6632177539, ... 
         0.5579724140,   0.3025679328,   1.6759741798,   1.1268939196, ... 
        -0.0587936486 ]';
E=0.000131046,sqp_iter=197,func_iter=405,feasible=1
S frequency constraints after:
al = [ ];
au = [ 1, 236 ]';
sl = [ ];
su = [ ];
tl = [ 1, 249, 421 ]';
tu = [ 133, 344, 479 ]';
pl = [ ];
pu = [ ];
Current constraints:
au = [ 1, 236 ]';
f(au)(fs=1) = [   0.0000000000,   0.1175000000 ]';
Au(dB) = [   0.0520597565,   0.0329785198 ]';
tl = [ 1, 249, 421 ]';
f(tl)(fs=1) = [   0.0000000000,   0.1240000000,   0.2100000000 ]';
Tl(samples) = [   5.9720285802,   5.9784358016,   5.9842324541 ]';
tu = [ 133, 344, 479 ]';
f(tu)(fs=1) = [   0.0660000000,   0.1715000000,   0.2390000000 ]';
Tu(samples) = [   6.0282301088,   6.0160754389,   6.0168266974 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

