#!/bin/sh

prog=tarczynski_bandpass_hilbert_test.m

depends="test/tarczynski_bandpass_hilbert_test.m test_common.m delayz.m \
print_polynomial.m print_pole_zero.m WISEJ.m x2tf.m tf2Abcd.m tf2x.m zp2x.m \
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
cat > test_x0.ok << 'EOF'
Ux0=2,Vx0=0,Mx0=18,Qx0=10,Rx0=2
x0 = [  -0.0045804400, ...
        -1.6019563465,   0.8936614970, ...
         0.7613131445,   0.8854287244,   1.0509685134,   1.0816826122, ... 
         1.1480418736,   1.1713905007,   1.1737489139,   1.4112330110, ... 
         1.4276393849, ...
         2.4427675113,   1.8140835871,   0.2500321473,   1.6364898610, ... 
         1.9709872396,   2.3418038079,   2.7298736859,   0.7909599399, ... 
         1.0645561043, ...
         0.6124284880,   0.6472894817,   0.6720666998,   0.7470245225, ... 
         0.8420992785, ...
         0.7827753890,   1.7086833353,   2.2219036329,   1.1587834744, ... 
         2.6520651573 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x0.ok tarczynski_bandpass_hilbert_test_x0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x0.ok"; fail; fi


#
# this much worked
#
pass

