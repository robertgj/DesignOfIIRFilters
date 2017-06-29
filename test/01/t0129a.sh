#!/bin/sh

prog=optKW_test.m

depends="optKW_test.m test_common.m \
optKW.m KW.m tf2Abcd.m dlyap_levinson.m dlyap_recursive.m atog.m gtor.m"
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
K =

   1.4597e+03   1.4586e+03   9.1040e+02   8.4581e+02  -6.5325e+02  -6.7981e+02
   1.4586e+03   1.4597e+03   9.7444e+02   9.1040e+02  -6.2317e+02  -6.5325e+02
   9.1040e+02   9.7444e+02   2.7076e+03   2.7045e+03   1.0909e+03   9.5599e+02
   8.4581e+02   9.1040e+02   2.7045e+03   2.7076e+03   1.2259e+03   1.0909e+03
  -6.5325e+02  -6.2317e+02   1.0909e+03   1.2259e+03   3.9924e+03   3.9845e+03
  -6.7981e+02  -6.5325e+02   9.5599e+02   1.0909e+03   3.9845e+03   3.9924e+03

W =

   1.2778e-02  -1.4400e-02   7.6067e-03  -8.5859e-03   4.6600e-03  -5.0323e-03
  -1.4400e-02   1.6292e-02  -8.3088e-03   9.3885e-03  -5.0311e-03   5.4360e-03
   7.6067e-03  -8.3088e-03   1.0743e-02  -1.1736e-02   1.1395e-02  -1.1988e-02
  -8.5859e-03   9.3885e-03  -1.1736e-02   1.2834e-02  -1.2217e-02   1.2866e-02
   4.6600e-03  -5.0311e-03   1.1395e-02  -1.2217e-02   1.8994e-02  -1.9607e-02
  -5.0323e-03   5.4360e-03  -1.1988e-02   1.2866e-02  -1.9607e-02   2.0270e-02

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

