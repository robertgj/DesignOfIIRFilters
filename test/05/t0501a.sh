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
h = [  0.0017186160,  0.0051203094,  0.0064240797, -0.0001544358, ... 
      -0.0158753834, -0.0301303800, -0.0210859420,  0.0309963155, ... 
       0.1244787517,  0.2269934200,  0.2882678003,  0.2707438665, ... 
       0.1769555415,  0.0516584965, -0.0453207374, -0.0765656716, ... 
      -0.0475385332,  0.0036153079,  0.0365311104,  0.0348816399, ... 
       0.0105205422, -0.0128241700, -0.0196963521, -0.0112074021, ... 
       0.0012613300,  0.0077989921,  0.0065320194,  0.0018004179, ... 
      -0.0015986695, -0.0021197142, -0.0010572440 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

cat > test_h_amp_coef.ok << 'EOF'
h_amp = [  0.0009587443,  0.0006645823, -0.0018183644, -0.0052208067, ... 
          -0.0051578986,  0.0021372561,  0.0137877323,  0.0186258107, ... 
           0.0050657514, -0.0251622370, -0.0497618114, -0.0359263161, ... 
           0.0351641749,  0.1473722227,  0.2516516437,  0.2941640418, ... 
           0.2516516437,  0.1473722227,  0.0351641749, -0.0359263161, ... 
          -0.0497618114, -0.0251622370,  0.0050657514,  0.0186258107, ... 
           0.0137877323,  0.0021372561, -0.0051578986, -0.0052208067, ... 
          -0.0018183644,  0.0006645823,  0.0009587443 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_amp_coef.ok"; fail; fi

cat > test_h_kyp_coef.ok << 'EOF'
h_kyp = [  0.0021782015,  0.0055609196,  0.0065083474, -0.0005697399, ... 
          -0.0164843283, -0.0304201829, -0.0208493486,  0.0314241961, ... 
           0.1245633644,  0.2266376619,  0.2879828858,  0.2710863908, ... 
           0.1778041703,  0.0521778976, -0.0458667823, -0.0779430625, ... 
          -0.0486086401,  0.0038863047,  0.0380560005,  0.0364521949, ... 
           0.0108714113, -0.0139066968, -0.0212618153, -0.0120501809, ... 
           0.0015993552,  0.0088210910,  0.0073990865,  0.0020640253, ... 
          -0.0017944949, -0.0023842313, -0.0011926486 ];
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

