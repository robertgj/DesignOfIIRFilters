#!/bin/sh

prog=schurOneMAPlatticeDoublyPipelined2H_test.m
depends="test/schurOneMAPlatticeDoublyPipelined2H_test.m \
test_common.m \
schurOneMAPlatticeDoublyPipelined2H.m \
schurOneMAPlatticeDoublyPipelined2Abcd.m \
schurOneMlatticeDoublyPipelined2Abcd.m \
tf2schurOneMlattice.m Abcd2tf.m qroots.m schurOneMscale.m tf2pa.m Abcd2H.m \
schurdecomp.oct schurexpand.oct qzsolve.oct spectralfactor.oct" 

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
warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 36 column 4

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 37 column 4

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 94 column 13
    schurOneMAPlatticeDoublyPipelined2H_test at line 50 column 11

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 55 column 11

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 57 column 11

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 94 column 13
    schurOneMAPlatticeDoublyPipelined2H_test at line 66 column 11

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 71 column 11

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 73 column 11

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 82 column 13

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 92 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 96 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 92 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 96 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 92 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 96 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 92 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 96 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 107 column 13

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 117 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 121 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 117 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 121 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 117 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 121 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 117 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 121 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 117 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 92 column 6
    schurOneMAPlatticeDoublyPipelined2H_test at line 121 column 12

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 98 column 26
    schurOneMAPlatticeDoublyPipelined2H_test at line 132 column 19

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 137 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 139 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 98 column 26
    schurOneMAPlatticeDoublyPipelined2H_test at line 148 column 19

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 153 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 155 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 100 column 37
    schurOneMAPlatticeDoublyPipelined2H_test at line 164 column 23

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 174 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 178 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 174 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 178 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 174 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 178 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 174 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 178 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 100 column 37
    schurOneMAPlatticeDoublyPipelined2H_test at line 189 column 23

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 199 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 203 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 199 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 203 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 199 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 203 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 199 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 203 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 199 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 203 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 103 column 50
    schurOneMAPlatticeDoublyPipelined2H_test at line 214 column 27

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 100 column 37
    schurOneMAPlatticeDoublyPipelined2H_test at line 219 column 25

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 100 column 37
    schurOneMAPlatticeDoublyPipelined2H_test at line 221 column 25

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 103 column 50
    schurOneMAPlatticeDoublyPipelined2H_test at line 230 column 27

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 100 column 37
    schurOneMAPlatticeDoublyPipelined2H_test at line 235 column 25

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 100 column 37
    schurOneMAPlatticeDoublyPipelined2H_test at line 237 column 25

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 106 column 58
    schurOneMAPlatticeDoublyPipelined2H_test at line 246 column 23

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 256 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 261 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 256 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 261 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 256 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 261 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 256 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 261 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 106 column 58
    schurOneMAPlatticeDoublyPipelined2H_test at line 278 column 23

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 288 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 293 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 288 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 293 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 288 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 293 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 288 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 293 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 288 column 16

warning: Using Octave m-file version of function Abcd2H()!
warning: called from
    Abcd2H at line 76 column 1
    schurOneMAPlatticeDoublyPipelined2H at line 96 column 18
    schurOneMAPlatticeDoublyPipelined2H_test at line 293 column 16

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
