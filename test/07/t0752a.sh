#!/bin/sh

prog=state_variable_serial_noise_gain_test.m
depends="test/state_variable_serial_noise_gain_test.m test_common.m \
tf2schurOneMlattice.m schurOneMscale.m KW.m p2n60.m svf.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct Abcd2tf.oct \
reprand.oct qroots.oct"

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
cat > test.ok.1 << 'EOF'
NN=1 : Overall scaled ng12=0.173, ngs=0.177, est_vary12=0.141, est_varysd=0.142, varysd=0.142
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.1"; fail; fi

cat > test.ok.2 << 'EOF'
NN=2 : Overall scaled ng12=0.807, ngs=0.828, est_vary12=0.352, est_varysd=0.359, varysd=0.359
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.2"; fail; fi

cat > test.ok.3 << 'EOF'
NN=3 : Overall scaled ng12=1.434, ngs=1.427, est_vary12=0.561, est_varysd=0.559, varysd=0.570
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.3"; fail; fi

cat > test.ok.4 << 'EOF'
NN=4 : Overall scaled ng12=1.873, ngs=1.857, est_vary12=0.708, est_varysd=0.702, varysd=0.709
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.4"; fail; fi

cat > test.ok.5 << 'EOF'
NN=5 : Overall scaled ng12=2.436, ngs=2.367, est_vary12=0.895, est_varysd=0.872, varysd=0.879
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.5"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr="state_variable_serial_noise_gain_test"

octave --no-gui -q $prog #>test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

for k in {1..5};do
    diff -Bb test.ok.$k $nstr"_NN_"$k".txt"
    if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok."$k; fail; fi
done

#
# this much worked
#
pass

