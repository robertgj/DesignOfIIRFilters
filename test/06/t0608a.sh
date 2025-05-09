#!/bin/sh

prog=yalmip_kyp_check_iir_bandpass_test.m
depends="test/yalmip_kyp_check_iir_bandpass_test.m test_common.m qroots.oct \
tf2Abcd.m Abcd2tf.m tf2pa.m tf2schurOneMlattice.m schurOneMscale.m \
schurOneMAPlattice2Abcd.m \
schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct \
spectralfactor.oct"

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
isdefinite() finds -F_slu<0 but min. eigenvalue >= -sedumi_eps
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test.ok"; fail;
fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok yalmip_kyp_check_iir_bandpass_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
