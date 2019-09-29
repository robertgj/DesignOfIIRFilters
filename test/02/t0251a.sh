#!/bin/sh

prog=tarczynski_frm_halfband_test.m

depends="tarczynski_frm_halfband_test.m \
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
cat > test.r1.ok << 'EOF'
r1 = [   1.0000000000,   0.4650421403,  -0.0756662210,   0.0125742228, ... 
         0.0030944722,  -0.0100384056 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r1.ok"; fail; fi

cat > test.aa1.ok << 'EOF'
aa1 = [  -0.0022730568,   0.0037199326,   0.0049034950,  -0.0046329239, ... 
         -0.0086841885,   0.0062298648,   0.0122190261,   0.0017956534, ... 
         -0.0266708058,  -0.0137096895,   0.0360235999,   0.0362740186, ... 
         -0.0501721957,  -0.0810254219,   0.0522745514,   0.3115883684, ... 
          0.4475813048,   0.3115883684,   0.0522745514,  -0.0810254219, ... 
         -0.0501721957,   0.0362740186,   0.0360235999,  -0.0137096895, ... 
         -0.0266708058,   0.0017956534,   0.0122190261,   0.0062298648, ... 
         -0.0086841885,  -0.0046329239,   0.0049034950,   0.0037199326, ... 
         -0.0022730568 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.aa1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.r1.ok tarczynski_frm_halfband_test_r1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.r1.ok"; fail; fi
diff -Bb test.aa1.ok tarczynski_frm_halfband_test_aa1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.aa1.ok"; fail; fi


#
# this much worked
#
pass

