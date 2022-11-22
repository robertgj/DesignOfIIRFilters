#!/bin/sh

prog=tarczynski_frm_halfband_test.m

depends="test/tarczynski_frm_halfband_test.m \
test_common.m print_polynomial.m frm_lowpass_vectors.m"
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
cat > test.r0.ok << 'EOF'
r0 = [   1.0000000000,   0.4651552126,  -0.0744511408,   0.0128358407, ... 
         0.0034282177,  -0.0100194983 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r0.ok"; fail; fi

cat > test.aa0.ok << 'EOF'
aa0 = [  -0.0022694339,   0.0062116892,   0.0037416038,  -0.0038882269, ... 
         -0.0095668168,   0.0058813289,   0.0122294150,   0.0014665828, ... 
         -0.0299801936,  -0.0110279809,   0.0340324487,   0.0360342003, ... 
         -0.0508111862,  -0.0816079767,   0.0516397722,   0.3151760055, ... 
          0.4432004039,   0.3151760055,   0.0516397722,  -0.0816079767, ... 
         -0.0508111862,   0.0360342003,   0.0340324487,  -0.0110279809, ... 
         -0.0299801936,   0.0014665828,   0.0122294150,   0.0058813289, ... 
         -0.0095668168,  -0.0038882269,   0.0037416038,   0.0062116892, ... 
         -0.0022694339 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.aa0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.r0.ok tarczynski_frm_halfband_test_r0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.r0.ok"; fail; fi
diff -Bb test.aa0.ok tarczynski_frm_halfband_test_aa0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.aa0.ok"; fail; fi


#
# this much worked
#
pass

