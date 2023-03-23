#!/bin/sh

prog=tfp2schurNSlattice2Abcd_test.m
depends="test/tfp2schurNSlattice2Abcd_test.m test_common.m \
tfp2schurNSlattice2Abcd.m tf2schurNSlattice.m tf2schurOneMlattice.m \
schurNSlattice2Abcd.oct schurOneMlattice2Abcd.oct KW.m optKW.m phi2p.m \
Abcd2tf.m schurNSlatticeNoiseGain.m schurOneMlatticeNoiseGain.m \
schurNSlatticeFilter.m schurOneMlatticeFilter.m crossWelch.m \
schurdecomp.oct schurexpand.oct schurNSscale.oct schurOneMscale.m \
p2n60.m qroots.m qzsolve.oct"

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
cat > test.ok << 'EOF'
ng_opt = 1.0730
ans = 1.5811
ans = 1.6008
ans = 11.204
ans = 34.582
A =
 Columns 1 through 8:
   0.2212   0.9752        0        0        0        0        0        0
  -0.7085   0.1607   0.6871        0        0        0        0        0
   0.1176  -0.0267   0.1276   0.9845        0        0        0        0
  -0.4077   0.0925  -0.4421   0.1085   0.7862        0        0        0
   0.0821  -0.0186   0.0891  -0.0219   0.0979   0.9874        0        0
  -0.1196   0.0271  -0.1297   0.0318  -0.1426   0.0370  -0.2454   0.0557
        0        0        0        0        0        0   0.2212   0.9752
        0        0        0        0        0        0  -0.7085   0.1607
        0        0        0        0        0        0   0.1176  -0.0267
        0        0        0        0        0        0  -0.4077   0.0925
        0        0        0        0        0        0   0.0821  -0.0186
   0.2242  -0.0509   0.2431  -0.0597   0.2672  -0.0693  -0.2247   0.0510
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.0434  -0.0098   0.0470  -0.0115   0.0517  -0.0134  -0.2636   0.0598
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.2600   0.0590  -0.2819   0.0692  -0.3099   0.0804   0.0786  -0.0178
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.0537   0.0122  -0.0582   0.0143  -0.0640   0.0166  -0.0467   0.0106
 Columns 9 through 16:
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.2660   0.0653  -0.2924   0.0759   0.0895  -0.0203   0.0970  -0.0238
        0        0        0        0        0        0        0        0
   0.6871        0        0        0        0        0        0        0
   0.1276   0.9845        0        0        0        0        0        0
  -0.4421   0.1085   0.7862        0        0        0        0        0
   0.0891  -0.0219   0.0979   0.9874        0        0        0        0
  -0.2436   0.0598  -0.2678   0.0695   0.2547  -0.0578   0.2761  -0.0678
        0        0        0        0   0.2212   0.9752        0        0
        0        0        0        0  -0.7085   0.1607   0.6871        0
        0        0        0        0   0.1176  -0.0267   0.1276   0.9845
        0        0        0        0  -0.4077   0.0925  -0.4421   0.1085
        0        0        0        0   0.0821  -0.0186   0.0891  -0.0219
  -0.2858   0.0702  -0.3142   0.0815  -0.2216   0.0503  -0.2403   0.0590
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.0852  -0.0209   0.0937  -0.0243   0.1827  -0.0414   0.1981  -0.0486
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.0507   0.0124  -0.0557   0.0145   0.1371  -0.0311   0.1487  -0.0365
 Columns 17 through 24:
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.1066  -0.0277   0.0434  -0.0098   0.0470  -0.0115   0.0517  -0.0134
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.3035  -0.0788  -0.0491   0.0111  -0.0532   0.0131  -0.0585   0.0152
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.7862        0        0        0        0        0        0        0
   0.0979   0.9874        0        0        0        0        0        0
  -0.2641   0.0685  -0.1331   0.0302  -0.1443   0.0354  -0.1586   0.0412
        0        0   0.2212   0.9752        0        0        0        0
        0        0  -0.7085   0.1607   0.6871        0        0        0
        0        0   0.1176  -0.0267   0.1276   0.9845        0        0
        0        0  -0.4077   0.0925  -0.4421   0.1085   0.7862        0
        0        0   0.0821  -0.0186   0.0891  -0.0219   0.0979   0.9874
   0.2177  -0.0565  -0.1600   0.0363  -0.1734   0.0426  -0.1906   0.0495
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.1634  -0.0424  -0.3635   0.0825  -0.3941   0.0967  -0.4332   0.1124
 Columns 25 through 30:
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.2641  -0.0599   0.2864  -0.0703   0.3148  -0.0817
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.0345  -0.0078   0.0374  -0.0092   0.0411  -0.0107
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
  -0.1897   0.0430  -0.2057   0.0505  -0.2261   0.0587
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.0931  -0.0211   0.1009  -0.0248   0.1109  -0.0288
   0.2212   0.9752        0        0        0        0
  -0.7085   0.1607   0.6871        0        0        0
   0.1176  -0.0267   0.1276   0.9845        0        0
  -0.4077   0.0925  -0.4421   0.1085   0.7862        0
   0.0821  -0.0186   0.0891  -0.0219   0.0979   0.9874
  -0.1640   0.0372  -0.1779   0.0437  -0.1955   0.0507

B =
        0
        0
        0
        0
        0
   0.2044
        0
        0
        0
        0
        0
  -0.0991
        0
        0
        0
        0
        0
   0.0579
        0
        0
        0
        0
        0
  -0.1852
        0
        0
        0
        0
        0
   0.1029

C =
 Columns 1 through 7:
   0.828008  -0.187836   0.897757  -0.220368   0.986740  -0.256106   0.227543
 Columns 8 through 14:
  -0.051619   0.246710  -0.060559   0.271164  -0.070380   0.220917  -0.050116
 Columns 15 through 21:
   0.239527  -0.058795   0.263268  -0.068331  -0.414429   0.094014  -0.449339
 Columns 22 through 28:
   0.110297  -0.493877   0.128184   0.692998  -0.157209   0.751374  -0.184436
 Columns 29 and 30:
   0.825848  -0.214347

D = 0.2437
ABCD_nz_coefs = 286
ans = 41.163
ans = 3651.6
NG_ABCD = 6.4380
ABCDopt_nz_coefs = 961
NG_ABCDopt = 6.4380
NG_schurNS = 18.883
est_varyd = 1.6569
varyd = 1.7615
NG_schurOneM = 13.603
est_varyd = 1.2169
varyd = 1.3363
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

cat > test.tab << 'EOF'
\begin{table}[hptb]
\centering
\begin{threeparttable}
\begin{tabular}{lrrr}  \toprule
&Non-zero coefficients&Noise gain&Noise variance(bits)\\ 
\midrule
ABCD transformed & 286 &  6.44 &  0.62 \\ 
Globally optimised & 961 &  6.44 &  0.62 \\ 
Schur normalised-scaled lattice & 180 & 18.88 &  1.66 \\ 
Schur one-multiplier lattice & 61 & 13.60 &  1.22 \\ 
\bottomrule
\end{tabular}
\end{threeparttable}
\caption[Schur NS lattice frequency transformation example]{Schur NS lattice frequency transformation round-off noise example : number of non-zero coefficients, noise gain and estimated output roundoff noise variances for a prototype 5th order elliptic low-pass filter transformed to a multiple band-stop filter.}
\label{tab:Schur-NS-lattice-frequency-transformation-example}
\end{table}
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.tab"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

diff -Bb test.tab tfp2schurNSlattice2Abcd_test.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

