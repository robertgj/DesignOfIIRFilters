#!/bin/sh

prog=allpass2ndOrderCascade_socp_test.m

depends="allpass2ndOrderCascade_socp_test.m \
test_common.m stability2ndOrderCascade.m print_polynomial.m \
allpass2ndOrderCascade.m allpass2ndOrderCascade_socp.m \
casc2tf.m tf2casc.m SeDuMi_1_3/"
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
a1 = [  -0.3886778788,  -1.1714215254,   0.5348178883,  -0.3155085230, ... 
         0.8306967580,   0.9425118218,   0.6632816869,  -0.5279545715, ... 
         0.6123199111,  -0.3999511418,  -0.1735918137 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi
cat > test_b1_coef.m << 'EOF'
b1 = [  -1.2672786021,   0.4645351038,  -0.5300346634,   0.4986290583, ... 
         0.9445419509,   0.6640912419,  -0.2937208160,  -0.1642197261, ... 
        -0.3151019717,   0.8341889523,  -0.8545522695,   0.8310544334 ]';
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

