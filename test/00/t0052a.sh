#!/bin/sh

prog=allpass2ndOrderCascade_socp_test.m

depends="test/allpass2ndOrderCascade_socp_test.m \
../tarczynski_allpass2ndOrderCascade_test_flat_delay_ab0_coef.m \
test_common.m stability2ndOrderCascade.m print_polynomial.m \
allpass2ndOrderCascade.m allpass2ndOrderCascade_socp.m \
casc2tf.m tf2casc.m qroots.m qzsolve.oct"

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
cat > test_a1_coef.m << 'EOF'
a1 = [   0.6633914912,   0.0814907517,   0.3631050430,  -1.1902766262, ... 
         0.4909956847,  -0.6364899703,   0.5204352646,   1.1134122429, ... 
         0.2456655839,  -0.1910909588,  -0.2858567007 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi
cat > test_b1_coef.m << 'EOF'
b1 = [  -0.2621457649,   0.0752261038,  -0.0146249222,   0.3528100144, ... 
         1.1954081752,   0.3589309964,   0.3222312861,  -0.4008746221, ... 
        -0.9697179449,   0.2653072759,  -0.8822769049,   0.8651325258 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m allpass2ndOrderCascade_socp_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m allpass2ndOrderCascade_socp_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_b1_coef.m"; fail; fi


#
# this much worked
#
pass

