#!/bin/sh

prog=bitflip_test.m
descr="bitflip_test.m (mfile)"
depends="bitflip_test.m test_common.m bitflip.m tf2schurNSlattice.m \
truncation_test_common.m print_polynomial.m schurNSlattice2tf.m \
schurNSlattice_cost.m schurNSscale.oct schurdecomp.oct schurexpand.oct \
schurNSlattice2Abcd.oct Abcd2tf.m x2nextra.m flt2SD.m bin2SD.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $descr 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $descr
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
norder =    5.0000e+00
dBpass =    1.0000e+00
dBstop =    4.0000e+01
fpass =    1.2500e-01
fstop =    1.5000e-01
nbits =    6.0000e+00
ndigits =    2.0000e+00
bitstart =    4.0000e+00
msize =    3.0000e+00
bitflip_test: cost_ex= 1.00080
bitflip_test: cost_rd= 1.21300
bitflip_test:nbits=7,bitstart=6,msize=1,cost_bf= 0.85784,fiter=480
bitflip_test:nbits=7,bitstart=6,msize=2,cost_bf= 0.79712,fiter=960
bitflip_test:nbits=7,bitstart=6,msize=3,cost_bf= 0.75325,fiter=2880
bitflip_test:nbits=7,bitstart=6,msize=4,cost_bf= 0.74147,fiter=3200
bitflip_test:nbits=7,bitstart=6,msize=5,cost_bf= 0.74147,fiter=5760
bitflip_test:nbits=7,bitstart=6,msize=6,cost_bf= 0.75179,fiter=8960
bitflip:initial cost=1.213
bitflip:cof(2)=0x2c:cost 1.213001>1.109735 for 0x2e(mask=0x41,l=0x2e,bit=6)
bitflip:cof(2)=0x2e:cost 1.109735>1.082687 for 0x30(mask=0x41,l=0x30,bit=6)
bitflip:cof(3)=0x16:cost 1.082687>1.016599 for 0x18(mask=0x41,l=0x18,bit=6)
bitflip:cof(6)=0xd:cost 1.016599>0.998073 for 0x3(mask=0x41,l=0x2,bit=6)
bitflip:cof(6)=0x3:cost 0.998073>0.982993 for 0x5(mask=0x41,l=0x4,bit=6)
bitflip:cof(6)=0x5:cost 0.982993>0.977964 for 0x7(mask=0x41,l=0x6,bit=6)
bitflip:cof(7)=0x2f:cost 0.977964>0.902108 for 0x31(mask=0x41,l=0x30,bit=6)
bitflip:cof(7)=0x31:cost 0.902108>0.884848 for 0x33(mask=0x41,l=0x32,bit=6)
bitflip:cof(6)=0x7:cost 0.884848>0.874956 for 0x9(mask=0x41,l=0x8,bit=6)
bitflip:cof(17)=0x12:cost 0.874956>0.864994 for 0x11(mask=0x60,l=0x11,bit=5)
bitflip:cof(19)=0x24:cost 0.864994>0.863401 for 0x23(mask=0x60,l=0x3,bit=5)
bitflip:cof(20)=0x38:cost 0.863401>0.842098 for 0x39(mask=0x60,l=0x19,bit=5)
bitflip:cof(6)=0x9:cost 0.842098>0.841959 for 0x8(mask=0x60,l=0x8,bit=5)
bitflip:cof(7)=0x33:cost 0.841959>0.839432 for 0x34(mask=0x60,l=0x14,bit=5)
bitflip:cof(18)=0x1e:cost 0.839432>0.825390 for 0x1d(mask=0x60,l=0x1d,bit=5)
bitflip:cof(20)=0x39:cost 0.825390>0.818275 for 0x3a(mask=0x60,l=0x1a,bit=5)
bitflip:cof(4)=0x9:cost 0.818275>0.803031 for 0x8(mask=0x60,l=0x8,bit=5)
bitflip:cof(6)=0x8:cost 0.803031>0.802145 for 0x7(mask=0x60,l=0x7,bit=5)
bitflip:cof(19)=0x23:cost 0.802145>0.798297 for 0x22(mask=0x60,l=0x2,bit=5)
bitflip:cof(20)=0x3a:cost 0.798297>0.769045 for 0x3b(mask=0x60,l=0x1b,bit=5)
bitflip:cof(3)=0x18:cost 0.769045>0.761848 for 0x17(mask=0x60,l=0x17,bit=5)
bitflip:cof(6)=0x7:cost 0.761848>0.756069 for 0x8(mask=0x60,l=0x8,bit=5)
bitflip:cof(6)=0x8:cost 0.756069>0.753573 for 0x9(mask=0x60,l=0x9,bit=5)
bitflip:cof(7)=0x34:cost 0.753573>0.742345 for 0x35(mask=0x60,l=0x15,bit=5)
bitflip:cof(6)=0x9:cost 0.742345>0.741465 for 0xa(mask=0x60,l=0xa,bit=5)
bitflip:final cost=0.741465,fiter=5760
bitflip_test:nbits=7,bitstart=6,msize=5,cost_bf= 0.74147,fiter=5760
s10_bf = [   0.9843750000,   0.7500000000,   0.3593750000,   0.1250000000, ... 
             0.0156250000 ]';
s11_bf = [   0.1562500000,   0.8281250000,   0.9375000000,   0.9843750000, ... 
             0.4843750000 ]';
s20_bf = [  -0.7656250000,   0.9531250000,  -0.8750000000,   0.8281250000, ... 
            -0.4843750000 ]';
s00_bf = [   0.6406250000,   0.2656250000,   0.4531250000,   0.5312500000, ... 
             0.9218750000 ]';
s02_bf = [   0.7656250000,  -0.9531250000,   0.8750000000,  -0.8281250000, ... 
             0.4843750000 ]';
s22_bf = [   0.6406250000,   0.2656250000,   0.4531250000,   0.5312500000, ... 
             0.9218750000 ]';
svec_bf = [  63.0000000000,  48.0000000000,  23.0000000000,   8.0000000000, ... 
              1.0000000000,  10.0000000000,  53.0000000000,  60.0000000000, ... 
             63.0000000000,  31.0000000000, -49.0000000000,  61.0000000000, ... 
            -56.0000000000,  53.0000000000, -31.0000000000,  41.0000000000, ... 
             17.0000000000,  29.0000000000,  34.0000000000,  59.0000000000 ];
bitflip_test:k=1,cost_del=1.42732,cost_bf= 1.06396,fiter=72
bitflip_test:k=2,cost_del=1.57734,cost_bf= 1.08269,fiter=48
bitflip_test:k=3,cost_del=1.69007,cost_bf= 1.16854,fiter=64
bitflip_test:k=4,cost_del=2.20297,cost_bf= 1.16550,fiter=64
bitflip_test:k=5,cost_del=3.61572,cost_bf= 1.21300,fiter=48
bitflip_test:k=6,cost_del=1.2542,cost_bf= 1.18562,fiter=72
bitflip_test:k=7,cost_del=1.51635,cost_bf= 1.04592,fiter=72
bitflip_test:k=8,cost_del=1.67635,cost_bf= 0.94405,fiter=64
bitflip_test:k=9,cost_del=1.74457,cost_bf= 0.88431,fiter=64
bitflip_test:k=10,cost_del=2.29648,cost_bf= 0.97110,fiter=56
bitflip_test:k=11,cost_del=3.72372,cost_bf= 3.70641,fiter=48
bitflip_test:k=12,cost_del=2.1759,cost_bf= 1.14340,fiter=56
bitflip_test:k=13,cost_del=8.34413,cost_bf= 8.15111,fiter=48
bitflip_test:k=14,cost_del=2.07156,cost_bf= 1.08866,fiter=64
bitflip_test:k=15,cost_del=4.45667,cost_bf= 4.14261,fiter=48
bitflip_test:k=16,cost_del=3.62241,cost_bf= 1.21300,fiter=64
bitflip_test:k=17,cost_del=1.77598,cost_bf= 1.21300,fiter=56
bitflip_test:k=18,cost_del=2.07816,cost_bf= 1.21778,fiter=56
bitflip_test:k=19,cost_del=1.99109,cost_bf= 1.05388,fiter=56
bitflip_test:k=20,cost_del=0.969901,cost_bf= 0.96990,fiter=40
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings.
#
echo "Running octave-cli -q " $descr

octave-cli -q $prog > test.out 
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

