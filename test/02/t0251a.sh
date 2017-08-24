#!/bin/sh

prog=tarczynski_frm_halfband_test.m

depends="tarczynski_frm_halfband_test.m \
test_common.m print_polynomial.m frm_lowpass_vectors.m"
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
cat > test.r1.ok << 'EOF'
r1 = [   1.0000000000,   0.4651958353,  -0.0751629761,   0.0130822302, ... 
         0.0030956411,  -0.0100469871 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r1.ok"; fail; fi
cat > test.aa1.ok << 'EOF'
aa1 = [  -0.0019916244,   0.0039551448,   0.0037663309,  -0.0054664887, ... 
         -0.0074318391,   0.0065318375,   0.0124846793,   0.0003822152, ... 
         -0.0275424096,  -0.0106176175,   0.0371649010,   0.0340474434, ... 
         -0.0500447495,  -0.0817205818,   0.0545198033,   0.3117675530, ... 
          0.4436062056,   0.3117675530,   0.0545198033,  -0.0817205818, ... 
         -0.0500447495,   0.0340474434,   0.0371649010,  -0.0106176175, ... 
         -0.0275424096,   0.0003822152,   0.0124846793,   0.0065318375, ... 
         -0.0074318391,  -0.0054664887,   0.0037663309,   0.0039551448, ... 
         -0.0019916244 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.aa1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.r1.ok tarczynski_frm_halfband_test_r1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.r1.ok"; fail; fi
diff -Bb test.aa1.ok tarczynski_frm_halfband_test_aa1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.aa1.ok"; fail; fi


#
# this much worked
#
pass

