#!/bin/sh

prog=allpass2ndOrderCascadeDelay_socp_test.m

depends="allpass2ndOrderCascadeDelay_socp_test.m \
test_common.m stability2ndOrderCascade.m print_polynomial.m \
allpass2ndOrderCascade.m allpass2ndOrderCascadeDelay_socp.m \
local_max.m fixResultNaN.m casc2tf.m tf2casc.m SeDuMi_1_3/"
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
a1 = [  -0.4212475147,   1.0771982453,   0.3177671158,  -1.0446316685, ... 
         0.3104469240,   0.7163932826,   0.3312240986,   0.0836798540, ... 
         0.3761881263,  -0.9054554883,   0.8005915016 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi
cat > test_a1sqm_coef.m << 'EOF'
a1sqm = [  -0.8079711730,   0.7379074669,   0.1462308270,  -0.1919636660, ... 
            0.2801222417,   0.5463641890,   0.1500431889,   0.2645642080, ... 
            0.1733747599,  -1.0781165626,   0.8564450299 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1sqm_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m allpass2ndOrderCascadeDelay_socp_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi
diff -Bb test_a1sqm_coef.m allpass2ndOrderCascadeDelay_socp_test_a1sqm_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1sqm_coef.m"; fail; fi


#
# this much worked
#
pass

