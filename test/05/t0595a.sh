#!/bin/sh

prog=qp_bandpass_test.m
depends="test/qp_bandpass_test.m test_common.m directFIRnonsymmetricEsqPW.m \
directFIRsymmetricEsqPW.m mcclellanFIRsymmetric.m local_max.m \
delayz.m print_polynomial.m lagrange_interp.m xfr2tf.m directFIRsymmetricA.m"

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
cat > test_h_coef.m << 'EOF'
h = [  0.0002797241,  0.0001966438, -0.0051184756, -0.0030507204, ... 
       0.0083029621,  0.0076040731, -0.0077933238, -0.0105252893, ... 
       0.0040038965,  0.0084319756, -0.0004031126, -0.0008016642, ... 
       0.0013917439, -0.0087819939, -0.0087382797,  0.0146288936, ... 
       0.0195230614, -0.0129992630, -0.0275728720,  0.0050897229, ... 
       0.0274947892,  0.0033885054, -0.0183007132, -0.0056051631, ... 
       0.0041463802, -0.0025960747,  0.0078430098,  0.0208185918, ... 
      -0.0107607236, -0.0445158874,  0.0003395738,  0.0665912752, ... 
       0.0237907098, -0.0792893120, -0.0576197783,  0.0763654383, ... 
       0.0931380177, -0.0555534438, -0.1202732967,  0.0203599593, ... 
       0.1304482334,  0.0203599593, -0.1202732967, -0.0555534438, ... 
       0.0931380177,  0.0763654383, -0.0576197783, -0.0792893120, ... 
       0.0237907098,  0.0665912752,  0.0003395738, -0.0445158874, ... 
      -0.0107607236,  0.0208185918,  0.0078430098, -0.0025960747, ... 
       0.0041463802, -0.0056051631, -0.0183007132,  0.0033885054, ... 
       0.0274947892,  0.0050897229, -0.0275728720, -0.0129992630, ... 
       0.0195230614,  0.0146288936, -0.0087382797, -0.0087819939, ... 
       0.0013917439, -0.0008016642, -0.0004031126,  0.0084319756, ... 
       0.0040038965, -0.0105252893, -0.0077933238,  0.0076040731, ... 
       0.0083029621, -0.0030507204, -0.0051184756,  0.0001966438, ... 
       0.0002797241 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m"; fail; fi

cat > test_hPM_coef.m << 'EOF'
hPM = [ -0.0002591487, -0.0000677819,  0.0006672837,  0.0004486165, ... 
        -0.0009499685, -0.0009449698,  0.0007797988,  0.0009812455, ... 
        -0.0001706585,  0.0002696197,  0.0000105558, -0.0028007959, ... 
        -0.0013721390,  0.0052738461,  0.0042484613, -0.0055991453, ... 
        -0.0064093894,  0.0031041926,  0.0044131281, -0.0001839318, ... 
         0.0034185384,  0.0014126970, -0.0140704984, -0.0093663390, ... 
         0.0205433660,  0.0202402741, -0.0171404788, -0.0237006715, ... 
         0.0061908437,  0.0092929371, -0.0000064366,  0.0241280733, ... 
         0.0144454529, -0.0633874581, -0.0569221215,  0.0862313026, ... 
         0.1176241929, -0.0750230244, -0.1718287995,  0.0297516702, ... 
         0.1935760345 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hPM_coef.m"; fail; fi

cat > test_hd_coef.m << 'EOF'
hd = [  0.0209959120,  0.0029710155, -0.0258403597, -0.0111816405, ... 
        0.0203805829,  0.0124262243, -0.0068877978,  0.0015174193, ... 
       -0.0040679303, -0.0304439926,  0.0000783024,  0.0635196927, ... 
        0.0240897613, -0.0851327111, -0.0623303419,  0.0843002153, ... 
        0.1010009434, -0.0603564749, -0.1269646353,  0.0215676781, ... 
        0.1334495245,  0.0205034096, -0.1206837022, -0.0557658519, ... 
        0.0933574828,  0.0772722421, -0.0584543557, -0.0814151352, ... 
        0.0243630121,  0.0687293235,  0.0004911822, -0.0447826868, ... 
       -0.0106095483,  0.0189235730,  0.0062912357, -0.0002629860, ... 
        0.0064003976, -0.0066786209, -0.0191758963,  0.0034208486, ... 
        0.0260038145,  0.0047120561, -0.0253280145, -0.0122459823, ... 
        0.0191664674,  0.0158348959, -0.0108754876, -0.0144322156, ... 
        0.0036417374,  0.0086484680, -0.0000059034, -0.0004909753, ... 
        0.0013846876, -0.0068356697, -0.0071369358,  0.0100765979, ... 
        0.0141532421, -0.0079333076, -0.0181581630,  0.0023467017, ... 
        0.0163815550,  0.0024617413, -0.0096094845, -0.0028642490, ... 
        0.0017601802, -0.0015527223,  0.0028851819,  0.0077604049, ... 
       -0.0026574992, -0.0116367667, -0.0006313178,  0.0109662811, ... 
        0.0034449325, -0.0067478879, -0.0032969355,  0.0020118656, ... 
        0.0002976662,  0.0005962550,  0.0035057852, -0.0004099441, ... 
       -0.0060555132 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hd_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=qp_bandpass_test

diff -Bb test_h_coef.m $nstr"_h_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

diff -Bb test_hPM_coef.m $nstr"_hPM_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hPM_coef.m"; fail; fi

diff -Bb test_hd_coef.m $nstr"_hd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hd_coef.m"; fail; fi

#
# this much worked
#
pass

