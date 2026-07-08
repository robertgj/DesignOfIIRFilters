#!/bin/sh

prog=schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_allocsd_test.m
depends="test/schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_allocsd_test.m \
test_common.m \
../schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_A1k2_coef.m \
../schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_A2k2_coef.m \
../schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_Aaa1k2_coef.m \
../schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_Aaa2k2_coef.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Ito.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedP.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedT.m \
schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw.m \
schurOneMPAlatticeDoublyPipelinedEsq.m \
schurOneMPAlatticeDoublyPipelinedAsq.m \
schurOneMPAlatticeDoublyPipelinedP.m \
schurOneMPAlatticeDoublyPipelinedT.m \
schurOneMPAlatticeDoublyPipelineddAsqdw.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticedAsqdw.m \
schurOneMAPlatticeDoublyPipelined2Abcd.m \
schurOneMAPlattice2Abcd.m \
schurOneMscale.m KW.m SDadders.m \
print_polynomial.m H2T.m H2P.m H2Asq.m H2dAsqdw.m flt2SD.m x2nextra.m \
bin2SDul.m \
schurOneMAPlatticeDoublyPipelined2H.oct \
schurdecomp.oct schurexpand.oct bin2SD.oct bin2SPT.oct Abcd2tf.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct schurOneMAPlattice2H.oct \
Abcd2H.oct complex_zhong_inverse.oct qroots.oct"

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

Exact,minimum pass-band amplitude (0 to 0.150)= -0.060dB
Exact,maximum stop-band amplitude(0.175 to 0.50)=-70.538dB
Exact,maximum pass-band phase error(0 to 0.100)=0.000499(rad./pi)
Exact,maximum pass-band delay error(0 to 0.100)=0.09991(samples)
Exact filter noise gain=  4.463
Round,nbits=10,ng=  4.464

Round,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.061dB
Round,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -56.177dB
Round,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.000501(rad./pi)
Round,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.10897(samples)
Round,nbits=11,ng=  4.463

Round,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Round,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -60.528dB
Round,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.001091(rad./pi)
Round,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.10302(samples)
Round,nbits=12,ng=  4.463

Round,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Round,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -69.310dB
Round,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.000526(rad./pi)
Round,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.10147(samples)
Round,nbits=13,ng=  4.463

Round,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Round,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -66.321dB
Round,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.000504(rad./pi)
Round,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.09945(samples)
Round,nbits=14,ng=  4.463

Round,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Round,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -69.481dB
Round,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.000498(rad./pi)
Round,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.09880(samples)
Round,nbits=15,ng=  4.463

Round,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Round,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -70.046dB
Round,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.000537(rad./pi)
Round,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.09957(samples)
Round,nbits=16,ng=  4.463

Round,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Round,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -70.344dB
Round,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.000497(rad./pi)
Round,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.09993(samples)

S-D,ndigits=3,nbits=10,ng=  4.466
Lim,ndigits=3,nbits=10,ng=  4.499
Ito,ndigits=3,nbits=10,ng=  4.489
S-D,ndigits=3,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.076dB
S-D,ndigits=3,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -41.205dB
S-D,ndigits=3,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.006232 (rad./pi)
S-D,ndigits=3,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.10564 (samples)
Lim,ndigits=3,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.087dB
Lim,ndigits=3,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -22.535dB
Lim,ndigits=3,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.030151 (rad./pi)
Lim,ndigits=3,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.35812 (samples)
Ito,ndigits=3,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.197dB
Ito,ndigits=3,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -40.683dB
Ito,ndigits=3,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.005209 (rad./pi)
Ito,ndigits=3,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.08778 (samples)

S-D,ndigits=3,nbits=11,ng=  4.466
Lim,ndigits=3,nbits=11,ng=  4.498
Ito,ndigits=3,nbits=11,ng=  4.468
S-D,ndigits=3,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.076dB
S-D,ndigits=3,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -41.205dB
S-D,ndigits=3,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.006090 (rad./pi)
S-D,ndigits=3,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.09797 (samples)
Lim,ndigits=3,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.081dB
Lim,ndigits=3,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -22.537dB
Lim,ndigits=3,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.030589 (rad./pi)
Lim,ndigits=3,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.36882 (samples)
Ito,ndigits=3,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.094dB
Ito,ndigits=3,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -42.293dB
Ito,ndigits=3,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.003490 (rad./pi)
Ito,ndigits=3,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.11516 (samples)

S-D,ndigits=3,nbits=12,ng=  4.466
Lim,ndigits=3,nbits=12,ng=  4.498
Ito,ndigits=3,nbits=12,ng=  4.469
S-D,ndigits=3,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.073dB
S-D,ndigits=3,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -41.203dB
S-D,ndigits=3,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.007103 (rad./pi)
S-D,ndigits=3,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.18409 (samples)
Lim,ndigits=3,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.078dB
Lim,ndigits=3,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -22.539dB
Lim,ndigits=3,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.030467 (rad./pi)
Lim,ndigits=3,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.36785 (samples)
Ito,ndigits=3,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.089dB
Ito,ndigits=3,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -42.291dB
Ito,ndigits=3,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.004623 (rad./pi)
Ito,ndigits=3,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.18323 (samples)

S-D,ndigits=3,nbits=13,ng=  4.466
Lim,ndigits=3,nbits=13,ng=  4.498
Ito,ndigits=3,nbits=13,ng=  4.468
S-D,ndigits=3,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.073dB
S-D,ndigits=3,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -41.406dB
S-D,ndigits=3,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.007133 (rad./pi)
S-D,ndigits=3,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.18458 (samples)
Lim,ndigits=3,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.078dB
Lim,ndigits=3,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -22.539dB
Lim,ndigits=3,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.028758 (rad./pi)
Lim,ndigits=3,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.33501 (samples)
Ito,ndigits=3,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.073dB
Ito,ndigits=3,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -42.288dB
Ito,ndigits=3,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.005085 (rad./pi)
Ito,ndigits=3,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.11930 (samples)

S-D,ndigits=3,nbits=14,ng=  4.466
Lim,ndigits=3,nbits=14,ng=  4.498
Ito,ndigits=3,nbits=14,ng=  4.467
S-D,ndigits=3,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.073dB
S-D,ndigits=3,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -41.304dB
S-D,ndigits=3,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.007118 (rad./pi)
S-D,ndigits=3,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.18434 (samples)
Lim,ndigits=3,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.077dB
Lim,ndigits=3,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -22.539dB
Lim,ndigits=3,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.028836 (rad./pi)
Lim,ndigits=3,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.33592 (samples)
Ito,ndigits=3,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.078dB
Ito,ndigits=3,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -42.288dB
Ito,ndigits=3,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.006010 (rad./pi)
Ito,ndigits=3,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.14030 (samples)

S-D,ndigits=3,nbits=15,ng=  4.466
Lim,ndigits=3,nbits=15,ng=  4.498
Ito,ndigits=3,nbits=15,ng=  4.467
S-D,ndigits=3,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.073dB
S-D,ndigits=3,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -41.406dB
S-D,ndigits=3,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.007133 (rad./pi)
S-D,ndigits=3,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.18458 (samples)
Lim,ndigits=3,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.077dB
Lim,ndigits=3,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -22.539dB
Lim,ndigits=3,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.028836 (rad./pi)
Lim,ndigits=3,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.33592 (samples)
Ito,ndigits=3,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.078dB
Ito,ndigits=3,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -42.288dB
Ito,ndigits=3,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.006010 (rad./pi)
Ito,ndigits=3,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.14030 (samples)

S-D,ndigits=3,nbits=16,ng=  4.466
Lim,ndigits=3,nbits=16,ng=  4.498
Ito,ndigits=3,nbits=16,ng=  4.467
S-D,ndigits=3,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.073dB
S-D,ndigits=3,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -41.304dB
S-D,ndigits=3,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.007118 (rad./pi)
S-D,ndigits=3,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.18434 (samples)
Lim,ndigits=3,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.078dB
Lim,ndigits=3,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -22.539dB
Lim,ndigits=3,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.028812 (rad./pi)
Lim,ndigits=3,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.33631 (samples)
Ito,ndigits=3,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.078dB
Ito,ndigits=3,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -42.288dB
Ito,ndigits=3,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.006010 (rad./pi)
Ito,ndigits=3,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.14030 (samples)

S-D,ndigits=4,nbits=10,ng=  4.463
Lim,ndigits=4,nbits=10,ng=  4.470
Ito,ndigits=4,nbits=10,ng=  4.489
S-D,ndigits=4,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.058dB
S-D,ndigits=4,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -56.859dB
S-D,ndigits=4,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.001046 (rad./pi)
S-D,ndigits=4,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.12158 (samples)
Lim,ndigits=4,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.066dB
Lim,ndigits=4,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -31.964dB
Lim,ndigits=4,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.004393 (rad./pi)
Lim,ndigits=4,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.18805 (samples)
Ito,ndigits=4,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.192dB
Ito,ndigits=4,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -40.682dB
Ito,ndigits=4,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.003823 (rad./pi)
Ito,ndigits=4,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.06261 (samples)

S-D,ndigits=4,nbits=11,ng=  4.462
Lim,ndigits=4,nbits=11,ng=  4.469
Ito,ndigits=4,nbits=11,ng=  4.467
S-D,ndigits=4,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.058dB
S-D,ndigits=4,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -60.553dB
S-D,ndigits=4,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.002115 (rad./pi)
S-D,ndigits=4,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.10976 (samples)
Lim,ndigits=4,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.071dB
Lim,ndigits=4,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -31.967dB
Lim,ndigits=4,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.003752 (rad./pi)
Lim,ndigits=4,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.17285 (samples)
Ito,ndigits=4,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.081dB
Ito,ndigits=4,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -42.287dB
Ito,ndigits=4,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.006644 (rad./pi)
Ito,ndigits=4,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.15825 (samples)

S-D,ndigits=4,nbits=12,ng=  4.463
Lim,ndigits=4,nbits=12,ng=  4.469
Ito,ndigits=4,nbits=12,ng=  4.467
S-D,ndigits=4,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.057dB
S-D,ndigits=4,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -56.860dB
S-D,ndigits=4,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.001652 (rad./pi)
S-D,ndigits=4,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.10481 (samples)
Lim,ndigits=4,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.070dB
Lim,ndigits=4,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -31.968dB
Lim,ndigits=4,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.003999 (rad./pi)
Lim,ndigits=4,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.17305 (samples)
Ito,ndigits=4,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.077dB
Ito,ndigits=4,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -42.287dB
Ito,ndigits=4,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.006068 (rad./pi)
Ito,ndigits=4,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.14513 (samples)

S-D,ndigits=4,nbits=13,ng=  4.463
Lim,ndigits=4,nbits=13,ng=  4.469
Ito,ndigits=4,nbits=13,ng=  4.461
S-D,ndigits=4,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.062dB
S-D,ndigits=4,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -52.037dB
S-D,ndigits=4,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.001243 (rad./pi)
S-D,ndigits=4,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.07694 (samples)
Lim,ndigits=4,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.069dB
Lim,ndigits=4,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -31.968dB
Lim,ndigits=4,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.004146 (rad./pi)
Lim,ndigits=4,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.17273 (samples)
Ito,ndigits=4,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.073dB
Ito,ndigits=4,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -43.063dB
Ito,ndigits=4,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.001519 (rad./pi)
Ito,ndigits=4,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.12876 (samples)

S-D,ndigits=4,nbits=14,ng=  4.463
Lim,ndigits=4,nbits=14,ng=  4.469
Ito,ndigits=4,nbits=14,ng=  4.463
S-D,ndigits=4,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.062dB
S-D,ndigits=4,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -52.024dB
S-D,ndigits=4,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.001216 (rad./pi)
S-D,ndigits=4,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.07433 (samples)
Lim,ndigits=4,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.069dB
Lim,ndigits=4,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -31.968dB
Lim,ndigits=4,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.004080 (rad./pi)
Lim,ndigits=4,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.17101 (samples)
Ito,ndigits=4,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.062dB
Ito,ndigits=4,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -52.781dB
Ito,ndigits=4,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.001651 (rad./pi)
Ito,ndigits=4,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.09616 (samples)

S-D,ndigits=4,nbits=15,ng=  4.463
Lim,ndigits=4,nbits=15,ng=  4.469
Ito,ndigits=4,nbits=15,ng=  4.463
S-D,ndigits=4,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.062dB
S-D,ndigits=4,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -52.024dB
S-D,ndigits=4,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.001198 (rad./pi)
S-D,ndigits=4,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.07437 (samples)
Lim,ndigits=4,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.069dB
Lim,ndigits=4,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -31.967dB
Lim,ndigits=4,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.004150 (rad./pi)
Lim,ndigits=4,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.17085 (samples)
Ito,ndigits=4,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.062dB
Ito,ndigits=4,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -52.781dB
Ito,ndigits=4,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.001642 (rad./pi)
Ito,ndigits=4,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.09671 (samples)

S-D,ndigits=4,nbits=16,ng=  4.463
Lim,ndigits=4,nbits=16,ng=  4.469
Ito,ndigits=4,nbits=16,ng=  4.463
S-D,ndigits=4,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.062dB
S-D,ndigits=4,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -51.521dB
S-D,ndigits=4,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.001232 (rad./pi)
S-D,ndigits=4,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.07602 (samples)
Lim,ndigits=4,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.069dB
Lim,ndigits=4,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -31.967dB
Lim,ndigits=4,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.004085 (rad./pi)
Lim,ndigits=4,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.17108 (samples)
Ito,ndigits=4,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.061dB
Ito,ndigits=4,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -52.785dB
Ito,ndigits=4,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.000783 (rad./pi)
Ito,ndigits=4,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.10029 (samples)

S-D,ndigits=5,nbits=10,ng=  4.464
Lim,ndigits=5,nbits=10,ng=  4.466
Ito,ndigits=5,nbits=10,ng=  4.469
S-D,ndigits=5,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.061dB
S-D,ndigits=5,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -56.177dB
S-D,ndigits=5,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.000501 (rad./pi)
S-D,ndigits=5,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.10897 (samples)
Lim,ndigits=5,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.061dB
Lim,ndigits=5,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -43.279dB
Lim,ndigits=5,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.001851 (rad./pi)
Lim,ndigits=5,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.11579 (samples)
Ito,ndigits=5,nbits=10,minimum pass-band amplitude(0 to 0.150) =  -0.086dB
Ito,ndigits=5,nbits=10,maximum stop-band amplitude(0.175 to 0.50) = -42.300dB
Ito,ndigits=5,nbits=10,maximum pass-band phase error(0 to 0.100) = 0.002759 (rad./pi)
Ito,ndigits=5,nbits=10,maximum pass-band delay error(0 to 0.100) = 0.10146 (samples)

S-D,ndigits=5,nbits=11,ng=  4.463
Lim,ndigits=5,nbits=11,ng=  4.465
Ito,ndigits=5,nbits=11,ng=  4.467
S-D,ndigits=5,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
S-D,ndigits=5,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -60.528dB
S-D,ndigits=5,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.001091 (rad./pi)
S-D,ndigits=5,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.10302 (samples)
Lim,ndigits=5,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Lim,ndigits=5,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -42.188dB
Lim,ndigits=5,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.001737 (rad./pi)
Lim,ndigits=5,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.10397 (samples)
Ito,ndigits=5,nbits=11,minimum pass-band amplitude(0 to 0.150) =  -0.078dB
Ito,ndigits=5,nbits=11,maximum stop-band amplitude(0.175 to 0.50) = -42.288dB
Ito,ndigits=5,nbits=11,maximum pass-band phase error(0 to 0.100) = 0.005710 (rad./pi)
Ito,ndigits=5,nbits=11,maximum pass-band delay error(0 to 0.100) = 0.14342 (samples)

S-D,ndigits=5,nbits=12,ng=  4.463
Lim,ndigits=5,nbits=12,ng=  4.465
Ito,ndigits=5,nbits=12,ng=  4.461
S-D,ndigits=5,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
S-D,ndigits=5,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -69.310dB
S-D,ndigits=5,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.000526 (rad./pi)
S-D,ndigits=5,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.10147 (samples)
Lim,ndigits=5,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Lim,ndigits=5,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -43.283dB
Lim,ndigits=5,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.001955 (rad./pi)
Lim,ndigits=5,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.10293 (samples)
Ito,ndigits=5,nbits=12,minimum pass-band amplitude(0 to 0.150) =  -0.073dB
Ito,ndigits=5,nbits=12,maximum stop-band amplitude(0.175 to 0.50) = -43.063dB
Ito,ndigits=5,nbits=12,maximum pass-band phase error(0 to 0.100) = 0.001575 (rad./pi)
Ito,ndigits=5,nbits=12,maximum pass-band delay error(0 to 0.100) = 0.13362 (samples)

S-D,ndigits=5,nbits=13,ng=  4.463
Lim,ndigits=5,nbits=13,ng=  4.465
Ito,ndigits=5,nbits=13,ng=  4.463
S-D,ndigits=5,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.059dB
S-D,ndigits=5,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -64.031dB
S-D,ndigits=5,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.000488 (rad./pi)
S-D,ndigits=5,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.10103 (samples)
Lim,ndigits=5,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.059dB
Lim,ndigits=5,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -42.418dB
Lim,ndigits=5,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.001900 (rad./pi)
Lim,ndigits=5,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.09985 (samples)
Ito,ndigits=5,nbits=13,minimum pass-band amplitude(0 to 0.150) =  -0.062dB
Ito,ndigits=5,nbits=13,maximum stop-band amplitude(0.175 to 0.50) = -52.781dB
Ito,ndigits=5,nbits=13,maximum pass-band phase error(0 to 0.100) = 0.001752 (rad./pi)
Ito,ndigits=5,nbits=13,maximum pass-band delay error(0 to 0.100) = 0.09815 (samples)

S-D,ndigits=5,nbits=14,ng=  4.463
Lim,ndigits=5,nbits=14,ng=  4.465
Ito,ndigits=5,nbits=14,ng=  4.463
S-D,ndigits=5,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
S-D,ndigits=5,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -66.670dB
S-D,ndigits=5,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.000502 (rad./pi)
S-D,ndigits=5,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.09973 (samples)
Lim,ndigits=5,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Lim,ndigits=5,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -42.302dB
Lim,ndigits=5,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.001901 (rad./pi)
Lim,ndigits=5,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.09922 (samples)
Ito,ndigits=5,nbits=14,minimum pass-band amplitude(0 to 0.150) =  -0.061dB
Ito,ndigits=5,nbits=14,maximum stop-band amplitude(0.175 to 0.50) = -52.785dB
Ito,ndigits=5,nbits=14,maximum pass-band phase error(0 to 0.100) = 0.000863 (rad./pi)
Ito,ndigits=5,nbits=14,maximum pass-band delay error(0 to 0.100) = 0.09762 (samples)

S-D,ndigits=5,nbits=15,ng=  4.463
Lim,ndigits=5,nbits=15,ng=  4.465
Ito,ndigits=5,nbits=15,ng=  4.463
S-D,ndigits=5,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
S-D,ndigits=5,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -67.466dB
S-D,ndigits=5,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.000529 (rad./pi)
S-D,ndigits=5,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.09995 (samples)
Lim,ndigits=5,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Lim,ndigits=5,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -42.417dB
Lim,ndigits=5,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.001959 (rad./pi)
Lim,ndigits=5,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.10001 (samples)
Ito,ndigits=5,nbits=15,minimum pass-band amplitude(0 to 0.150) =  -0.061dB
Ito,ndigits=5,nbits=15,maximum stop-band amplitude(0.175 to 0.50) = -52.785dB
Ito,ndigits=5,nbits=15,maximum pass-band phase error(0 to 0.100) = 0.000777 (rad./pi)
Ito,ndigits=5,nbits=15,maximum pass-band delay error(0 to 0.100) = 0.10059 (samples)

S-D,ndigits=5,nbits=16,ng=  4.463
Lim,ndigits=5,nbits=16,ng=  4.465
Ito,ndigits=5,nbits=16,ng=  4.462
S-D,ndigits=5,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
S-D,ndigits=5,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -68.132dB
S-D,ndigits=5,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.000524 (rad./pi)
S-D,ndigits=5,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.10010 (samples)
Lim,ndigits=5,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Lim,ndigits=5,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -42.302dB
Lim,ndigits=5,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.001896 (rad./pi)
Lim,ndigits=5,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.10024 (samples)
Ito,ndigits=5,nbits=16,minimum pass-band amplitude(0 to 0.150) =  -0.060dB
Ito,ndigits=5,nbits=16,maximum stop-band amplitude(0.175 to 0.50) = -65.263dB
Ito,ndigits=5,nbits=16,maximum pass-band phase error(0 to 0.100) = 0.000640 (rad./pi)
Ito,ndigits=5,nbits=16,maximum pass-band delay error(0 to 0.100) = 0.09972 (samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlatticePipelined_bandpass_allocsd_test"

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
