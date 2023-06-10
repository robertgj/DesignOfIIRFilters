#!/bin/sh

prog=tarczynski_frm_allpass_test.m

depends="test/tarczynski_frm_allpass_test.m test_common.m delayz.m print_polynomial.m \
print_pole_zero.m frm_lowpass_vectors.m"

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
cat > test_r1.ok << 'EOF'
r1 = [   1.0000000000,   0.2691326418,   0.4515850658,  -0.1227541794, ... 
        -0.0427592022,   0.0521962318,  -0.0280205506,   0.0246731162, ... 
        -0.0202666446,   0.0030661377,   0.0041572177 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r1.ok"; fail; fi

cat > test_aa1.ok << 'EOF'
aa1 = [  -0.0235374205,  -0.0131445322,   0.0322846735,  -0.0037339506, ... 
         -0.0300773669,   0.0053917122,   0.0171149979,  -0.0202522826, ... 
         -0.0045764603,   0.0605987472,   0.0058544239,  -0.0715557486, ... 
          0.0369179994,   0.0565878743,  -0.0504457891,  -0.0024308055, ... 
          0.0810752746,  -0.0669044966,  -0.1331993072,   0.2904900656, ... 
          0.6473779347,   0.2904900656,  -0.1331993072,  -0.0669044966, ... 
          0.0810752746,  -0.0024308055,  -0.0504457891,   0.0565878743, ... 
          0.0369179994,  -0.0715557486,   0.0058544239,   0.0605987472, ... 
         -0.0045764603,  -0.0202522826,   0.0171149979,   0.0053917122, ... 
         -0.0300773669,  -0.0037339506,   0.0322846735,  -0.0131445322, ... 
         -0.0235374205 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa1.ok"; fail; fi

cat > test_ac1.ok << 'EOF'
ac1 = [  -0.0176574189,   0.0563617055,   0.1749131273,   0.0600386009, ... 
         -0.0212652171,  -0.0057435223,   0.0111009619,  -0.0000722414, ... 
         -0.0078897301,  -0.0391103591,   0.1392921178,   0.4823232181, ... 
          0.1790829576,  -0.0806772846,  -0.0128474157,   0.0602330486, ... 
         -0.0499979152,  -0.0128510700,   0.0649102653,  -0.0676468667, ... 
         -0.0220055303,  -0.0676468667,   0.0649102653,  -0.0128510700, ... 
         -0.0499979152,   0.0602330486,  -0.0128474157,  -0.0806772846, ... 
          0.1790829576,   0.4823232181,   0.1392921178,  -0.0391103591, ... 
         -0.0078897301,  -0.0000722414,   0.0111009619,  -0.0057435223, ... 
         -0.0212652171,   0.0600386009,   0.1749131273,   0.0563617055, ... 
         -0.0176574189 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_r1.ok tarczynski_frm_allpass_test_r1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r1.ok"; fail; fi

diff -Bb test_aa1.ok tarczynski_frm_allpass_test_aa1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aa1.ok"; fail; fi

diff -Bb test_ac1.ok tarczynski_frm_allpass_test_ac1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ac1.ok"; fail; fi


#
# this much worked
#
pass

