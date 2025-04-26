#!/bin/sh

prog=sparsePOP_test.m

depends="test/sparsePOP_test.m test_common.m"
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
cat > test_xVect.ok << 'EOF'

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
SDPobjValue= -2.854993
POP.xVect=
  -0.025252 
  -0.173893 
   0.075626 
   0.047586 
   0.046613 
   0.046926 
   0.047101 
   0.047189 
   0.047233 
   0.047255 
   0.047266 
   0.047271 
   0.047274 
   0.047275 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047276 
   0.047272 
   0.047080 

Solving randomwithEQ(20,2,4,4,3201):
SDPsolverInfo.numerr=0
SDPobjValue=  0.718289
POP.xVect=
   0.008879 
   0.050363 
   0.025689 
   0.085327 
  -0.100238 
  -0.069824 
   0.099877 
   0.016236 
   0.080272 
   0.095662 
   0.058105 
  -0.010477 
   0.106721 
   0.006378 
   0.028122 
  -0.046889 
   0.078673 
  -0.005209 
   0.024379 
  -0.065242 

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
SDPobjValue= -2.854993
POP.xVect=
  -0.025257 
  -0.173892 
   0.075629 
   0.047590 
   0.046617 
   0.046931 
   0.047106 
   0.047193 
   0.047237 
   0.047259 
   0.047270 
   0.047275 
   0.047278 
   0.047279 
   0.047280 
   0.047280 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047281 
   0.047277 
   0.047084 

Solving randomwithEQ(20,2,4,4,3201):
SDPsolverInfo.termcode=0
SDPobjValue=  0.718289
POP.xVect=
   0.008879 
   0.050364 
   0.025689 
   0.085328 
  -0.100238 
  -0.069825 
   0.099876 
   0.016236 
   0.080274 
   0.095660 
   0.058105 
  -0.010476 
   0.106721 
   0.006379 
   0.028122 
  -0.046889 
   0.078672 
  -0.005209 
   0.024380 
  -0.065243 

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
  66.666667 
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
if [ $? -ne 0 ]; then echo "Failed output cat test_xVect.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_xVect.ok sparsePOP_test_xVect.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test_xVect.ok"; fail; fi

#
# this much worked
#
pass
