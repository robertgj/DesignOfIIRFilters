#!/bin/sh

prog=tfp2schurNSlattice2Abcd_test.m
depends="test/tfp2schurNSlattice2Abcd_test.m test_common.m \
tfp2schurNSlattice2Abcd.m tf2schurNSlattice.m tf2schurOneMlattice.m \
KW.m optKW.m phi2p.m schurNSlatticeNoiseGain.m schurOneMlatticeNoiseGain.m \
schurNSlatticeFilter.m crossWelch.m \
schurOneMlatticeFilter.oct schurNSlattice2Abcd.oct schurOneMlattice2Abcd.oct \
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
  -0.1145   0.0260  -0.1242   0.0305  -0.1365   0.0354  -0.2481   0.0563
        0        0        0        0        0        0   0.2212   0.9752
        0        0        0        0        0        0  -0.7085   0.1607
        0        0        0        0        0        0   0.1176  -0.0267
        0        0        0        0        0        0  -0.4077   0.0925
        0        0        0        0        0        0   0.0821  -0.0186
   0.2433  -0.0552   0.2638  -0.0648   0.2900  -0.0753  -0.2257   0.0512
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.0596  -0.0135   0.0646  -0.0158   0.0710  -0.0184  -0.2491   0.0565
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.2575   0.0584  -0.2792   0.0685  -0.3069   0.0796   0.0588  -0.0133
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.0439   0.0100  -0.0476   0.0117  -0.0523   0.0136  -0.0506   0.0115
 Columns 9 through 16:
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.2690   0.0660  -0.2956   0.0767   0.0659  -0.0149   0.0714  -0.0175
        0        0        0        0        0        0        0        0
   0.6871        0        0        0        0        0        0        0
   0.1276   0.9845        0        0        0        0        0        0
  -0.4421   0.1085   0.7862        0        0        0        0        0
   0.0891  -0.0219   0.0979   0.9874        0        0        0        0
  -0.2447   0.0601  -0.2690   0.0698   0.2505  -0.0568   0.2716  -0.0667
        0        0        0        0   0.2212   0.9752        0        0
        0        0        0        0  -0.7085   0.1607   0.6871        0
        0        0        0        0   0.1176  -0.0267   0.1276   0.9845
        0        0        0        0  -0.4077   0.0925  -0.4421   0.1085
        0        0        0        0   0.0821  -0.0186   0.0891  -0.0219
  -0.2701   0.0663  -0.2969   0.0771  -0.2278   0.0517  -0.2470   0.0606
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.0637  -0.0156   0.0700  -0.0182   0.1951  -0.0443   0.2115  -0.0519
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
  -0.0549   0.0135  -0.0603   0.0157   0.1401  -0.0318   0.1519  -0.0373
 Columns 17 through 24:
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.0785  -0.0204   0.0439  -0.0100   0.0476  -0.0117   0.0523  -0.0136
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.2985  -0.0775  -0.0459   0.0104  -0.0498   0.0122  -0.0547   0.0142
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.7862        0        0        0        0        0        0        0
   0.0979   0.9874        0        0        0        0        0        0
  -0.2715   0.0705  -0.1378   0.0313  -0.1494   0.0367  -0.1642   0.0426
        0        0   0.2212   0.9752        0        0        0        0
        0        0  -0.7085   0.1607   0.6871        0        0        0
        0        0   0.1176  -0.0267   0.1276   0.9845        0        0
        0        0  -0.4077   0.0925  -0.4421   0.1085   0.7862        0
        0        0   0.0821  -0.0186   0.0891  -0.0219   0.0979   0.9874
   0.2325  -0.0603  -0.1600   0.0363  -0.1735   0.0426  -0.1907   0.0495
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
        0        0        0        0        0        0        0        0
   0.1670  -0.0433  -0.3621   0.0822  -0.3926   0.0964  -0.4316   0.1120
 Columns 25 through 30:
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.2520  -0.0572   0.2733  -0.0671   0.3004  -0.0780
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.0545  -0.0124   0.0590  -0.0145   0.0649  -0.0168
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
  -0.2001   0.0454  -0.2170   0.0533  -0.2385   0.0619
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
        0        0        0        0        0        0
   0.0896  -0.0203   0.0972  -0.0238   0.1068  -0.0277
   0.2212   0.9752        0        0        0        0
  -0.7085   0.1607   0.6871        0        0        0
   0.1176  -0.0267   0.1276   0.9845        0        0
  -0.4077   0.0925  -0.4421   0.1085   0.7862        0
   0.0821  -0.0186   0.0891  -0.0219   0.0979   0.9874
  -0.1619   0.0367  -0.1755   0.0431  -0.1929   0.0501

B =
        0
        0
        0
        0
        0
   0.2129
        0
        0
        0
        0
        0
  -0.0832
        0
        0
        0
        0
        0
   0.0492
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
   0.1043

C =
 Columns 1 through 7:
   0.811861  -0.184173   0.880250  -0.216071   0.967498  -0.251112   0.290452
 Columns 8 through 14:
  -0.065890   0.314919  -0.077302   0.346133  -0.089838   0.189488  -0.042986
 Columns 15 through 21:
   0.205450  -0.050431   0.225814  -0.058609  -0.414161   0.093954  -0.449048
 Columns 22 through 28:
   0.110226  -0.493557   0.128101   0.698039  -0.158352   0.756840  -0.185778
 Columns 29 and 30:
   0.831856  -0.215906

D = 0.2437
ABCD_nz_coefs = 286
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

