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
x2 = [   0.0117468872,   0.9761396980,   0.7662104704,   1.2292501586, ... 
        -0.1091103315,   2.0874270344,   2.1847786233,   2.0429977413, ... 
         3.6432098505,   1.3083816363,   0.4652983269,   0.7087733086, ... 
         0.5706872468,   0.3130828222,   1.6395207647,   1.1294802358, ... 
         0.2896947297 ]';
E=0.000147793,sqp_iter=258,func_iter=523,feasible=1

Second MMSE pass
S frequency constraints before:
al = [ ];
au = [ 1, 232, 601 ]';
sl = [ ];
su = [ ];
tl = [ 1, 239, 415, 501 ]';
tu = [ 125, 337, 472 ]';
pl = [ ];
pu = [ ];
Current constraints:
au = [ 1, 232, 601 ]';
f(au)(fs=1) = [   0.0000000000,   0.1155000000,   0.3000000000 ]';
Au(dB) = [   0.0259194925,   0.0800821054, -30.7636607418 ]';
tl = [ 1, 239, 415, 501 ]';
f(tl)(fs=1) = [   0.0000000000,   0.1190000000,   0.2070000000,   0.2500000000 ]';
Tl(samples) = [   5.9800288599,   5.9768954293,   5.9792982168,   5.9262331584 ]';
tu = [ 125, 337, 472 ]';
f(tu)(fs=1) = [   0.0620000000,   0.1680000000,   0.2355000000 ]';
Tu(samples) = [   6.0206720981,   6.0233897623,   6.0300379278 ]';
x3 = [   0.0098530292,   0.9947355215,   0.8461087043,   1.1335175135, ... 
         0.0248255323,   2.1776515626,   1.9311149826,   2.5717317214, ... 
         3.1518517782,   1.4774677949,   0.4511847647,   0.6432641874, ... 
         0.5312464631,   0.2626541781,   1.6807848483,   1.1158285435, ... 
        -0.0137083159 ]';
E=0.000244833,sqp_iter=82,func_iter=167,feasible=1
S frequency constraints after:
al = [ ];
au = [ 203, 671 ]';
sl = [ ];
su = [ ];
tl = [ ];
tu = [ ];
pl = [ ];
pu = [ ];
Current constraints:
au = [ 203, 671 ]';
f(au)(fs=1) = [   0.1010000000,   0.3350000000 ]';
Au(dB) = [   0.0296548265, -38.3510604457 ]';
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

