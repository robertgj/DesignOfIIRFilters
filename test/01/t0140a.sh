#!/bin/sh

prog=schurFIRlatticeFilter_test.m

depends="schurFIRlatticeFilter_test.m test_common.m schurFIRlatticeFilter.m \
schurFIRdecomp.oct crossWelch.m"

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
     8.0050
    11.4739
    19.9942
    36.6250
    57.0572
    41.5274
    59.1249
    57.3235
    57.3204
    81.8955
    92.6065
    93.3719
   127.9560
   193.0303
   208.5223
   213.4527
   305.2406
   362.7927
   359.2588
   367.4090
   407.4652
   398.5857
   368.9937
   354.4860
   354.1344
   355.5299
   366.7014
   371.7659
   371.6090
   349.1011
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

