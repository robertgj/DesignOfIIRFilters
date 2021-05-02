#!/bin/sh

prog=iir_slb_exchange_constraints_test.m

depends="iir_slb_exchange_constraints_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb_exchange_constraints.m iir_slb_update_constraints.m \
iir_slb_show_constraints.m iirA.m iirP.m iirT.m local_max.m \
fixResultNaN.m"
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
maxiter=2000,tol=1e-05,verbose=0
Test parameters:fap=0.15,dBap=0.1,Wap=1,fas=0.3,dBas=50,Was=10,tp=6,rtp=0.01,Wtp=0.1
vR before exchange constraints:
Current constraints:
al = [ 302 ];
f(al)(fs=1) = [   0.1505000000 ];
Al(dB) = [  -0.2418428093 ];
au = [ 1, 158, 280 ]';
f(au)(fs=1) = [   0.0000000000,   0.0785000000,   0.1395000000 ]';
Au(dB) = [   0.0067176332,   0.0334668724,   0.0914506977 ]';
sl = [ 61, 259 ]';
f(sl)(fs=1) = [   0.3305000000,   0.4295000000 ]';
Sl(dB) = [ -56.1182960989, -61.2325870864 ]';
su = [ 1, 145, 400 ]';
f(su)(fs=1) = [   0.3005000000,   0.3725000000,   0.5000000000 ]';
Su(dB) = [ -36.6098765468, -43.0609714125, -41.7197215159 ]';
tu = [ 311 ];
f(tu)(fs=1) = [   0.1550000000 ];
Tu(samples) = [  16.7791849882 ];
pl = [ 501 ];
f(pl)(fs=1) = [   0.2500000000 ];
Pl(rad.) = [  -5.8476818631 ];
vS before exchange constraints:
Current constraints:
al = [ 1, 302 ]';
f(al)(fs=1) = [   0.0000000000,   0.1505000000 ]';
Al(dB) = [  -0.1847495583,  -0.8046829498 ]';
sl = [ 153, 400 ]';
f(sl)(fs=1) = [   0.3765000000,   0.5000000000 ]';
Sl(dB) = [ -58.8500309461, -74.5651170598 ]';
su = [ 1, 54 ]';
f(su)(fs=1) = [   0.3005000000,   0.3270000000 ]';
Su(dB) = [ -40.5467515228, -45.0400681738 ]';
tl = [ 1, 246, 443 ]';
f(tl)(fs=1) = [   0.0000000000,   0.1225000000,   0.2210000000 ]';
Tl(samples) = [   5.9874847899,   5.9872997763,   5.9873531826 ]';
tu = [ 126, 355, 498 ]';
f(tu)(fs=1) = [   0.0625000000,   0.1770000000,   0.2485000000 ]';
Tu(samples) = [   6.0125184767,   6.0128133226,   6.0089887673 ]';
pl = [ 187, 402 ]';
f(pl)(fs=1) = [   0.0930000000,   0.2005000000 ]';
Pl(rad.) = [  -1.1164760540,  -2.4063552118 ]';
pu = [ 64, 302 ]';
f(pu)(fs=1) = [   0.0315000000,   0.1505000000 ]';
Pu(rad.) = [  -0.3774961205,  -1.8055424350 ]';
Exchanged constraint from vR.al(302) to vS
vR after exchange constraints:
Current constraints:
au = [ 1, 158, 280 ]';
f(au)(fs=1) = [   0.0000000000,   0.0785000000,   0.1395000000 ]';
Au(dB) = [  -0.1847495583,  -0.0261678432,  -0.4573429733 ]';
sl = [ 61, 259 ]';
f(sl)(fs=1) = [   0.3305000000,   0.4295000000 ]';
Sl(dB) = [ -45.2071709789, -57.1058267029 ]';
su = [ 1, 145, 400 ]';
f(su)(fs=1) = [   0.3005000000,   0.3725000000,   0.5000000000 ]';
Su(dB) = [ -40.5467515228, -58.5932613910, -74.5651170598 ]';
tu = [ 311 ];
f(tu)(fs=1) = [   0.1550000000 ];
Tu(samples) = [   6.0031776403 ];
pl = [ 501 ];
f(pl)(fs=1) = [   0.2500000000 ];
Pl(rad.) = [  -2.9998894438 ];
vS after exchange constraints:
Current constraints:
al = [ 1, 302 ]';
f(al)(fs=1) = [   0.0000000000,   0.1505000000 ]';
Al(dB) = [  -0.1847495583,  -0.8046829498 ]';
sl = [ 153, 400 ]';
f(sl)(fs=1) = [   0.3765000000,   0.5000000000 ]';
Sl(dB) = [ -58.8500309461, -74.5651170598 ]';
su = [ 1, 54 ]';
f(su)(fs=1) = [   0.3005000000,   0.3270000000 ]';
Su(dB) = [ -40.5467515228, -45.0400681738 ]';
tl = [ 1, 246, 443 ]';
f(tl)(fs=1) = [   0.0000000000,   0.1225000000,   0.2210000000 ]';
Tl(samples) = [   5.9874847899,   5.9872997763,   5.9873531826 ]';
tu = [ 126, 355, 498 ]';
f(tu)(fs=1) = [   0.0625000000,   0.1770000000,   0.2485000000 ]';
Tu(samples) = [   6.0125184767,   6.0128133226,   6.0089887673 ]';
pl = [ 187, 402 ]';
f(pl)(fs=1) = [   0.0930000000,   0.2005000000 ]';
Pl(rad.) = [  -1.1164760540,  -2.4063552118 ]';
pu = [ 64, 302 ]';
f(pu)(fs=1) = [   0.0315000000,   0.1505000000 ]';
Pu(rad.) = [  -0.3774961205,  -1.8055424350 ]';
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

