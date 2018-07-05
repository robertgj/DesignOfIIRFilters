#!/bin/sh

prog=iir_slb_exchange_constraints_test.m

depends="iir_slb_exchange_constraints_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb_exchange_constraints.m iir_slb_update_constraints.m \
iir_slb_show_constraints.m iirA.m iirP.m iirT.m local_max.m local_peak.m \
fixResultNaN.m"
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
maxiter =  2000
tol =  0.000010000
verbose = 1
U = 0
V = 0
Q =  6
M =  10
R =  1
fap =  0.15000
dBap =  0.10000
Wap =  1
fas =  0.30000
dBas =  50
Was =  10
ftp =  0.25000
tp =  6
tpr =  0.010000
Wtp =  0.10000
fpp =  0.25000
pd = 0
ppr =  0.0020000
Wpp =  0.0010000
vR before exchange constraints:
Current constraints:
al = [ 302 ]
f(al) = [ 0.150500 ] (fs=1)
Al = [ -0.241843 ] (dB)
au = [ 1 158 280 ]
f(au) = [ 0.000000 0.078500 0.139500 ] (fs=1)
Au = [ 0.006718 0.033467 0.091451 ] (dB)
su = [ 1 145 400 ]
f(su) = [ 0.300500 0.372500 0.500000 ] (fs=1)
Su = [ -36.609877 -43.060971 -41.719722 ] (dB)
tu = [ 311 ]
f(tu) = [ 0.155000 ] (fs=1)
Tu = [ 16.779185 ] (Samples)
pl = [ 501 ]
f(pl) = [ 0.250000 ] (fs=1)
Pl = [ -18.371034 ] (Samples)
vS before exchange constraints:
Current constraints:
al = [ 1 302 ]
f(al) = [ 0.000000 0.150500 ] (fs=1)
Al = [ -0.184750 -0.804683 ] (dB)
su = [ 1 54 ]
f(su) = [ 0.300500 0.327000 ] (fs=1)
Su = [ -40.546752 -45.040068 ] (dB)
tl = [ 1 246 443 ]
f(tl) = [ 0.000000 0.122500 0.221000 ] (fs=1)
Tl = [ 5.987485 5.987300 5.987353 ] (Samples)
tu = [ 126 355 498 ]
f(tu) = [ 0.062500 0.177000 0.248500 ] (fs=1)
Tu = [ 6.012518 6.012813 6.008989 ] (Samples)
pl = [ 187 402 ]
f(pl) = [ 0.093000 0.200500 ] (fs=1)
Pl = [ -3.507513 -7.559788 ] (Samples)
pu = [ 64 302 ]
f(pu) = [ 0.031500 0.150500 ] (fs=1)
Pu = [ -1.185939 -5.672279 ] (Samples)
Exchanged constraint from vR.al(302) to vS
vRx7 =
  scalar structure containing the fields:
    al = [](1x0)
    au =
         1
       158
       280
    sl = [](0x0)
    su =
         1
       145
       400
    tl = [](0x0)
    tu =  311
    pl =  501
    pu = [](0x0)

vSx7 =
  scalar structure containing the fields:
    al =
         1
       302
    au = [](0x0)
    sl = [](0x0)
    su =
        1
       54
    tl =
         1
       246
       443
    tu =
       126
       355
       498
    pl =
       187
       402
    pu =
        64
       302

exchanged = 1
vR after exchange constraints:
Current constraints:
au = [ 1 158 280 ]
f(au) = [ 0.000000 0.078500 0.139500 ] (fs=1)
Au = [ -0.184750 -0.026168 -0.457343 ] (dB)
su = [ 1 145 400 ]
f(su) = [ 0.300500 0.372500 0.500000 ] (fs=1)
Su = [ -40.546752 -58.593261 -74.565117 ] (dB)
tu = [ 311 ]
f(tu) = [ 0.155000 ] (fs=1)
Tu = [ 6.003178 ] (Samples)
pl = [ 501 ]
f(pl) = [ 0.250000 ] (fs=1)
Pl = [ -9.424431 ] (Samples)
vS after exchange constraints:
Current constraints:
al = [ 1 302 ]
f(al) = [ 0.000000 0.150500 ] (fs=1)
Al = [ -0.184750 -0.804683 ] (dB)
su = [ 1 54 ]
f(su) = [ 0.300500 0.327000 ] (fs=1)
Su = [ -40.546752 -45.040068 ] (dB)
tl = [ 1 246 443 ]
f(tl) = [ 0.000000 0.122500 0.221000 ] (fs=1)
Tl = [ 5.987485 5.987300 5.987353 ] (Samples)
tu = [ 126 355 498 ]
f(tu) = [ 0.062500 0.177000 0.248500 ] (fs=1)
Tu = [ 6.012518 6.012813 6.008989 ] (Samples)
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
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

