#!/bin/sh

prog=iir_sqp_slb_test.m

depends="test/iir_sqp_slb_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m \
iirT.m iirP.m invSVD.m local_max.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m \
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
maxiter=2000,ftol=0.001,ctol=0.001,verbose=0
f = [   0.1495000000,   0.1500000000,   0.1505000000,   0.2995000000, ... 
        0.3000000000,   0.3005000000 ]';
Wa = [   1.0000000000,   1.0000000000,   0.0000000000,   0.0000000000, ... 
         1.0000000000,   1.0000000000 ]';
ft(ntp) = [   0.2500000000 ];
Test parameters:fap=0.15,dBap=1,Wap=1,fas=0.3,dBas=40,Was=1,tp=6,rtp=0.025,Wtp=0.1

First MMSE pass
x2 = [   0.0051958417,   0.9528216738,   0.3081089847,   2.0028631260, ... 
         0.1632834242,   2.3736711048,   2.1076829139,   2.1898922740, ... 
         2.8003192609,   1.7392676361,   0.4312084847,   0.6912548386, ... 
         0.5821899433,   0.4297486435,   1.5972552296,   1.0882019341, ... 
         0.4192806962 ]';
E=0.000393878,sqp_iter=161,func_iter=326,feasible=1

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
Au(dB) = [   0.1079996749, -26.6937959755 ]';
tl = [ 217, 407, 501 ]';
f(tl)(fs=1) = [   0.1080000000,   0.2030000000,   0.2500000000 ]';
Tl(samples) = [   5.9715959453,   5.9747670459,   5.9176614193 ]';
tu = [ 325, 468 ]';
f(tu)(fs=1) = [   0.1620000000,   0.2335000000 ]';
Tu(samples) = [   6.0345451168,   6.0377405716 ]';
x3 = [   0.0146480016,   1.0078178876,  -0.0966679736,   0.9633128983, ... 
         0.8057185589,   2.0108945881,   1.9337694660,   2.0730974060, ... 
         2.5097722420,   3.0211405597,   0.4732334965,   0.6549923403, ... 
         0.5604695912,   0.3082828322,   1.6503456216,   1.1161770538, ... 
        -0.0222415014 ]';
E=0.000124987,sqp_iter=213,func_iter=436,feasible=1
S frequency constraints after:
al = [ ];
au = [ 1, 238 ]';
sl = [ ];
su = [ ];
tl = [ 1, 248, 419 ]';
tu = [ 133, 342, 478 ]';
pl = [ ];
pu = [ ];
Current constraints:
au = [ 1, 238 ]';
f(au)(fs=1) = [   0.0000000000,   0.1185000000 ]';
Au(dB) = [   0.0591439481,   0.0408842878 ]';
tl = [ 1, 248, 419 ]';
f(tl)(fs=1) = [   0.0000000000,   0.1235000000,   0.2090000000 ]';
Tl(samples) = [   5.9727450890,   5.9785971295,   5.9855488401 ]';
tu = [ 133, 342, 478 ]';
f(tu)(fs=1) = [   0.0660000000,   0.1705000000,   0.2385000000 ]';
Tu(samples) = [   6.0297346805,   6.0154892407,   6.0152313335 ]';
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

