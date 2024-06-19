#!/bin/sh

prog=tarczynski_allpass2ndOrderCascade_test.m
depends="test/tarczynski_allpass2ndOrderCascade_test.m allpass2ndOrderCascade.m \
casc2tf.m test_common.m delayz.m print_polynomial.m qroots.m \
qzsolve.oct"

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
cat > test_ab0_coef.m << 'EOF'
ab0 = [  -0.6043902400,  -0.7392878577,   0.3387677852,  -0.6649585554, ... 
          0.5632034950,  -0.7465997852,   0.2983652235,  -1.4216753790, ... 
          0.7011071740,  -0.6553702815,   0.5602443868 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ab0_coef.m"; fail; fi

cat > test_flat_ab0_coef.m << 'EOF'
ab0 = [   0.6722526695,   0.0648310991,   0.4859422622,  -1.3201848189, ... 
          0.5421236043,  -0.3040760452,   0.6433045645,   1.1371539838, ... 
          0.2757729131,  -0.2054929230,  -0.3424142266,  -0.2197767258, ... 
          0.4409717585,  -0.1634944317,   0.5049767306,   1.2760747848, ... 
          0.4208594114,   0.4331572350,  -0.2996471787,  -0.8387006536, ... 
          0.1585524675,  -0.9827780549,   0.5562442310 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_ab0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

strn="tarczynski_allpass2ndOrderCascade_test"

diff -Bb test_ab0_coef.m $strn"_ab0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ab0_coef.m"; fail; fi

diff -Bb test_flat_ab0_coef.m $strn"_flat_delay_ab0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_ab0_coef.m"; fail; fi

#
# this much worked
#
pass

