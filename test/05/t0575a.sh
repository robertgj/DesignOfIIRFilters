#!/bin/sh

prog=schurFIRlattice2Abcd_symbolic_test.m
depends="test/schurFIRlattice2Abcd_symbolic_test.m test_common.m \
schurFIRlattice2Abcd.m Abcd2tf.m schurFIRdecomp.oct"

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
cat > test_N_10_latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_10_latex.ok.lz
TFpJUAEMACCYiGZdrDUGrkbiRSuXv7S0QZ1w8xnlxYqdE6SAvNP4WO0+BUtJ
NQGbh4AmntXZ4/bCY48i9/kZtjQCqeNU7m2lL8VSJCF99foNJckNenAL9rj2
md0bPavHOVX0fr6gatlWZwjE7gUXV2FIAlqnIxb0A6udsLGeabCF0IkJ7HuH
kdXUyvSCoCcGFcrwwsx9ftXlDOoRt94ZCy/vBqV9ehqqG+g1Lv/kMGpuqVEx
VecBdlmX143r6kDj/S9ILkIuMuImlL36lyexNJu6KwsBte330hQPVwzH//0j
lkdqbbPgVwQAAAAAAAD3AAAAAAAAAA==
====
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_10_latex.ok.lz.uue"; fail;
fi

uudecode test_N_10_latex.ok.lz.uue
if [ $? -ne 0 ]; then
    echo "Failed uudecode test_N_10_latex.ok.lz.uue"; fail;
fi

lzip -d test_N_10_latex.ok.lz
if [ $? -ne 0 ]; then
    echo "Failed lzip -d test_N_10_latex.ok.lz"; fail;
fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog #>test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N_10_latex.ok schurFIRlattice2Abcd_symbolic_test_N_10.latex
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_10_latex.ok"; fail; fi

#
# this much worked
#
pass
