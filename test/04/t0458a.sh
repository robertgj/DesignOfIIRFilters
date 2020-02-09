#!/bin/sh

prog=mcclellanFIRsymmetric_lowpass_test.m

depends="mcclellanFIRsymmetric_lowpass_test.m test_common.m \
print_polynomial.m mcclellanFIRsymmetric.m local_max.m lagrange_interp.m \
xfr2tf.m directFIRsymmetricA.m"

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
cat > test_hM.ok << 'EOF'
hM = [  -0.0020632913,  -0.0059266754,  -0.0016831407,   0.0086376134, ... 
         0.0092367643,  -0.0095748911,  -0.0221622199,   0.0023744709, ... 
         0.0391202673,   0.0202379100,  -0.0564060230,  -0.0755221777, ... 
         0.0694057740,   0.3072654865,   0.4257593871 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

cat > test_hM_LD.ok << 'EOF'
hM_LD = [  -0.0020632913,  -0.0059266754,  -0.0016831407,   0.0086376134, ... 
            0.0092367643,  -0.0095748911,  -0.0221622199,   0.0023744709, ... 
            0.0391202673,   0.0202379100,  -0.0564060230,  -0.0755221777, ... 
            0.0694057740,   0.3072654865,   0.4257593871 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_LD.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok mcclellanFIRsymmetric_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

diff -Bb test_hM_LD.ok mcclellanFIRsymmetric_lowpass_test_hM_LD_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_LD.ok"; fail; fi

#
# this much worked
#
pass

