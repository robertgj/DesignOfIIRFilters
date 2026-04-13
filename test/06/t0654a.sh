#!/bin/sh

prog=yalmip_solver_kyp_test.m
depends="test/yalmip_solver_kyp_test.m test_common.m delayz.m print_polynomial.m"

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
cat > test_sedumi_h_coef.ok << 'EOF'
h = [  0.0020599330,  0.0052912895,  0.0060621114, -0.0010504333, ... 
      -0.0167321374, -0.0302042534, -0.0202083499,  0.0320931539, ... 
       0.1247243675,  0.2260203160,  0.2868961833,  0.2702945619, ... 
       0.1779771776,  0.0533152132, -0.0445245688, -0.0773920601, ... 
      -0.0492933709,  0.0024466889,  0.0369074049,  0.0363983314, ... 
       0.0118726435, -0.0126520454, -0.0206498784, -0.0123957550, ... 
       0.0007141389,  0.0081240298,  0.0073547344,  0.0026129335, ... 
      -0.0010589468, -0.0018432917, -0.0009458396 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sedumi_h_coef.ok"; fail; fi

cat > test_sdpt3_h_coef.ok << 'EOF'
h = [  0.0020415962,  0.0051933493,  0.0056762112, -0.0017216070, ... 
      -0.0174088575, -0.0304044249, -0.0196379858,  0.0331415917, ... 
       0.1254201827,  0.2255983051,  0.2853822790,  0.2686833609, ... 
       0.1775431018,  0.0545389206, -0.0424824575, -0.0761031790, ... 
      -0.0497889641,  0.0005361716,  0.0350540217,  0.0359717430, ... 
       0.0130662782, -0.0108714089, -0.0196073744, -0.0126564684, ... 
      -0.0003552808,  0.0072312710,  0.0072915522,  0.0033145636, ... 
      -0.0001283390, -0.0011784037, -0.0006556649 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sdpt3_h_coef.ok"; fail; fi

cat > test_scs-direct_h_coef.ok << 'EOF'
h = [  0.0006316482,  0.0042475352,  0.0068777529,  0.0023257560, ... 
      -0.0127435821, -0.0293096960, -0.0244803361,  0.0250840253, ... 
       0.1208371412,  0.2295785172,  0.2961461420,  0.2779541305, ... 
       0.1772516368,  0.0441088883, -0.0550261897, -0.0806712691, ... 
      -0.0428015643,  0.0131922513,  0.0432515576,  0.0339109210, ... 
       0.0035867694, -0.0195824004, -0.0213556677, -0.0077411621, ... 
       0.0059960996,  0.0100593158,  0.0055887028, -0.0004736009, ... 
      -0.0031426326, -0.0023649446, -0.0004678450 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_scs-direct_h_coef.ok"; fail;
fi

cat > test_scs-indirect_h_coef.ok << 'EOF'
h = [  0.0008574590,  0.0043599150,  0.0069672994,  0.0022392151, ... 
      -0.0128983122, -0.0293178388, -0.0242809771,  0.0252215422, ... 
       0.1206270795,  0.2290950933,  0.2958593311,  0.2783120479, ... 
       0.1781131808,  0.0447256603, -0.0553176402, -0.0817791983, ... 
      -0.0438207569,  0.0131970667,  0.0443473033,  0.0352002547, ... 
       0.0039745375, -0.0204166470, -0.0226578356, -0.0084262026, ... 
       0.0064043023,  0.0110913468,  0.0063394566, -0.0004926119, ... 
      -0.0036904311, -0.0028300260, -0.0007352789 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_scs-indirect_h_coef.ok"; fail;
fi

#
# run and see if the results match. 
#
echo "Running $prog"

nstr="yalmip_solver_kyp_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_sedumi_h_coef.ok $nstr"_sedumi_h_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_sedumi_h_coef.ok"; fail; fi

diff -Bb test_sdpt3_h_coef.ok $nstr"_sdpt3_h_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_sdpt3_h_coef.ok"; fail; fi

diff -Bb test_scs-direct_h_coef.ok $nstr"_scs-direct_h_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_scs-direct_h_coef.ok"; fail; fi

diff -Bb test_scs-indirect_h_coef.ok $nstr"_scs-indirect_h_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_scs-indirect_h_coef.ok"; fail; fi

#
# this much worked
#
pass

