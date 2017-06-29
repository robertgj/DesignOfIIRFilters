#!/bin/sh

prog=tarczynski_pink_test.m

depends="tarczynski_pink_test.m test_common.m"
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
cat > test.ok << 'EOF'
N=[   0.0255743587   0.0278384489   0.0321476859   0.0361079952   0.0657889278   0.2319828340   0.0319161641  -0.0285660148  -0.0468650948  -0.0439578015  -0.0332308639   0.0133637638 ]';
R=1,D=[   1.0000000000  -0.0879376251  -0.1670765454  -0.1960898452  -0.1461189848  -0.1356729636   0.1032110433  -0.0102026181   0.0012949550  -0.0039114345  -0.0018552456  -0.0051358746 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok tarczynski_pink_test.coef
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

