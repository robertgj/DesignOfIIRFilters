#!/bin/sh

prog=mcclellanFIRsymmetric_bandpass_test.m

depends="mcclellanFIRsymmetric_bandpass_test.m test_common.m \
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
hM = [  -0.0001825792,  -0.0000454355,   0.0004370679,   0.0002807949, ... 
        -0.0005520292,  -0.0004924576,   0.0003279243,   0.0002034241, ... 
         0.0001098090,   0.0011408993,   0.0000084476,  -0.0033146927, ... 
        -0.0014230452,   0.0050412028,   0.0037898840,  -0.0046801365, ... 
        -0.0049343476,   0.0020859086,   0.0019942325,   0.0002287784, ... 
         0.0059232581,   0.0017378064,  -0.0154830996,  -0.0096436533, ... 
         0.0202482490,   0.0192036966,  -0.0156768643,  -0.0206396147, ... 
         0.0049234838,   0.0048498311,  -0.0000052363,   0.0281745803, ... 
         0.0154584790,  -0.0653441300,  -0.0573965919,   0.0857782989, ... 
         0.1158919480,  -0.0734661088,  -0.1675416638,   0.0289464179, ... 
         0.1881653480 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

cat > test_hM_LD.ok << 'EOF'
hM_LD = [  -0.0001825792,  -0.0000454355,   0.0004370679,   0.0002807949, ... 
           -0.0005520292,  -0.0004924576,   0.0003279243,   0.0002034241, ... 
            0.0001098090,   0.0011408993,   0.0000084476,  -0.0033146927, ... 
           -0.0014230452,   0.0050412028,   0.0037898840,  -0.0046801365, ... 
           -0.0049343476,   0.0020859086,   0.0019942325,   0.0002287784, ... 
            0.0059232581,   0.0017378064,  -0.0154830996,  -0.0096436533, ... 
            0.0202482490,   0.0192036966,  -0.0156768643,  -0.0206396147, ... 
            0.0049234838,   0.0048498311,  -0.0000052363,   0.0281745803, ... 
            0.0154584790,  -0.0653441300,  -0.0573965919,   0.0857782989, ... 
            0.1158919480,  -0.0734661088,  -0.1675416638,   0.0289464179, ... 
            0.1881653480 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_LD.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok mcclellanFIRsymmetric_bandpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

diff -Bb test_hM_LD.ok mcclellanFIRsymmetric_bandpass_test_hM_LD_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_LD.ok"; fail; fi

#
# this much worked
#
pass

