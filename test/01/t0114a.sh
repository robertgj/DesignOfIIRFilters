#!/bin/sh

prog=contfrac_test.m

depends="contfrac_test.m test_common.m contfrac.m \
Abcd2tf.m tf2Abcd.m KW.m optKW.m svf.m crossWelch.m"

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
N =    5.0000e+00
fc =    5.0000e-02
Acf =

   1.1807e+00   3.0070e-01   0.0000e+00   0.0000e+00   0.0000e+00
   1.0000e+00   1.1144e-01  -7.0301e-01   0.0000e+00   0.0000e+00
   0.0000e+00   1.0000e+00   1.2927e+00   1.5201e-02   0.0000e+00
   0.0000e+00   0.0000e+00   1.0000e+00   7.3759e-01  -2.0192e-01
   0.0000e+00   0.0000e+00   0.0000e+00   1.0000e+00   1.0175e+00

Bcf =

   1.6346e-02
   0.0000e+00
   0.0000e+00
   0.0000e+00
   0.0000e+00

Ccf =

   1.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00

Dcf =    8.3022e-03
max(abs(b-bcf))=0.000000
max(abs(a-acf))=0.000000
ngcf =    1.2668e+02
ngdir =    5.8334e+05
ngoptdir =    9.2821e-01
ngopt =    9.2821e-01
est_varydcf =    4.2310e+01
varydcf =    4.6064e+01
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

