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
r1 = [   1.0000000000,   0.4653218344,  -0.0748844988,   0.0136271947, ... 
         0.0036404244,  -0.0098545395 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r1.ok"; fail; fi
cat > test.aa1.ok << 'EOF'
aa1 = [  -0.0019386694,   0.0038651658,   0.0038966667,  -0.0055183094, ... 
         -0.0073803747,   0.0065412259,   0.0124707032,   0.0002743368, ... 
         -0.0274018042,  -0.0109536422,   0.0372892516,   0.0338854400, ... 
         -0.0500123121,  -0.0817477325,   0.0546928300,   0.3116333907, ... 
          0.4440189387,   0.3116333907,   0.0546928300,  -0.0817477325, ... 
         -0.0500123121,   0.0338854400,   0.0372892516,  -0.0109536422, ... 
         -0.0274018042,   0.0002743368,   0.0124707032,   0.0065412259, ... 
         -0.0073803747,  -0.0055183094,   0.0038966667,   0.0038651658, ... 
         -0.0019386694 ]';
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

