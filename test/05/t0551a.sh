#!/bin/sh

prog=tarczynski_frm_allpass_test.m

depends="tarczynski_frm_allpass_test.m test_common.m print_polynomial.m \
print_pole_zero.m frm_lowpass_vectors.m"

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
cat > test_r1.ok << 'EOF'
r1 = [   1.0000000000,   0.1876459113,   0.4881097993,  -0.1253205705, ... 
        -0.0610225063,   0.0673118421,  -0.0387929002,   0.0368835476, ... 
        -0.0238900058,  -0.0021676228,   0.0030644685 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r1.ok"; fail; fi

cat > test_aa1.ok << 'EOF'
aa1 = [  -0.0162624037,  -0.0082479297,   0.0241750114,  -0.0038413357, ... 
         -0.0204538826,   0.0042722437,   0.0130773232,  -0.0179720752, ... 
          0.0007715413,   0.0432024545,  -0.0035326967,  -0.0548789732, ... 
          0.0348901611,   0.0369363817,  -0.0463567243,   0.0056876458, ... 
          0.0744016235,  -0.0740250599,  -0.1101634768,   0.2981156918, ... 
          0.6278454616,   0.2981156918,  -0.1101634768,  -0.0740250599, ... 
          0.0744016235,   0.0056876458,  -0.0463567243,   0.0369363817, ... 
          0.0348901611,  -0.0548789732,  -0.0035326967,   0.0432024545, ... 
          0.0007715413,  -0.0179720752,   0.0130773232,   0.0042722437, ... 
         -0.0204538826,  -0.0038413357,   0.0241750114,  -0.0082479297, ... 
         -0.0162624037 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa1.ok"; fail; fi

cat > test_ac1.ok << 'EOF'
ac1 = [  -0.0135131740,   0.0534250924,   0.1707296163,   0.0584050504, ... 
         -0.0211007053,  -0.0048056062,   0.0090734205,  -0.0036970850, ... 
         -0.0023175614,  -0.0286943882,   0.1321272295,   0.4586744193, ... 
          0.1714886463,  -0.0794844448,  -0.0079397941,   0.0562652034, ... 
         -0.0557399987,  -0.0081310517,   0.0738889171,  -0.0812737222, ... 
         -0.0605221782,  -0.0812737222,   0.0738889171,  -0.0081310517, ... 
         -0.0557399987,   0.0562652034,  -0.0079397941,  -0.0794844448, ... 
          0.1714886463,   0.4586744193,   0.1321272295,  -0.0286943882, ... 
         -0.0023175614,  -0.0036970850,   0.0090734205,  -0.0048056062, ... 
         -0.0211007053,   0.0584050504,   0.1707296163,   0.0534250924, ... 
         -0.0135131740 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_r1.ok tarczynski_frm_allpass_test_r1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r1.ok"; fail; fi

diff -Bb test_aa1.ok tarczynski_frm_allpass_test_aa1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aa1.ok"; fail; fi

diff -Bb test_ac1.ok tarczynski_frm_allpass_test_ac1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ac1.ok"; fail; fi


#
# this much worked
#
pass

