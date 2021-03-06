#!/bin/sh

prog=yalmip_kyp_test.m
depends="yalmip_kyp_test.m test_common.m print_polynomial.m \
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
h_kyp = [  0.0000831948,  0.0040058678,  0.0072893390,  0.0033064657, ... 
          -0.0118638668, -0.0294429120, -0.0259111272,  0.0232515335, ... 
           0.1201639016,  0.2309596958,  0.2987519037,  0.2796915681, ... 
           0.1764917820,  0.0412891308, -0.0575983277, -0.0807977293, ... 
          -0.0403926640,  0.0160590769,  0.0442274758,  0.0324005088, ... 
           0.0010618866, -0.0210778191, -0.0208973206, -0.0060680627, ... 
           0.0074176163,  0.0103218501,  0.0048695594, -0.0013432782, ... 
          -0.0034846588, -0.0021059978,  0.0000097034 ];
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

