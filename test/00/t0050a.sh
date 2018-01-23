#!/bin/sh

prog=print_pole_zero_test.m

depends="print_pole_zero_test.m test_common.m print_pole_zero.m tf2x.m"
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
cat > test.ok.1 << 'EOF'
Ux1=2,Vx1=0,Mx1=8,Qx1=6,Rx1=1
x1 = [   0.0000239596, ...
        -1.0185328804,  -0.9819323779, ...
         1.0130257221,   0.9999349523,   0.9871416150,   3.1285888592, ...
         3.1232903388,   3.1287191112,   0.8912076376,   0.7125050633, ...
         0.5860298117,   0.5183051138,   0.6191205855, ...
         0.5434273135,   0.3836450090,   0.1408034717 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok.1"; fail; fi
cat > test.ok.2 << 'EOF'
Ux1=2,Vx1=0,Mx1=8,Qx1=6,Rx1=1
x1 = [  2.39596e-05, ...
       -1.01853e+00, -9.81932e-01, ...
        1.01303e+00,  9.99935e-01,  9.87142e-01,  3.12859e+00, ...
        3.12329e+00,  3.12872e+00,  8.91208e-01,  7.12505e-01, ...
        5.86030e-01,  5.18305e-01,  6.19121e-01, ...
        5.43427e-01,  3.83645e-01,  1.40803e-01 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok.2"; fail; fi
cat > test.ok.3 << 'EOF'
Ux2=2,Vx2=2,Mx2=22,Qx2=0,Rx2=2
x2 = [   0.0055318501, ...
        -2.5170628267,  -1.3160752171, ...
        -0.9079560306,  -0.2702693669, ...
         1.3053646150,   1.2801395738,   1.2456947672,   1.3543532252, ... 
         1.3403287270,   1.3017511081,   1.1940391431,   1.0576999798, ... 
         0.8556865803,   0.6295823844,   0.5427361878, ...
         2.8130739332,   2.4936224647,   2.1815962607,   0.2206288358, ... 
         0.6636910430,   1.1146343826,   1.8756693941,   1.6003195241, ... 
         1.5609093563,   1.0945324853,   0.3906957551 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok.3"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.1 print_pole_zero_test.coef.1
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi
diff -Bb test.ok.2 print_pole_zero_test.coef.2
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi
diff -Bb test.ok.3 print_pole_zero_test.coef.3
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

