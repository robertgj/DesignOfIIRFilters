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
verbose =  1
tol =    1.0000e-05
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
al=[ 1 301 ]
au=[ 601 655 823 ]
sl=[ ]
su=[ ]
tl=[ 1 246 443 ]
tu=[ 126 355 ]
pl=[ ]
pu=[ ]
Current constraints:
al = [ 1 301 ]
al = [ 0.000000 0.150000 ] (fs=1)
Al = [ -0.184750 -0.785997 ] (dB)
au = [ 601 655 823 ]
au = [ 0.300000 0.327000 0.411000 ] (fs=1)
Au = [ -39.996619 -45.040068 -56.301844 ] (dB)
tl = [ 1 246 443 ]
tl = [ 0.000000 0.122500 0.221000 ] (fs=1)
Tl = [ 5.987485 5.987300 5.987353 ] (Samples)
tu = [ 126 355 ]
tu = [ 0.062500 0.177000 ] (fs=1)
Tu = [ 6.012518 6.012813 ] (Samples)
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

