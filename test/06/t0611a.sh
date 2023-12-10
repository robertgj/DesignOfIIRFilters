#!/bin/sh

prog=yalmip_kyp_lowpass_Esq_s_test.m
depends="test/yalmip_kyp_lowpass_Esq_s_test.m test_common.m \
delayz.m print_polynomial.m"

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
cat > test_d_10.ok << 'EOF'
h10 = [  0.0015222430,  0.0056117156,  0.0079483379,  0.0024441377, ... 
        -0.0135896374, -0.0303616957, -0.0247709679,  0.0258232434, ... 
         0.1218930213,  0.2299756738,  0.2956218386,  0.2771913341, ... 
         0.1770637235,  0.0445647549, -0.0546123522, -0.0809174901, ... 
        -0.0435116704,  0.0128673306,  0.0438842997,  0.0350849619, ... 
         0.0041984139, -0.0202401305, -0.0227639377, -0.0086322884, ... 
         0.0064031498,  0.0113093087,  0.0065048787, -0.0006480780, ... 
        -0.0042536892, -0.0037733719, -0.0015054268 ];
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_3.ok"; fail;
fi

cat > test_d_12.ok << 'EOF'
h12 = [ -0.0024788532, -0.0031425869,  0.0004066940,  0.0084149440, ... 
         0.0140523817,  0.0068138813, -0.0160400622, -0.0392076571, ... 
        -0.0328601660,  0.0268450153,  0.1335051302,  0.2439481858, ... 
         0.3002576337,  0.2678435305,  0.1611544743,  0.0357535410, ... 
        -0.0483580330, -0.0644608514, -0.0302347693,  0.0128294215, ... 
         0.0320531356,  0.0224194493,  0.0010199834, -0.0126250065, ... 
        -0.0117392158, -0.0027790651,  0.0044318624,  0.0055940718, ... 
         0.0029362507,  0.0003506061, -0.0008668166 ];
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_5.ok"; fail;
fi

cat > test_d_15.ok << 'EOF'
h15 = [  0.0013068480,  0.0005795887, -0.0025436090, -0.0070309300, ... 
        -0.0078971964, -0.0003519900,  0.0130394812,  0.0200655926, ... 
         0.0073572487, -0.0243980676, -0.0521193049, -0.0407477790, ... 
         0.0305643519,  0.1457747338,  0.2537463824,  0.2979056990, ... 
         0.2537463824,  0.1457747338,  0.0305643519, -0.0407477790, ... 
        -0.0521193049, -0.0243980676,  0.0073572487,  0.0200655926, ... 
         0.0130394812, -0.0003519900, -0.0078971964, -0.0070309300, ... 
        -0.0025436090,  0.0005795887,  0.0013068480 ];
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_7.ok"; fail;
fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="yalmip_kyp_lowpass_Esq_s_test"

diff -Bb test_d_10.ok $nstr"_d_10_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_10.ok"; fail; fi

diff -Bb test_d_12.ok $nstr"_d_12_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_12.ok"; fail; fi

diff -Bb test_d_15.ok $nstr"_d_15_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_15.ok"; fail; fi

#
# this much worked
#
pass
