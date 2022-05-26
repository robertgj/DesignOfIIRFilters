#!/bin/sh

prog=herrmannFIRsymmetric_flat_lowpass_test.m

depends="test/herrmannFIRsymmetric_flat_lowpass_test.m test_common.m \
herrmannFIRsymmetric_flat_lowpass.m directFIRsymmetricA.m print_polynomial.m"

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
cat > test_hM18K11.ok << 'EOF'
hM18K11 = [ -0.000000283006, -0.000001797918,  0.000000000000,  0.000023772474, ... 
             0.000038205762, -0.000131662935, -0.000380359590,  0.000333432108, ... 
             0.001986699644,  0.000158483163, -0.006846472621, -0.004768079147, ... 
             0.016997319181,  0.022251036018, -0.031787194312, -0.073816929013, ... 
             0.045892761787,  0.305951745249,  0.448198646307 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM18K11.ok"; fail; fi

cat > test_aM18K11.ok << 'EOF'
aM18K11 = [            1,            0,            0,            0, ... 
                       0,            0,            0,            0, ... 
                  -43758,       388960,     -1575288,      3818880, ... 
                -6126120,      6785856,     -5250960,      2800512, ... 
                 -984555,       205920,       -19448 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aM18K11.ok"; fail; fi

cat > test_hM18K12.ok << 'EOF'
hM18K12 = [  0.000000180095,  0.000001906883,  0.000006483402, -0.000002161134, ... 
            -0.000068770372, -0.000131662935,  0.000190179795,  0.000985477120, ... 
             0.000499221962, -0.003264753148, -0.005420124158,  0.004671754315, ... 
             0.020200119819,  0.006068464369, -0.046524893492, -0.056863758713, ... 
             0.074633683311,  0.298534733243,  0.412967839278 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM18K12.ok"; fail; fi

cat > test_aM18K12.ok << 'EOF'
aM18K12 = [            1,            0,            0,            0, ... 
                       0,            0,            0,       -31824, ... 
                  306306,     -1361360,      3675672,     -6683040, ... 
                 8576568,     -7916832,      5250960,     -2450448, ... 
                  765765,      -144144,        12376 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aM18K12.ok"; fail; fi

cat > test_hM19K11.ok << 'EOF'
hM19K11 = [  0.000000159191,  0.000000672138, -0.000001957109, -0.000012098491, ... 
             0.000007057453,  0.000102837177,  0.000027686932, -0.000548464945, ... 
            -0.000430046377,  0.002056743542,  0.002490944957, -0.005758881918, ... 
            -0.009666694648,  0.012477577489,  0.029411432653, -0.021390132839, ... 
            -0.080658625913,  0.029411432653,  0.308820042861,  0.467320630385 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM19K11.ok"; fail; fi

cat > test_aM19K11.ok << 'EOF'
aM19K11 = [            1,            0,            0,            0, ... 
                       0,            0,            0,            0, ... 
                       0,       -92378,       831402,     -3401190, ... 
                 8314020,    -13430340,     14965236,    -11639628, ... 
                 6235515,     -2200770,       461890,       -43758 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aM19K11.ok"; fail; fi

cat > test_hM19K12.ok << 'EOF'
hM19K12 = [ -0.000000115775, -0.000000977656, -0.000001682143,  0.000008798903, ... 
             0.000035928853, -0.000008798903, -0.000247553748, -0.000258101150, ... 
             0.000888689188,  0.001935758628, -0.001537852688, -0.007637447678, ... 
            -0.001205449691,  0.020284404047,  0.017043474829, -0.039348693565, ... 
            -0.068841149448,  0.057879182976,  0.303865710623,  0.434291748796 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM19K12.ok"; fail; fi

cat > test_aM19K12.ok << 'EOF'
aM19K12 = [            1,            0,            0,            0, ... 
                       0,            0,            0,            0, ... 
                  -75582,       739024,     -3325608,      9069840, ... 
               -16628040,     21488544,    -19953648,     13302432, ... 
                -6235515,      1956240,      -369512,        31824 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aM19K12.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM18K11.ok herrmannFIRsymmetric_flat_lowpass_test_hM18K11_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM18K11.ok"; fail; fi

diff -Bb test_aM18K11.ok herrmannFIRsymmetric_flat_lowpass_test_aM18K11_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aM18K11.ok"; fail; fi

diff -Bb test_hM18K12.ok herrmannFIRsymmetric_flat_lowpass_test_hM18K12_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM18K12.ok"; fail; fi

diff -Bb test_aM18K12.ok herrmannFIRsymmetric_flat_lowpass_test_aM18K12_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aM18K12.ok"; fail; fi

diff -Bb test_hM19K11.ok herrmannFIRsymmetric_flat_lowpass_test_hM19K11_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM19K11.ok"; fail; fi

diff -Bb test_aM19K11.ok herrmannFIRsymmetric_flat_lowpass_test_aM19K11_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aM19K11.ok"; fail; fi

diff -Bb test_hM19K12.ok herrmannFIRsymmetric_flat_lowpass_test_hM19K12_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM19K12.ok"; fail; fi

diff -Bb test_aM19K12.ok herrmannFIRsymmetric_flat_lowpass_test_aM19K12_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aM19K12.ok"; fail; fi

#
# this much worked
#
pass

