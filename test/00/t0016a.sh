#!/bin/sh

prog=iir_slb_update_constraints_test.m 

depends="iir_slb_update_constraints_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb_update_constraints.m xConstraints.m iir_slb_show_constraints.m \
iirA.m iirT.m iirP.m local_max.m fixResultNaN.m"
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
test parameters:fap=0.15,dBap=0.1,fas=0.3,dBas=45,tp=6,rtp=0.025,tol=1e-05
al = [    1,  302 ]';
au = [  191 ];
sl = [   20,  153,  400 ]';
su = [    1,   54 ]';
tl = [    1,  246,  443 ]';
tu = [  126,  355 ]';
pl = [  187,  402 ]';
pu = [   64,  302 ]';
Current constraints:
al = [ 1, 302 ]';
f(al)(fs=1) = [   0.0000000000,   0.1505000000 ]';
Al(dB) = [  -0.1284290814,  -0.7483624729 ]';
au = [ 191 ];
f(au)(fs=1) = [   0.0950000000 ];
Au(dB) = [   0.0563079273 ];
sl = [ 20, 153, 400 ]';
f(sl)(fs=1) = [   0.3100000000,   0.3765000000,   0.5000000000 ]';
Sl(dB) = [ -49.7222621025, -58.7937104691, -74.5087965829 ]';
su = [ 1, 54 ]';
f(su)(fs=1) = [   0.3005000000,   0.3270000000 ]';
Su(dB) = [ -40.4904310459, -44.9837476968 ]';
tl = [ 1, 246, 443 ]';
f(tl)(fs=1) = [   0.0000000000,   0.1225000000,   0.2210000000 ]';
Tl(samples) = [   5.9874847899,   5.9872997763,   5.9873531826 ]';
tu = [ 126, 355 ]';
f(tu)(fs=1) = [   0.0625000000,   0.1770000000 ]';
Tu(samples) = [   6.0125184767,   6.0128133226 ]';
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

