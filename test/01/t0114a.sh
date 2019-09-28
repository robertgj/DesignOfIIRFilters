#!/bin/sh

prog=contfrac_test.m

depends="contfrac_test.m test_common.m contfrac.m \
Abcd2tf.m tf2Abcd.m KW.m optKW.m svf.m crossWelch.m"

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
N =  5
fc =  0.050000
Acf =
   1.18075   0.30070   0.00000   0.00000   0.00000
   1.00000   0.11142  -0.70303   0.00000   0.00000
   0.00000   1.00000   1.29267   0.01520   0.00000
   0.00000   0.00000   1.00000   0.73758  -0.20193
   0.00000   0.00000   0.00000   1.00000   1.01748

Bcf =
   0.016346
   0.000000
   0.000000
   0.000000
   0.000000

Ccf =
   1   0   0   0   0

Dcf =  0.0083020
max(abs(b-bcf))=0.000000
max(abs(a-acf))=0.000000
ngcf =  126.69
ngdir =  583337.81582
ngoptdir =  0.92821
ngopt =  0.92821
est_varydcf =  42.312
varydcf =  45.528
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

