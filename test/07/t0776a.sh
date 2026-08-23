#!/bin/sh

prog=yalmip_kyp_dual_bandpass_test.m
depends="test/yalmip_kyp_dual_bandpass_test.m test_common.m Abcd2H.oct"

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

value(Esq_p)=0.425665,Asq_max_p=1.42568


value(Esq_pz)=0.0376366,Esq_max_pz=0.0376424

YALMIP failed for pass-band maximum response : Infeasible problem (<a href="yalmip.github.io/debugginginfeasible">learn to debug</a>) (SeDuMi)
YALMIP failed for pass-band maximum response error : Infeasible problem (<a href="yalmip.github.io/debugginginfeasible">learn to debug</a>) (SeDuMi)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok yalmip_kyp_dual_bandpass_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

