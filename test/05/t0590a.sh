#!/bin/sh

prog=schurNSPAlattice_socp_mmse_test.m

depends="test/schurNSPAlattice_socp_mmse_test.m test_common.m \
schurNSPAlattice_socp_mmse.m tf2schurNSlattice.m \
schurNSPAlattice_slb_show_constraints.m \
schurNSPAlatticeEsq.m schurNSPAlatticeAsq.m schurNSPAlatticeP.m \
schurNSPAlatticeT.m schurNSAPlattice2Abcd.m H2Asq.m H2P.m H2T.m \
schurNSPAlattice_slb_set_empty_constraints.m print_polynomial.m \
schurdecomp.oct schurexpand.oct schurNSscale.oct schurNSlattice2Abcd.oct \
Abcd2H.oct"

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
cat > test_A1s20_1.ok << 'EOF'
A1s20_1 = [  -0.4211736271,   0.5668175949,   0.5270040142,  -0.5461931018, ... 
              0.6550530930,  -0.2373180660,  -0.1084214338,   0.3962189226, ... 
             -0.2633216807,   0.1290400036 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s20_1.ok"; fail; fi

cat > test_A1s00_1.ok << 'EOF'
A1s00_1 = [   0.9084068159,   0.8252132199,   0.8517229975,   0.8404082640, ... 
              0.7590176044,   0.9736149893,   0.9921875000,   0.9172621108, ... 
              0.9652192692,   0.9921875000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s00_1.ok"; fail; fi

cat > test_A2s20_1.ok << 'EOF'
A2s20_1 = [  -0.7587537631,   0.6911203023,   0.5193006191,  -0.5950226421, ... 
              0.6777168703,  -0.1762382584,  -0.0940535856,   0.3878630497, ... 
             -0.2548103025,   0.1428570801 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s20_1.ok"; fail; fi

cat > test_A2s00_1.ok << 'EOF'
A2s00_1 = [   0.6520216724,   0.7230685714,   0.8565448384,   0.8038448364, ... 
              0.7388111211,   0.9865658920,   0.9918047788,   0.9202904316, ... 
              0.9668768696,   0.9905911598 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s00_1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_A1s20_1.ok schurNSPAlattice_socp_mmse_test_A1s20_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s20_1.ok"; fail; fi

diff -Bb test_A1s00_1.ok schurNSPAlattice_socp_mmse_test_A1s00_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s00_1.ok"; fail; fi

diff -Bb test_A2s20_1.ok schurNSPAlattice_socp_mmse_test_A2s20_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s20_1.ok"; fail; fi

diff -Bb test_A2s00_1.ok schurNSPAlattice_socp_mmse_test_A2s00_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s00_1.ok"; fail; fi


#
# this much worked
#
pass
