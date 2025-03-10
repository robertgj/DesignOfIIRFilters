#!/bin/sh

prog=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq_test.m

depends="test/schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq_test.m \
test_common.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedT.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedP.m \
schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw.m \
schurOneMPAlatticeDoublyPipelinedAsq.m \
schurOneMPAlatticeDoublyPipelinedT.m \
schurOneMPAlatticeDoublyPipelinedP.m \
schurOneMPAlatticeDoublyPipelineddAsqdw.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticedAsqdw.m \
schurOneMlatticeDoublyPipelined2Abcd.m \
schurOneMAPlatticeDoublyPipelined2Abcd.m \
schurOneMAPlattice2Abcd.m \
schurOneMAPlatticeDoublyPipelined2H.m \
H2Asq.m H2T.m H2P.m H2dAsqdw.m phi2p.m tfp2g.m \
tf2schurOneMlattice.m schurOneMscale.m tf2pa.m qroots.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct complex_zhong_inverse.oct \
Abcd2H.oct schurdecomp.oct schurexpand.oct spectralfactor.oct"

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

