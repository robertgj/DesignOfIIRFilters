#!/bin/sh

prog=sparsePOP_test.m

depends="sparsePOP_test.m test_common.m SeDuMi_1_3/ SDPT3/ SparsePOP303/"
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

Using sedumi

Solving example1:
SDPsolverInfo.numerr=0
SDPobjValue=-10.000000
POP.xVect=
   1.500000 
   0.000000 
   3.500000 

Solving Rosenbrock(40,-1):
SDPsolverInfo.numerr=0
SDPobjValue=  1.000008
POP.xVect=
  -0.999999 
   0.999992 
   0.999992 
   0.999992 
   0.999992 
   0.999992 
   0.999991 
   0.999991 
   0.999992 
   0.999994 
   0.999995 
   0.999996 
   0.999996 
   0.999996 
   0.999996 
   0.999996 
   0.999995 
   0.999996 
   0.999996 
   0.999997 
   0.999998 
   0.999999 
   1.000000 
   1.000000 
   1.000001 
   1.000001 
   1.000000 
   1.000000 
   1.000000 
   0.999999 
   0.999998 
   0.999997 
   0.999996 
   0.999994 
   0.999990 
   0.999984 
   0.999974 
   0.999952 
   0.999908 
   0.999816 

Solving randomwithEQ(20,2,4,4,3201):
SDPsolverInfo.numerr=0
SDPobjValue=  0.529295
POP.xVect=
  -0.003067 
   0.045636 
   0.026882 
   0.080684 
  -0.086197 
  -0.064400 
   0.098897 
   0.019033 
   0.083895 
   0.081158 
   0.061833 
   0.000530 
   0.086815 
   0.013704 
   0.028475 
  -0.052271 
   0.075714 
  -0.000395 
   0.020642 
  -0.070408 

Solving genMAXCUT(8,1):
SDPsolverInfo.numerr=0
SDPobjValue=-9184.000000
POP.xVect=
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 

Solving Bex5_2_5.gms:
SDPsolverInfo.numerr=0
SDPobjValue=-9700.000003
POP.xVect=
   0.251296 
   0.251296 
   0.251296 
   0.249243 
   0.249243 
   0.249243 
   0.249476 
   0.249476 
   0.249476 
   0.249985 
   0.249985 
   0.249985 
   0.000000 
  -0.000000 
   0.000000 
   0.000000 
   0.000000 
  33.333350 
  66.666629 
  33.333349 
  33.333352 
  33.333356 
  33.333325 
  66.666685 
  33.333326 
  33.333324 
  33.333322 
  33.333325 
  66.666686 
  33.333326 
  33.333324 
  33.333322 

Using sdpt3

Solving example1:
SDPsolverInfo.termcode=0
SDPobjValue=-10.000000
POP.xVect=
   1.500000 
   0.000000 
   3.500000 

Solving Rosenbrock(40,-1):
SDPsolverInfo.termcode=0
SDPobjValue=  1.000000
POP.xVect=
  -1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000000 
   1.000001 
   1.000001 
   1.000002 
   1.000004 
   1.000009 

Solving randomwithEQ(20,2,4,4,3201):
SDPsolverInfo.termcode=0
SDPobjValue=  0.529295
POP.xVect=
  -0.003068 
   0.045636 
   0.026882 
   0.080685 
  -0.086198 
  -0.064400 
   0.098896 
   0.019034 
   0.083897 
   0.081155 
   0.061834 
   0.000531 
   0.086816 
   0.013705 
   0.028475 
  -0.052272 
   0.075713 
  -0.000396 
   0.020643 
  -0.070409 

Solving genMAXCUT(8,1):
SDPsolverInfo.termcode=0
SDPobjValue=-9184.000006
POP.xVect=
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 
  -1.000000 

Solving Bex5_2_5.gms:
SDPsolverInfo.termcode=0
SDPobjValue=-9700.000006
POP.xVect=
   0.250977 
   0.250977 
   0.250977 
   0.249830 
   0.249830 
   0.249830 
   0.249030 
   0.249030 
   0.249030 
   0.250163 
   0.250163 
   0.250163 
   0.000000 
   0.000000 
   0.000000 
   0.000000 
   0.000000 
  33.333333 
  66.666666 
  33.333333 
  33.333333 
  33.333333 
  33.333333 
  66.666667 
  33.333333 
  33.333333 
  33.333333 
  33.333333 
  66.666667 
  33.333333 
  33.333333 
  33.333333 
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok sparsePOP_test_xVect.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.ok"; fail; fi

#
# this much worked
#
pass
