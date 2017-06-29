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
tol =    1.0000e-05
verbose =  1
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
vR before exchange constraints:
Current constraints:
al = [ 301 ]
al = [ 0.150000 ] (fs=1)
Al = [ -0.205465 ] (dB)
au = [ 1 158 280 601 746 1000 ]
au = [ 0.000000 0.078500 0.139500 0.300000 0.372500 0.499500 ] (fs=1)
Au = [ 0.006718 0.033467 0.091451 -36.422613 -43.060971 -41.720250 ] (dB)
tu = [ 311 ]
tu = [ 0.155000 ] (fs=1)
Tu = [ 16.779185 ] (Samples)
vS before exchange constraints:
Current constraints:
al = [ 1 301 ]
al = [ 0.000000 0.150000 ] (fs=1)
Al = [ -0.184750 -0.785997 ] (dB)
au = [ 601 655 ]
au = [ 0.300000 0.327000 ] (fs=1)
Au = [ -39.996619 -45.040068 ] (dB)
tl = [ 1 246 443 ]
tl = [ 0.000000 0.122500 0.221000 ] (fs=1)
Tl = [ 5.987485 5.987300 5.987353 ] (Samples)
tu = [ 126 355 498 ]
tu = [ 0.062500 0.177000 0.248500 ] (fs=1)
Tu = [ 6.012518 6.012813 6.008989 ] (Samples)
Exchanged constraint from vR.al(301) to vS
vRx7 =
  scalar structure containing the fields:
    al = [](1x0)
    au =
          1
        158
        280
        601
        746
       1000
    sl = [](0x0)
    su = [](0x0)
    tl = [](0x0)
    tu =  311
    pl = [](0x0)
    pu = [](0x0)
vSx7 =
  scalar structure containing the fields:
    al =
         1
       301
    au =
       601
       655
    sl = [](0x0)
    su = [](0x0)
    tl =
         1
       246
       443
    tu =
       126
       355
       498
    pl = [](0x0)
    pu = [](0x0)
exchanged =  1
vR after exchange constraints:
Current constraints:
au = [ 1 158 280 601 746 1000 ]
au = [ 0.000000 0.078500 0.139500 0.300000 0.372500 0.499500 ] (fs=1)
Au = [ -0.184750 -0.026168 -0.457343 -39.996619 -58.593261 -74.560663 ] (dB)
tu = [ 311 ]
tu = [ 0.155000 ] (fs=1)
Tu = [ 6.003178 ] (Samples)
vS after exchange constraints:
Current constraints:
al = [ 1 301 ]
al = [ 0.000000 0.150000 ] (fs=1)
Al = [ -0.184750 -0.785997 ] (dB)
au = [ 601 655 ]
au = [ 0.300000 0.327000 ] (fs=1)
Au = [ -39.996619 -45.040068 ] (dB)
tl = [ 1 246 443 ]
tl = [ 0.000000 0.122500 0.221000 ] (fs=1)
Tl = [ 5.987485 5.987300 5.987353 ] (Samples)
tu = [ 126 355 498 ]
tu = [ 0.062500 0.177000 0.248500 ] (fs=1)
Tu = [ 6.012518 6.012813 6.008989 ] (Samples)
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

