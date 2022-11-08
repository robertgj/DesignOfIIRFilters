#!/bin/sh

prog=schurOneMAPlattice2Abcd_symbolic_test.m
depends="test/schurOneMAPlattice2Abcd_symbolic_test.m \
test_common.m schurOneMAPlattice2Abcd.m tf2schurOneMlattice.m tf2Abcd.m \
Abcd2tf.m schurOneMscale.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct"

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
cat > test_N_6_latex.ok << 'EOF'
Abcd=\left[\begin{matrix}- k_{1} & k_{1} + 1 & 0 & 0 & 0 & 0 & 0\\- k_{2} \cdot \left(1 - k_{1}\right) & - k_{1} k_{2} & k_{2} + 1 & 0 & 0 & 0 & 0\\- k_{3} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) & - k_{1} k_{3} \cdot \left(1 - k_{2}\right) & - k_{2} k_{3} & k_{3} + 1 & 0 & 0 & 0\\- k_{4} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) & - k_{1} k_{4} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) & - k_{2} k_{4} \cdot \left(1 - k_{3}\right) & - k_{3} k_{4} & k_{4} + 1 & 0 & 0\\- k_{5} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) & - k_{1} k_{5} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) & - k_{2} k_{5} \cdot \left(1 - k_{3}\right) \left(1 - k_{4}\right) & - k_{3} k_{5} \cdot \left(1 - k_{4}\right) & - k_{4} k_{5} & k_{5} + 1 & 0\\- k_{6} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) & - k_{1} k_{6} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) & - k_{2} k_{6} \cdot \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) & - k_{3} k_{6} \cdot \left(1 - k_{4}\right) \left(1 - k_{5}\right) & - k_{4} k_{6} \cdot \left(1 - k_{5}\right) & - k_{5} k_{6} & k_{6} + 1\\\left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) & k_{1} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) & k_{2} \cdot \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) & k_{3} \cdot \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) & k_{4} \cdot \left(1 - k_{5}\right) \left(1 - k_{6}\right) & k_{5} \cdot \left(1 - k_{6}\right) & k_{6}\end{matrix}\right]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N_6_latex.ok"; fail; fi

cat > test_N_7_latex.ok << 'EOF'
Abcd=\left[\begin{matrix}- k_{1} & k_{1} + 1 & 0 & 0 & 0 & 0 & 0 & 0\\- k_{2} \cdot \left(1 - k_{1}\right) & - k_{1} k_{2} & k_{2} + 1 & 0 & 0 & 0 & 0 & 0\\- k_{3} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) & - k_{1} k_{3} \cdot \left(1 - k_{2}\right) & - k_{2} k_{3} & k_{3} + 1 & 0 & 0 & 0 & 0\\- k_{4} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) & - k_{1} k_{4} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) & - k_{2} k_{4} \cdot \left(1 - k_{3}\right) & - k_{3} k_{4} & k_{4} + 1 & 0 & 0 & 0\\- k_{5} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) & - k_{1} k_{5} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) & - k_{2} k_{5} \cdot \left(1 - k_{3}\right) \left(1 - k_{4}\right) & - k_{3} k_{5} \cdot \left(1 - k_{4}\right) & - k_{4} k_{5} & k_{5} + 1 & 0 & 0\\- k_{6} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) & - k_{1} k_{6} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) & - k_{2} k_{6} \cdot \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) & - k_{3} k_{6} \cdot \left(1 - k_{4}\right) \left(1 - k_{5}\right) & - k_{4} k_{6} \cdot \left(1 - k_{5}\right) & - k_{5} k_{6} & k_{6} + 1 & 0\\- k_{7} \cdot \left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) & - k_{1} k_{7} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) & - k_{2} k_{7} \cdot \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) & - k_{3} k_{7} \cdot \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) & - k_{4} k_{7} \cdot \left(1 - k_{5}\right) \left(1 - k_{6}\right) & - k_{5} k_{7} \cdot \left(1 - k_{6}\right) & - k_{6} k_{7} & k_{7} + 1\\\left(1 - k_{1}\right) \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) \left(1 - k_{7}\right) & k_{1} \cdot \left(1 - k_{2}\right) \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) \left(1 - k_{7}\right) & k_{2} \cdot \left(1 - k_{3}\right) \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) \left(1 - k_{7}\right) & k_{3} \cdot \left(1 - k_{4}\right) \left(1 - k_{5}\right) \left(1 - k_{6}\right) \left(1 - k_{7}\right) & k_{4} \cdot \left(1 - k_{5}\right) \left(1 - k_{6}\right) \left(1 - k_{7}\right) & k_{5} \cdot \left(1 - k_{6}\right) \left(1 - k_{7}\right) & k_{6} \cdot \left(1 - k_{7}\right) & k_{7}\end{matrix}\right]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N_7_latex.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N_6_latex.ok schurOneMAPlattice2Abcd_symbolic_test_N_6.latex
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_6_latex.ok"; fail; fi

diff -Bb test_N_7_latex.ok schurOneMAPlattice2Abcd_symbolic_test_N_7.latex
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_7_latex.ok"; fail; fi

#
# this much worked
#
pass
