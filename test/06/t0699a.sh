#!/bin/sh

prog=tarczynski_bandpass_hilbert_R2_test.m

depends="test/tarczynski_bandpass_hilbert_R2_test.m test_common.m delayz.m \
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
Ux0=2,Vx0=2,Mx0=18,Qx0=8,Rx0=2
x0 = [  -0.0019309929, ...
        -2.1450836505,  -1.1625273498, ...
        -0.8455646026,  -0.7677432964, ...
         0.7810305207,   0.8760346874,   0.9768980319,   1.0668836456, ... 
         1.0934929679,   1.1713162822,   1.1993706732,   1.4151924022, ... 
         1.6375157960, ...
         2.6383776469,   1.8332638829,   1.5874459314,   0.2634548172, ... 
         1.6578017663,   1.9993401344,   2.3714393587,   1.0037100297, ... 
         0.7828429618, ...
         0.6933582682,   0.7172608702,   0.7754575897,   0.8744557271, ...
         2.0649478565,   1.5615430507,   2.5749749277,   1.1457081990 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x0.ok tarczynski_bandpass_hilbert_R2_test_x0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x0.ok"; fail; fi


#
# this much worked
#
pass

