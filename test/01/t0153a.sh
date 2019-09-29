#!/bin/sh

prog=svcasc2noise_test.m

depends="svcasc2noise_test.m test_common.m \
svcasc2noise.m butter2pq.m pq2svcasc.m svcasc2Abcd.m KW.m"

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
cat > test.ok << 'EOF'
ngcasc=[ 1.302 2.100 2.860 2.685 1.881 1.079 0.564 0.307 0.217 0.080 ]
Hl2=[ 0.111 0.088 0.078 0.074 0.075 0.080 0.091 0.120 0.245 1.000 ]
xbits=[ 0.339 0.683 0.906 0.861 0.604 0.203 -0.265 -0.703 -0.953 -1.677 ]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.out"; fail; fi

#
# this much worked
#
pass

