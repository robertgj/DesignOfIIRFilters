#!/bin/sh

prog=butter2pq_test.m

depends="butter2pq_test.m test_common.m butter2pq.m"

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
cat > test.ok << 'EOF'
Testing butter2pq low-pass, N=1,fc=0.100000
Testing butter2pq high-pass, N=1,fc=0.100000
Testing butter2pq low-pass, N=2,fc=0.100000
Testing butter2pq high-pass, N=2,fc=0.100000
Testing butter2pq low-pass, N=3,fc=0.100000
Testing butter2pq high-pass, N=3,fc=0.100000
Testing butter2pq low-pass, N=4,fc=0.100000
Testing butter2pq high-pass, N=4,fc=0.100000
Testing butter2pq low-pass, N=5,fc=0.100000
Testing butter2pq high-pass, N=5,fc=0.100000
Testing butter2pq low-pass, N=6,fc=0.100000
Testing butter2pq high-pass, N=6,fc=0.100000
Testing butter2pq low-pass, N=7,fc=0.100000
Testing butter2pq high-pass, N=7,fc=0.100000
Testing butter2pq low-pass, N=8,fc=0.100000
Testing butter2pq high-pass, N=8,fc=0.100000
Testing butter2pq low-pass, N=9,fc=0.100000
Testing butter2pq high-pass, N=9,fc=0.100000
Testing butter2pq low-pass, N=10,fc=0.100000
Testing butter2pq high-pass, N=10,fc=0.100000
Testing butter2pq low-pass, N=11,fc=0.100000
Testing butter2pq high-pass, N=11,fc=0.100000
Testing butter2pq low-pass, N=12,fc=0.100000
Testing butter2pq high-pass, N=12,fc=0.100000
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

