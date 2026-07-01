#!/bin/sh

prog=yalmip_kyp_test.m
depends="test/yalmip_kyp_test.m test_common.m delayz.m print_polynomial.m \
directFIRnonsymmetricEsqPW.m"

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
h = [  0.0017186197,  0.0051203207,  0.0064240938, -0.0001544361, ... 
      -0.0158754183, -0.0301304461, -0.0210859883,  0.0309963836, ... 
       0.1244790249,  0.2269939182,  0.2882684330,  0.2707444608, ... 
       0.1769559299,  0.0516586099, -0.0453208369, -0.0765658396, ... 
      -0.0475386375,  0.0036153158,  0.0365311906,  0.0348817165, ... 
       0.0105205653, -0.0128241981, -0.0196963953, -0.0112074267, ... 
       0.0012613328,  0.0077990092,  0.0065320337,  0.0018004218, ... 
      -0.0015986730, -0.0021197188, -0.0010572463 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

cat > test_h_amp_coef.ok << 'EOF'
h_amp = [  0.0009587443,  0.0006645823, -0.0018183644, -0.0052208067, ... 
          -0.0051578986,  0.0021372561,  0.0137877324,  0.0186258106, ... 
           0.0050657513, -0.0251622370, -0.0497618114, -0.0359263161, ... 
           0.0351641750,  0.1473722227,  0.2516516436,  0.2941640417, ... 
           0.2516516436,  0.1473722227,  0.0351641750, -0.0359263161, ... 
          -0.0497618114, -0.0251622370,  0.0050657513,  0.0186258106, ... 
           0.0137877324,  0.0021372561, -0.0051578986, -0.0052208067, ... 
          -0.0018183644,  0.0006645823,  0.0009587443 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_amp_coef.ok"; fail; fi

cat > test_h_kyp_coef.ok << 'EOF'
h_kyp = [  0.0021499249,  0.0055563954,  0.0065803024, -0.0004075084, ... 
          -0.0163148317, -0.0303868475, -0.0210328597,  0.0311203001, ... 
           0.1243869360,  0.2267826289,  0.2884055109,  0.2714889068, ... 
           0.1778586155,  0.0518082151, -0.0463827065, -0.0781997985, ... 
          -0.0484052949,  0.0043783031,  0.0384424040,  0.0364489025, ... 
           0.0105233686, -0.0142992186, -0.0214119018, -0.0119004210, ... 
           0.0018793823,  0.0090088283,  0.0073926885,  0.0019180282, ... 
          -0.0019606049, -0.0024908362, -0.0012348847 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_kyp_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok yalmip_kyp_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

diff -Bb test_h_amp_coef.ok yalmip_kyp_test_h_amp_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_amp_coef.ok"; fail; fi

diff -Bb test_h_kyp_coef.ok yalmip_kyp_test_h_kyp_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_kyp_coef.ok"; fail; fi

#
# this much worked
#
pass

