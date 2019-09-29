#!/bin/sh

prog=schur_retimed_test.m

depends="schur_retimed_test.m test_common.m \
schurdecomp.oct schurNSscale.oct schurexpand.oct \
tf2Abcd.m Abcd2tf.m WISEJ.m tf2schurNSlattice.m KW.m svf.m crossWelch.m"
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
   0.732703   0.330433   0.231529   0.078416

s11 =
   0.68055   0.94383   0.97283   0.35139

s20 =
   0.00000  -0.78817   0.00000   0.48629

s00 =
   1.00000   0.61545   1.00000   0.87379

s02 =
  -0.00000   0.78817  -0.00000  -0.48629

s22 =
   1.00000   0.61545   1.00000   0.87379

sn =
 Columns 1 through 7:
   0.000000   0.000000   0.078416   0.071090   0.006841   0.071101   0.078422
 Columns 8 through 12:
  -0.000000  -0.000000  -0.000000  -0.000000  -0.000000

sdR =
 Columns 1 through 8:
   1.00000  -0.00000  -1.17146  -0.00000   0.48629  -0.00000  -0.00000  -0.00000
 Columns 9 through 12:
  -0.00000  -0.00000  -0.00000  -0.00000

max(abs(sn(3:7)-n'))=0.000000
max(abs(sdR(1:5)-dR'))=0.000000
ngABCD =  0.70885
ngABCDap =  3.0000
est_varyd =  0.14240
varyd =  0.14265
est_varydap =  0.33333
varydap =  0.33004
stdxx =
 Columns 1 through 8:
   129.42   130.39   129.43   128.28   128.28   130.50   128.27   130.63
 Columns 9 through 11:
   128.28   128.00   128.00

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

