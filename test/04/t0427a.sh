#!/bin/sh

prog=zolotarev_chen_parks_test.m

depends="zolotarev_chen_parks_test.m zolotarev_chen_parks.m test_common.m \
elliptic_F.m elliptic_E.m jacobi_Eta.m jacobi_Zeta.m \
jacobi_theta1.m jacobi_theta1k.m jacobi_theta2.m jacobi_theta2k.m \
jacobi_theta3.m jacobi_theta3k.m jacobi_theta4.m jacobi_theta4k.m \
jacobi_theta2p.m jacobi_theta4p.m jacobi_theta4kp.m \
carlson_RJ.m carlson_RD.m carlson_RC.m carlson_RF.m"

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
N=32,L=6,k=0.8,xm= 1.1001715841,fm=47.2793999460
a= 1.1813437747,fa= 1.0000000000,b= 1.2985780030,fb= 1.0000000000
N=32,L=1,k=0.999,xm= 1.0308019187,fm=85.8149107926
a= 1.0396533124,fa= 1.0000000000,b= 1.0397343162,fb=-1.0000000000
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

