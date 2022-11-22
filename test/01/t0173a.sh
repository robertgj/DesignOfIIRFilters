#!/bin/sh

prog=sos2pq_test.m
depends="test/sos2pq_test.m test_common.m sos2pq.m"

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
Testing IIR, N=1
Testing IIR, N=2
Testing IIR, N=3
Testing IIR, N=4
Testing IIR, N=5
Testing IIR, N=6
Testing IIR, N=7
Testing IIR, N=8
Testing IIR, N=9
Testing IIR, N=10
Testing IIR, N=11
Testing IIR, N=12
Testing FIR, N=1
Testing FIR, N=2
Testing FIR, N=3
Testing FIR, N=4
Testing FIR, N=5
Testing FIR, N=6
Testing FIR, N=7
Testing FIR, N=8
Testing FIR, N=9
Testing FIR, N=10
Testing FIR, N=11
Testing FIR, N=12
Testing mixed IIR/FIR, N=1
Testing mixed IIR/FIR, N=2
Testing mixed IIR/FIR, N=3
Testing mixed IIR/FIR, N=4
Testing mixed IIR/FIR, N=5
Testing mixed IIR/FIR, N=6
Testing mixed IIR/FIR, N=7
Testing mixed IIR/FIR, N=8
Testing mixed IIR/FIR, N=9
Testing mixed IIR/FIR, N=10
Testing mixed IIR/FIR, N=11
Testing mixed IIR/FIR, N=12
Testing mixed2 FIR/IIR, N=1
Testing mixed2 FIR/IIR, N=2
Testing mixed2 FIR/IIR, N=3
Testing mixed2 FIR/IIR, N=4
Testing mixed2 FIR/IIR, N=5
Testing mixed2 FIR/IIR, N=6
Testing mixed2 FIR/IIR, N=7
Testing mixed2 FIR/IIR, N=8
Testing mixed2 FIR/IIR, N=9
Testing mixed2 FIR/IIR, N=10
Testing mixed2 FIR/IIR, N=11
Testing mixed2 FIR/IIR, N=12
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

