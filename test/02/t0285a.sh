#!/bin/sh

prog=schurOneMPAlatticeP_test.m

depends="schurOneMPAlatticeP_test.m test_common.m schurOneMPAlatticeP.m \
tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m schurOneMlattice2Abcd.oct \
H2P.m schurOneMAPlattice2H.oct tf2pa.m schurOneMscale.m \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct"

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
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress grpdelay() warnings.
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog >/dev/null 2>test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
