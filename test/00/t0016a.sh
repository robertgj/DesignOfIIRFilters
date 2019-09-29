#!/bin/sh

prog=iir_slb_update_constraints_test.m 

depends="iir_slb_update_constraints_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb_update_constraints.m xConstraints.m iir_slb_show_constraints.m \
iirA.m iirT.m iirP.m local_max.m local_peak.m fixResultNaN.m"
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
verbose = 1
tol =  0.000010000
U = 0
V = 0
Q =  6
M =  10
R =  1
fap =  0.15000
dBap =  0.10000
Wap =  1
fas =  0.30000
dBas =  60
Was =  1
ftp =  0.25000
tp =  6
tpr =  0.025000
Wtp =  1
fpp =  0.25000
pd = 0
ppr =  0.0020000
Wpp =  0.0010000
al=[ 1 302 ]
au=[ 191 ]
sl=[  ]
su=[ 1 54 222 ]
tl=[ 1 246 443 ]
tu=[ 126 355 ]
pl=[ 187 402 ]
pu=[ 64 302 ]
Current constraints:
al = [ 1 302 ]
f(al) = [ 0.000000 0.150500 ] (fs=1)
Al = [ -0.128429 -0.748362 ] (dB)
au = [ 191 ]
f(au) = [ 0.095000 ] (fs=1)
Au = [ 0.056308 ] (dB)
su = [ 1 54 222 ]
f(su) = [ 0.300500 0.327000 0.411000 ] (fs=1)
Su = [ -40.490431 -44.983748 -56.245524 ] (dB)
tl = [ 1 246 443 ]
f(tl) = [ 0.000000 0.122500 0.221000 ] (fs=1)
Tl = [ 5.987485 5.987300 5.987353 ] (Samples)
tu = [ 126 355 ]
f(tu) = [ 0.062500 0.177000 ] (fs=1)
Tu = [ 6.012518 6.012813 ] (Samples)
pl = [ 187 402 ]
f(pl) = [ 0.093000 0.200500 ] (fs=1)
Pl = [ -3.507513 -7.559788 ] (Samples)
pu = [ 64 302 ]
f(pu) = [ 0.031500 0.150500 ] (fs=1)
Pu = [ -1.185939 -5.672279 ] (Samples)
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

