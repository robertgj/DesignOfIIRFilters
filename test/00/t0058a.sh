#!/bin/sh

prog=tarczynski_ex2_standalone_test.m

depends="test/tarczynski_ex2_standalone_test.m test_common.m \
WISEJ.m tf2Abcd.m print_polynomial.m"

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
cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,   1.1781972853,   0.2453690259 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi

cat > test.ok.N0 << 'EOF'
N0 = [   0.0055318056,   0.0168959019,   0.0074747069,  -0.0015217632, ... 
        -0.0019752367,   0.0069417252,   0.0033977968,  -0.0102845651, ... 
        -0.0055115952,   0.0171242060,   0.0104429077,  -0.0353411015, ... 
        -0.0284871651,   0.1348459465,   0.4155092437,   0.6323652597, ... 
         0.6374870441,   0.4464420276,   0.1788987531,  -0.0679345776, ... 
         0.2506266798,  -0.3305090495,   0.2959985521,  -0.1721580560, ... 
         0.0604525821 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.D0 tarczynski_ex2_standalone_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D0"; fail; fi

diff -Bb test.ok.N0 tarczynski_ex2_standalone_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N0"; fail; fi

#
# this much worked
#
pass

