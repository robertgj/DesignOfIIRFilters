#!/bin/sh

prog=iir_frm_socp_slb_test.m

depends="test/iir_frm_socp_slb_test.m test_common.m \
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
exp_a = [   0.0023872435,  -0.0002998516,  -0.0028178530,  -0.0006292835, ... 
            0.0075112808,   0.0007771227,  -0.0153793578,   0.0328696565, ... 
           -0.0275937942,   0.0088012491,   0.0051176032  ]';
iir_frm_socp_slb_test_a_coef;
tol=2e-8;
if max(abs(exp_a-a))>tol
   error("max(abs(exp_a-a))(%g)>tol(%g)",max(abs(exp_a-a)),tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_a_coef.m"; fail; fi

cat > test_exp_d_coef.m << 'EOF'
exp_d = [   1.0000000000,   0.3925483043,   0.7343625347,   0.2883931662, ... 
            0.0561892637,  -0.0084691690,  -0.0054392025,  -0.0010209218, ... 
           -0.0001136908,  -0.0000105375,  -0.0000006973 ]';
iir_frm_socp_slb_test_d_coef;
tol=2e-8;
if max(abs(exp_d-d))>tol
   error("max(abs(exp_d-d))(%g)>tol(%g)",max(abs(exp_d-d)),tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_d_coef.m"; fail; fi

cat > test_exp_aa_coef.m << 'EOF'
exp_aa = [  0.1390307825,   0.1637722775,  -0.4624376812,   0.3001578566, ... 
            0.1315784307,  -0.1954580193,   0.0918906885,   0.2285812605, ... 
           -0.2582587245,  -0.0510615690,   0.4089339399,  -0.2772987421, ... 
           -0.2448363933,   0.4178081872,   0.0611968156,  -0.4873687979, ... 
            0.2932744964,   0.3733965821,  -0.3282092409,   0.5572050084, ... 
            0.2923220653,   0.5572050084,  -0.3282092409,   0.3733965821, ... 
            0.2932744964,  -0.4873687979,   0.0611968156,   0.4178081872, ... 
           -0.2448363933,  -0.2772987421,   0.4089339399,  -0.0510615690, ... 
           -0.2582587245,   0.2285812605,   0.0918906885,  -0.1954580193, ... 
            0.1315784307,   0.3001578566,  -0.4624376812,   0.1637722775, ... 
            0.1390307825  ]';
iir_frm_socp_slb_test_aa_coef;
tol=2e-8;
if max(abs(exp_aa-aa))>tol
   error("max(abs(exp_aa-aa))(%g)>tol(%g)",max(abs(exp_aa-aa)),tol);
endif
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_exp_aa_coef.m"; fail; fi

cat > test_exp_ac_coef.m << 'EOF'
exp_ac = [ -0.0029639740,  -0.0079292225,   0.0154038074,  -0.0064703235, ... 
           -0.0080891576,   0.0049463675,   0.0035094405,  -0.0104947353, ... 
            0.0014871843,   0.0217797981,   0.0002949507,  -0.0392881999, ... 
            0.0380337181,   0.0135031685,  -0.0446458306,   0.0177031304, ... 
            0.0624691923,  -0.0750983708,  -0.0832297850,   0.2924774451, ... 
            0.6087368404,   0.2924774451,  -0.0832297850,  -0.0750983708, ... 
            0.0624691923,   0.0177031304,  -0.0446458306,   0.0135031685, ... 
            0.0380337181,  -0.0392881999,   0.0002949507,   0.0217797981, ... 
            0.0014871843,  -0.0104947353,   0.0035094405,   0.0049463675, ... 
           -0.0080891576,  -0.0064703235,   0.0154038074,  -0.0079292225, ... 
           -0.0029639740 ]';
iir_frm_socp_slb_test_ac_coef;
tol=2e-8;
if max(abs(exp_ac-ac))>tol
   error("max(abs(exp_ac-ac))(%g)>tol(%g)",max(abs(exp_ac-ac)),tol);
endif
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

