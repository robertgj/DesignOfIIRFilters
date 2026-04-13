#!/bin/sh

prog=tarczynski_allpass2ndOrderCascade_test.m
depends="test/tarczynski_allpass2ndOrderCascade_test.m allpass2ndOrderCascade.m \
casc2tf.m test_common.m delayz.m print_polynomial.m qroots.oct \
"

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
ab0 = [  -0.4896240620,  -0.9974609241,   0.6227336117,  -0.9767363257, ... 
          0.5038481704,  -0.8681807013,   0.5454560711,  -1.2238689543, ... 
          0.8976857017,  -1.0084823443,   0.3161478071 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ab0_coef.m"; fail; fi

cat > test_flat_ab0_coef.m << 'EOF'
ab0 = [  -0.5167346383,   0.1706096215,  -0.3653680348,   0.8025531482, ... 
          0.2596185687,   0.4500024494,   0.5466854575,  -0.4493685705, ... 
         -0.0379154977,  -0.1024135361,   0.2074166570,   0.9767890954, ... 
          0.3196056206,   0.3853418601,   0.5162236730,   0.4431618823, ... 
          0.3616770247,   0.1046743095,  -0.4301826014,  -1.2439815202, ... 
          0.5392900712,  -0.8760149844,   0.6220241337 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_ab0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="tarczynski_allpass2ndOrderCascade_test"

diff -Bb test_ab0_coef.m $nstr"_ab0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ab0_coef.m"; fail; fi

diff -Bb test_flat_ab0_coef.m $nstr"_flat_delay_ab0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_ab0_coef.m"; fail; fi

#
# this much worked
#
pass

