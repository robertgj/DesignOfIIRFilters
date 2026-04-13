#!/bin/sh

prog=tarczynski_frm_allpass_test.m

depends="test/tarczynski_frm_allpass_test.m test_common.m delayz.m print_polynomial.m \
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
r1 = [   1.0000000000,   0.3297155388,   0.4322858059,  -0.1372103743, ... 
        -0.0287118844,   0.0479523402,  -0.0207679173,   0.0150885435, ... 
        -0.0190943600,   0.0070258114,   0.0062691617 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r1.ok"; fail; fi

cat > test_aa1.ok << 'EOF'
aa1 = [  -0.0248678186,  -0.0156684538,   0.0338116677,  -0.0027482696, ... 
         -0.0339165257,   0.0056131684,   0.0216919576,  -0.0220955547, ... 
         -0.0093270361,   0.0642483630,   0.0110472256,  -0.0745810737, ... 
          0.0356777689,   0.0623659775,  -0.0518940065,  -0.0083909117, ... 
          0.0854373528,  -0.0628406105,  -0.1389146487,   0.2886883076, ... 
          0.6521910290,   0.2886883076,  -0.1389146487,  -0.0628406105, ... 
          0.0854373528,  -0.0083909117,  -0.0518940065,   0.0623659775, ... 
          0.0356777689,  -0.0745810737,   0.0110472256,   0.0642483630, ... 
         -0.0093270361,  -0.0220955547,   0.0216919576,   0.0056131684, ... 
         -0.0339165257,  -0.0027482696,   0.0338116677,  -0.0156684538, ... 
         -0.0248678186 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa1.ok"; fail; fi

cat > test_ac1.ok << 'EOF'
ac1 = [  -0.0177382757,   0.0546456285,   0.1743090479,   0.0603182311, ... 
         -0.0229495071,  -0.0073424751,   0.0112373332,   0.0016652173, ... 
         -0.0075324830,  -0.0404003053,   0.1423849686,   0.4935085918, ... 
          0.1855794507,  -0.0847497954,  -0.0150965337,   0.0635939416, ... 
         -0.0472716012,  -0.0155446553,   0.0615273252,  -0.0577272179, ... 
         -0.0012610955,  -0.0577272179,   0.0615273252,  -0.0155446553, ... 
         -0.0472716012,   0.0635939416,  -0.0150965337,  -0.0847497954, ... 
          0.1855794507,   0.4935085918,   0.1423849686,  -0.0404003053, ... 
         -0.0075324830,   0.0016652173,   0.0112373332,  -0.0073424751, ... 
         -0.0229495071,   0.0603182311,   0.1743090479,   0.0546456285, ... 
         -0.0177382757 ]';
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

