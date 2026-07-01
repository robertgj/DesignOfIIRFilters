#!/bin/sh

prog=yalmip_sdp_fir_lowpass_test.m
depends="test/yalmip_sdp_fir_lowpass_test.m test_common.m delayz.m \
print_polynomial.m directFIRnonsymmetricEsqPW.m"

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
cat > test_h1_coef.ok << 'EOF'
h1 = [  0.0017186197,  0.0051203207,  0.0064240938, -0.0001544361, ... 
       -0.0158754183, -0.0301304461, -0.0210859883,  0.0309963836, ... 
        0.1244790249,  0.2269939182,  0.2882684330,  0.2707444608, ... 
        0.1769559299,  0.0516586099, -0.0453208369, -0.0765658396, ... 
       -0.0475386375,  0.0036153158,  0.0365311906,  0.0348817165, ... 
        0.0105205653, -0.0128241981, -0.0196963953, -0.0112074267, ... 
        0.0012613328,  0.0077990092,  0.0065320337,  0.0018004218, ... 
       -0.0015986730, -0.0021197188, -0.0010572463 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h1_coef.ok"; fail; fi

cat > test_h2_coef.ok << 'EOF'
h2 = [  0.0017186170,  0.0051203124,  0.0064240835, -0.0001544358, ... 
       -0.0158753926, -0.0301303974, -0.0210859542,  0.0309963335, ... 
        0.1244788238,  0.2269935514,  0.2882679672,  0.2707440232, ... 
        0.1769556440,  0.0516585264, -0.0453207637, -0.0765657159, ... 
       -0.0475385607,  0.0036153100,  0.0365311315,  0.0348816601, ... 
        0.0105205483, -0.0128241774, -0.0196963635, -0.0112074086, ... 
        0.0012613307,  0.0077989966,  0.0065320232,  0.0018004189, ... 
       -0.0015986704, -0.0021197154, -0.0010572446 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h2_coef.ok"; fail; fi

cat > test_h3_coef.ok << 'EOF'
h3 = [  0.0017186160,  0.0051203096,  0.0064240800, -0.0001544358, ... 
       -0.0158753841, -0.0301303813, -0.0210859430,  0.0309963169, ... 
        0.1244787573,  0.2269934302,  0.2882678133,  0.2707438787, ... 
        0.1769555495,  0.0516584988, -0.0453207395, -0.0765656750, ... 
       -0.0475385353,  0.0036153081,  0.0365311120,  0.0348816415, ... 
        0.0105205427, -0.0128241706, -0.0196963529, -0.0112074026, ... 
        0.0012613301,  0.0077989925,  0.0065320197,  0.0018004180, ... 
       -0.0015986696, -0.0021197143, -0.0010572441 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h3_coef.ok"; fail; fi

cat > test_h4_coef.ok << 'EOF'
h4 = [  0.0017186132,  0.0051202745,  0.0064240509, -0.0001544044, ... 
       -0.0158752917, -0.0301303085, -0.0210859839,  0.0309961670, ... 
        0.1244786388,  0.2269935144,  0.2882681345,  0.2707442669, ... 
        0.1769557501,  0.0516583872, -0.0453210439, -0.0765659079, ... 
       -0.0475385120,  0.0036155451,  0.0365313502,  0.0348816941, ... 
        0.0105203996, -0.0128243623, -0.0196964366, -0.0112073404, ... 
        0.0012614532,  0.0077990666,  0.0065320037,  0.0018003526, ... 
       -0.0015987190, -0.0021197166, -0.0010572144 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h4_coef.ok"; fail; fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h1_coef.ok yalmip_sdp_fir_lowpass_test_h1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h1_coef.ok"; fail; fi

diff -Bb test_h2_coef.ok yalmip_sdp_fir_lowpass_test_h2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h2_coef.ok"; fail; fi

diff -Bb test_h3_coef.ok yalmip_sdp_fir_lowpass_test_h3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h3_coef.ok"; fail; fi

diff -Bb test_h4_coef.ok yalmip_sdp_fir_lowpass_test_h4_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h4_coef.ok"; fail; fi

#
# this much worked
#
pass

