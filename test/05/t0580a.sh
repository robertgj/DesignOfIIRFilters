#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_double_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_double_bandpass_test.m \
test_common.m delayz.m print_polynomial.m"

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
cat > test_h_coef.ok << 'EOF'
h = [  0.0032501884, -0.0007936457, -0.0041045168, -0.0026997196, ... 
      -0.0154714136,  0.0202497922,  0.0147688387, -0.0067943010, ... 
       0.0031296793, -0.0122876386,  0.0000477430, -0.0283115082, ... 
       0.0064615521, -0.0303326963,  0.0765435947,  0.1486104607, ... 
      -0.1683878086, -0.0413993782, -0.1066303222, -0.0479073232, ... 
       0.3926121574, -0.0501002321, -0.1105892879, -0.0495211545, ... 
      -0.2077743526,  0.1909920648,  0.1039200424, -0.0491632718, ... 
       0.0082466657, -0.0361261230, -0.0002707804, -0.0211346986, ... 
       0.0049666839, -0.0188377012,  0.0333928378,  0.0485841955, ... 
      -0.0410966131, -0.0083123854, -0.0036680139, -0.0018974992, ... 
       0.0025812561,  0.0008227982,  0.0030572237,  0.0021659048, ... 
       0.0112292005, -0.0115856155, -0.0072562105,  0.0052998882, ... 
      -0.0000823400 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok \
         directFIRnonsymmetric_kyp_union_double_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

