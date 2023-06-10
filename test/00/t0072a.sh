#!/bin/sh

prog=iir_frm_socp_slb_test.m

depends="test/iir_frm_socp_slb_test.m test_common.m delayz.m \
../tarczynski_frm_iir_test_a_coef.m \
../tarczynski_frm_iir_test_d_coef.m \
../tarczynski_frm_iir_test_aa_coef.m \
../tarczynski_frm_iir_test_ac_coef.m \
iir_frm.m \
iir_frm_slb.m \
iir_frm_slb_constraints_are_empty.m \
iir_frm_slb_exchange_constraints.m \
iir_frm_slb_set_empty_constraints.m \
iir_frm_slb_show_constraints.m \
iir_frm_slb_update_constraints.m \
iir_frm_socp_mmse.m \
iir_frm_socp_slb_plot.m \
iir_frm_struct_to_vec.m \
iir_frm_vec_to_struct.m \
iirA.m iirP.m iirT.m iirdelAdelw.m fixResultNaN.m tf2x.m zp2x.m x2tf.m \
xConstraints.m print_polynomial.m print_pole_zero.m \
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
cat > test_exp_a_coef.m << 'EOF'
a = [   0.0023072067,   0.0001004998,  -0.0027009187,  -0.0009118762, ... 
        0.0070683537,   0.0022809590,  -0.0152588768,   0.0325623629, ... 
       -0.0258497547,   0.0075253412,   0.0039808664 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_a_coef.m"; fail; fi

cat > test_exp_d_coef.m << 'EOF'
d = [   1.0000000000,   0.5103321859,   0.8307417974,   0.3705503351, ... 
        0.0900090972,  -0.0126066756,  -0.0129428074,  -0.0028778601, ... 
       -0.0002557166,  -0.0000085521,  -0.0000008915 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_d_coef.m"; fail; fi

cat > test_exp_aa_coef.m << 'EOF'
aa = [   0.1269145974,   0.1734400528,  -0.4578826228,   0.2829389922, ... 
         0.1394182675,  -0.1805542094,   0.0675961726,   0.2274211424, ... 
        -0.2391590255,  -0.0631222160,   0.3888974987,  -0.2334031908, ... 
        -0.2629044691,   0.4008656834,   0.0826279326,  -0.4882750388, ... 
         0.2621935021,   0.4023232824,  -0.3411513354,   0.5627021602, ... 
         0.2816829763,   0.5627021602,  -0.3411513354,   0.4023232824, ... 
         0.2621935021,  -0.4882750388,   0.0826279326,   0.4008656834, ... 
        -0.2629044691,  -0.2334031908,   0.3888974987,  -0.0631222160, ... 
        -0.2391590255,   0.2274211424,   0.0675961726,  -0.1805542094, ... 
         0.1394182675,   0.2829389922,  -0.4578826228,   0.1734400528, ... 
         0.1269145974 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_aa_coef.m"; fail; fi

cat > test_exp_ac_coef.m << 'EOF'
ac = [  -0.0026969743,  -0.0087527898,   0.0166331172,  -0.0068670676, ... 
        -0.0084816844,   0.0049259385,   0.0040698641,  -0.0113915352, ... 
         0.0024609268,   0.0213832121,   0.0015428433,  -0.0417158570, ... 
         0.0391893229,   0.0136891487,  -0.0441833606,   0.0173797890, ... 
         0.0628603921,  -0.0759849998,  -0.0826548163,   0.2904856694, ... 
         0.6122604039,   0.2904856694,  -0.0826548163,  -0.0759849998, ... 
         0.0628603921,   0.0173797890,  -0.0441833606,   0.0136891487, ... 
         0.0391893229,  -0.0417158570,   0.0015428433,   0.0213832121, ... 
         0.0024609268,  -0.0113915352,   0.0040698641,   0.0049259385, ... 
        -0.0084816844,  -0.0068670676,   0.0166331172,  -0.0087527898, ... 
        -0.0026969743 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_ac_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

for filter in a d aa ac ; do
    octave --no-gui -q test_exp_$filter"_coef.m" >test.out 2>&1
    if [ $? -ne 0 ]; then echo "Failed for $filter"; fail; fi
done

#
# this much worked
#
pass

