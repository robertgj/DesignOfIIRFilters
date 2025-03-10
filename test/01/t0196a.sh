#!/bin/sh

prog=tfp2schurNSlattice2Abcd_test.m
depends="test/tfp2schurNSlattice2Abcd_test.m test_common.m \
tfp2schurNSlattice2Abcd.m tf2schurNSlattice.m tf2schurOneMlattice.m \
schurNSlattice2Abcd.oct schurOneMlattice2Abcd.oct KW.m optKW.m phi2p.m \
schurNSlatticeNoiseGain.m schurOneMlatticeNoiseGain.m \
schurNSlatticeFilter.m schurOneMlatticeFilter.m crossWelch.m \
schurdecomp.oct schurexpand.oct schurNSscale.oct schurOneMscale.m \
p2n60.m qroots.oct Abcd2tf.oct"

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
A =
 Columns 1 through 8:
   0.2212   0.9752        0        0        0        0        0        0
  -0.7085   0.1607   0.6871        0        0        0        0        0
   0.1176  -0.0267   0.1276   0.9845        0        0        0        0
  -0.4077   0.0925  -0.4421   0.1085   0.7862        0        0        0
   0.0821  -0.0186   0.0891  -0.0219   0.0979   0.9874        0        0
  -0.1210   0.0275  -0.1312   0.0322  -0.1443   0.0374  -0.2186   0.0496
        0        0        0        0        0        0   0.2212   0.9752
        0        0        0        0        0        0  -0.7085   0.1607
        0        0        0        0        0        0   0.1176  -0.0267
        0        0        0        0        0        0  -0.4077   0.0925
        0        0        0        0        0        0   0.0821  -0.0186
   0.2509  -0.0569   0.2720  -0.0668   0.2990  -0.0776  -0.2233   0.0507
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.1035  -0.0235   0.1122  -0.0275   0.1233  -0.0320  -0.2494   0.0566
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.2656   0.0603  -0.2880   0.0707  -0.3165   0.0822   0.0198  -0.0045
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.0406   0.0092  -0.0440   0.0108  -0.0484   0.0126  -0.0516   0.0117
 Columns 9 through 16:
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.2371   0.0582  -0.2606   0.0676   0.0287  -0.0065   0.0311  -0.0076
        0        0        0        0        0        0        0        0
   0.6871        0        0        0        0        0        0        0
   0.1276   0.9845        0        0        0        0        0        0
  -0.4421   0.1085   0.7862        0        0        0        0        0
   0.0891  -0.0219   0.0979   0.9874        0        0        0        0
  -0.2421   0.0594  -0.2661   0.0691   0.2656  -0.0602   0.2879  -0.0707
        0        0        0        0   0.2212   0.9752        0        0
        0        0        0        0  -0.7085   0.1607   0.6871        0
        0        0        0        0   0.1176  -0.0267   0.1276   0.9845
        0        0        0        0  -0.4077   0.0925  -0.4421   0.1085
        0        0        0        0   0.0821  -0.0186   0.0891  -0.0219
  -0.2704   0.0664  -0.2972   0.0771  -0.2216   0.0503  -0.2403   0.0590
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.0215  -0.0053   0.0236  -0.0061   0.1897  -0.0430   0.2057  -0.0505
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.0559   0.0137  -0.0614   0.0159   0.1331  -0.0302   0.1443  -0.0354
 Columns 17 through 24:
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.0342  -0.0089   0.0561  -0.0127   0.0608  -0.0149   0.0668  -0.0174
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.3165  -0.0821  -0.0435   0.0099  -0.0472   0.0116  -0.0519   0.0135
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.7862        0        0        0        0        0        0        0
   0.0979   0.9874        0        0        0        0        0        0
  -0.2641   0.0685  -0.1372   0.0311  -0.1487   0.0365  -0.1635   0.0424
        0        0   0.2212   0.9752        0        0        0        0
        0        0  -0.7085   0.1607   0.6871        0        0        0
        0        0   0.1176  -0.0267   0.1276   0.9845        0        0
        0        0  -0.4077   0.0925  -0.4421   0.1085   0.7862        0
        0        0   0.0821  -0.0186   0.0891  -0.0219   0.0979   0.9874
   0.2261  -0.0587  -0.1640   0.0372  -0.1779   0.0437  -0.1955   0.0507
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.1586  -0.0412  -0.3635   0.0825  -0.3941   0.0967  -0.4332   0.1124
 Columns 25 through 30:
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.2553  -0.0579   0.2768  -0.0679   0.3043  -0.0790
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.0928  -0.0211   0.1007  -0.0247   0.1106  -0.0287
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
  -0.1827   0.0414  -0.1981   0.0486  -0.2177   0.0565
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.0931  -0.0211   0.1010  -0.0248   0.1110  -0.0288
   0.2212   0.9752        0        0        0        0
  -0.7085   0.1607   0.6871        0        0        0
   0.1176  -0.0267   0.1276   0.9845        0        0
  -0.4077   0.0925  -0.4421   0.1085   0.7862        0
   0.0821  -0.0186   0.0891  -0.0219   0.0979   0.9874
  -0.1600   0.0363  -0.1735   0.0426  -0.1907   0.0495

B =
        0
        0
        0
        0
        0
   0.2211
        0
        0
        0
        0
        0
  -0.0481
        0
        0
        0
        0
        0
   0.0581
        0
        0
        0
        0
        0
  -0.1826
        0
        0
        0
        0
        0
   0.1091

C =
 Columns 1 through 7:
   0.754250  -0.171104   0.817786  -0.200738   0.898843  -0.233292   0.417475
 Columns 8 through 14:
  -0.094705   0.452642  -0.111108   0.497507  -0.129127   0.220145  -0.049941
 Columns 15 through 21:
   0.238690  -0.058590   0.262348  -0.068092  -0.390723   0.088637  -0.423636
 Columns 22 through 28:
   0.103988  -0.465626   0.120852   0.702757  -0.159423   0.761956  -0.187033
 Columns 29 and 30:
   0.837479  -0.217366

D = 0.2437
ABCD_nz_coefs = 286
NG_ABCD = 6.4380
ABCDopt_nz_coefs = 961
NG_ABCDopt = 6.4380
NG_schurNS = 18.883
est_varyd = 1.6570
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

