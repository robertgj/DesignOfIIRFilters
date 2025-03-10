#!/bin/sh

prog=schurOneMPAlatticeDoublyPipelinedAsq_test.m
depends="test/schurOneMPAlatticeDoublyPipelinedAsq_test.m \
test_common.m \
schurOneMPAlatticeDoublyPipelinedAsq.m \
schurOneMAPlatticeDoublyPipelined2H.m \
schurOneMAPlatticeDoublyPipelined2Abcd.m \
schurOneMlatticeDoublyPipelined2Abcd.m \
tf2schurOneMlattice.m Abcd2tf.m qroots.oct schurOneMscale.m tf2pa.m H2Asq.m \
schurdecomp.oct schurexpand.oct spectralfactor.oct Abcd2H.oct" 

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
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. .
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

