#!/bin/sh

prog=lowpass2ndOrderCascade_socp_test.m

depends="lowpass2ndOrderCascade_socp_test.m \
test_common.m stability2ndOrderCascade.m print_polynomial.m print_pole_zero.m \
lowpass2ndOrderCascade_socp.m x2tf.m casc2tf.m tf2casc.m SeDuMi_1_3/"
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
cat > test.a.ok << 'EOF'
a = [  -0.0021092647,   0.0004069329,   0.0076883394,   0.0051931733, ... 
       -0.0115231077,  -0.0210543663,   0.0019486082,   0.0417050319, ... 
        0.0578424345,   0.0390044901,   0.0123776721 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed x.a output cat"; fail; fi
cat > test.d.ok << 'EOF'
d = [   1.0000000000,  -2.4277939779,   3.0446749932,  -2.3351332887, ... 
        1.1383562667,  -0.3371599411,   0.0468622432 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed x.d output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.a.ok lowpass2ndOrderCascade_socp_test_a_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.a.ok"; fail; fi
diff -Bb test.d.ok lowpass2ndOrderCascade_socp_test_d_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.d.ok"; fail; fi


#
# this much worked
#
pass

