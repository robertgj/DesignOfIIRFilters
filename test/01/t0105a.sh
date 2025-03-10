#!/bin/sh

prog=schur_pipelined_test.m

depends="test/schur_pipelined_test.m test_common.m \
schurdecomp.oct schurNSscale.oct schurexpand.oct \
tf2Abcd.m Abcd2tf.m WISEJ.m tf2schurNSlattice.m KW.m svf.m crossWelch.m \
p2n60.m qroots.oct"

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
s10 =
   0.732702   0.330469   0.231570   0.078429

s11 =
   0.6805   0.9438   0.9728   0.3514

s20 =
        0  -0.7882        0   0.4863

s00 =
   1.0000   0.6155   1.0000   0.8738

s02 =
        0   0.7882        0  -0.4863

s22 =
   1.0000   0.6155   1.0000   0.8738

sn =
 Columns 1 through 7:
          0          0   0.078429   0.071103   0.006836   0.071089   0.078420
 Columns 8 through 12:
          0          0          0          0          0

sdR =
 Columns 1 through 8:
   1.0000        0  -1.1714        0   0.4863        0        0        0
 Columns 9 through 12:
        0        0        0        0

max(abs(sn(3:7)-n'))=0.000000
max(abs(sdR(1:5)-dR'))=0.000000
ngABCD = 0.7088
ngABCDap = 3.0000
est_varyd = 0.1424
varyd = 0.1424
est_varydap = 0.3333
varydap = 0.3300
stdxxABCD =
 Columns 1 through 8:
   129.45   130.32   129.44   128.27   128.27   130.43   128.29   130.56
 Columns 9 through 11:
   128.27   128.01   128.00

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

