#!/bin/sh

prog=allpass2ndOrderCascade_socp_test.m

depends="allpass2ndOrderCascade_socp_test.m \
test_common.m stability2ndOrderCascade.m print_polynomial.m \
allpass2ndOrderCascade.m allpass2ndOrderCascade_socp.m \
casc2tf.m tf2casc.m qroots.m qzsolve.oct SeDuMi_1_3/"
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
cat > test_a1_coef.m << 'EOF'
a1 = [  -0.3866193132,  -1.1716344944,   0.5341931858,  -0.3268446561, ... 
         0.8229247435,   0.9343003296,   0.6608618162,  -0.5222715410, ... 
         0.6183946762,  -0.4081341790,  -0.1672202937 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi
cat > test_b1_coef.m << 'EOF'
b1 = [  -1.2644762337,   0.4626004764,  -0.5291175874,   0.5051441119, ... 
         0.9363500937,   0.6616615865,  -0.3025987043,  -0.1596748100, ... 
        -0.3260280765,   0.8269831707,  -0.8498130740,   0.8284005965 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m allpass2ndOrderCascade_socp_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m allpass2ndOrderCascade_socp_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_b1_coef.m"; fail; fi


#
# this much worked
#
pass

