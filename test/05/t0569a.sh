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
cat > test_N_6.latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_6.latex.ok.lz
TFpJUAEMACCYiGZdrDUGrkbiRSuXv7S0QZ103QEUHvO5SVETZST+wWHgYSXh
SMDNgE10tThPw/Elgm+q/xJ4DshxOOf9UqYC5HKTbJdDQUq/a8qw6drgAFIc
5PnpZyvgh9ZhgVGn2WAgy2sPZPDdMd426xfb/lVEa/2Cl0YuvUm70+5+rq7u
rc7OuQZB4j2Ib9J3PKf9k2JLg81+EOiJwJDFDwA4vsfZUG+U1nQJN1HapQqQ
fo5AnTg/Z6eaZDYWICzIbCvAhSMONJcA5B1ZZWOzG/sgqeI1PydyH7/teegv
HAM+RTqdHubJgBrbTWP//+2TUJRElJ54DgcAAAAAAAAJAQAAAAAAAA==
====
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N_6.latex.ok.lz.uue"; fail; fi

cat > test_N_7.latex.ok.lz.uue << 'EOF'
begin-base64 644 test_N_7.latex.ok.lz
TFpJUAEMACCYiGZdrDUGrkbiRSuXv7S0QZ103QEUHvO5SVETZST+wWHgYSXh
SMDNgE14XnxrRWRy6wWYvtXn7Ie6z6woI5OOmmsRpVKtm/wFsbZRS/tfp+Jp
Mer4s1yWPcDhdMD/GmbJQy0jrYNnA06AG0dkebGug/URs1oNyfaYnmtU/lmf
KuQgvbmx8P0Za8N7HGqmd2dE/Ehjve2zai1tusApARrFpUl9D/YTyL+BAGf7
PzTyq8srzOkR7M4oISQ0EfeMX7KT6IZusGv+HgJMRc7A1ykMRbJAc0tDxIFs
WNS9Zxoy4QT66Aj/nm6X2EapKtXKZdg9ajoZpNaBsvaHTA+SpSQjXPs8fRhR
iXxaUHnGHKYXz3bF/Ov//++ie43ZONXDJwoAAAAAAAA2AQAAAAAAAA==
====
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N_7.latex.ok.lz.uue"; fail; fi

for n in 6 7;
do 
    uudecode test_N_$n".latex.ok.lz.uue"
    if [ $? -ne 0 ]; then
        echo "Failed uudecode test_N_"$n".latex.ok.lz.uue"; fail;
    fi
    lzip -d test_N_$n".latex.ok.lz"
    if [ $? -ne 0 ]; then
        echo "Failed lzip -d test_N_"$n".latex.ok.lz"; fail;
    fi
done

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N_6.latex.ok schurOneMAPlattice2Abcd_symbolic_test_N_6.latex
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_6.latex.ok"; fail; fi

diff -Bb test_N_7.latex.ok schurOneMAPlattice2Abcd_symbolic_test_N_7.latex
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N_7.latex.ok"; fail; fi

#
# this much worked
#
pass
