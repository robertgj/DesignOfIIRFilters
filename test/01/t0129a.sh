#!/bin/sh

prog=optKW_test.m

depends="test/optKW_test.m test_common.m \
optKW.m KW.m tf2Abcd.m dlyap_levinson.m dlyap_recursive.m atog.m gtor.m"
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
K =
   1459.70   1458.64    910.40    845.81   -653.25   -679.81
   1458.64   1459.70    974.44    910.40   -623.17   -653.25
    910.40    974.44   2707.57   2704.46   1090.93    955.99
    845.81    910.40   2704.46   2707.57   1225.90   1090.93
   -653.25   -623.17   1090.93   1225.90   3992.44   3984.49
   -679.81   -653.25    955.99   1090.93   3984.49   3992.44

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
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

