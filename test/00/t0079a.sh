#!/bin/sh

prog=iir_frm_parallel_allpass_socp_slb_test.m

depends="iir_frm_parallel_allpass_socp_slb_test.m test_common.m \
../tarczynski_frm_parallel_allpass_test_r_coef.m \
../tarczynski_frm_parallel_allpass_test_s_coef.m \
../tarczynski_frm_parallel_allpass_test_aa_coef.m \
../tarczynski_frm_parallel_allpass_test_ac_coef.m \
iir_frm_parallel_allpass.m \
iir_frm_parallel_allpass_slb.m \
iir_frm_parallel_allpass_slb_constraints_are_empty.m \
iir_frm_parallel_allpass_slb_exchange_constraints.m \
iir_frm_parallel_allpass_slb_set_empty_constraints.m \
iir_frm_parallel_allpass_slb_show_constraints.m \
iir_frm_parallel_allpass_slb_update_constraints.m \
iir_frm_parallel_allpass_socp_mmse.m \
iir_frm_parallel_allpass_socp_slb_plot.m \
iir_frm_parallel_allpass_struct_to_vec.m \
iir_frm_parallel_allpass_vec_to_struct.m \
allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m \
local_max.m qroots.m qzsolve.oct"

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
cat > test_r_coef.m.ok << 'EOF'
r = [   1.0000000000,  -0.3609323789,   0.6575786320,  -0.2218466618, ... 
       -0.0214686384,   0.0518837804,  -0.0103025664,  -0.0036209391, ... 
        0.0033005761 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r_coef.m.ok"; fail; fi
cat > test_s_coef.m.ok << 'EOF'
s = [   1.0000000000,  -0.5764912563,   0.2356295634,   0.0329805162, ... 
       -0.0732205238,   0.0113745030,   0.0106441729,   0.0027049155 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_s_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0078989030,   0.0160183581,  -0.0266566372,  -0.0403264574, ... 
         0.0161681486,   0.0120735110,  -0.0343958748,  -0.0032565973, ... 
         0.0036305283,  -0.1458282291,  -0.1332423468,   0.2809612827, ... 
         0.5645849007,   0.3076237531,  -0.0238603457,  -0.0058985727, ... 
         0.1143791082,   0.0453060785,  -0.0392197866,   0.0018193453, ... 
         0.0353008881,   0.0203582813,   0.0132790009,   0.0054332569, ... 
         0.0069579142 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0101093076,  -0.0228344876,  -0.0125188206,   0.0046804495, ... 
        -0.0356563148,  -0.0240334972,   0.0470780681,  -0.0008369752, ... 
        -0.0885592761,  -0.0816669578,  -0.0873836137,   0.1827120689, ... 
         0.5867422108,   0.3946448820,  -0.1102909779,  -0.0366716860, ... 
         0.2188327636,   0.0055201079,  -0.1171704576,   0.0458981948, ... 
         0.0686261044,  -0.0291983615,   0.0009643986,   0.0348993849, ... 
        -0.0008874613 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
diff -Bb test_r_coef.m.ok iir_frm_parallel_allpass_socp_slb_test_r_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on r.coef"; fail; fi
diff -Bb test_s_coef.m.ok iir_frm_parallel_allpass_socp_slb_test_s_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on s.coef"; fail; fi
diff -Bb test_aa_coef.m.ok iir_frm_parallel_allpass_socp_slb_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on aa.coef"; fail; fi
diff -Bb test_ac_coef.m.ok iir_frm_parallel_allpass_socp_slb_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on ac.coef"; fail; fi

#
# this much worked
#
pass

