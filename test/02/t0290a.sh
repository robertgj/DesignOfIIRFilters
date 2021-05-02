#!/bin/sh

prog=svd_test.m
depends=""
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
# Test files
#
cat > b1.bin.uue << 'EOF'
begin 664 b1.bin
M*AP%^EO#>C^GZ0ZYR$0Y/_EA%@/.H54_ZUND&\J?8;^@U"R!IMV!OSNF&S3\
MV7^_DWH+69<ZB;\I1PHT7@>2OQ]`F&LV"Y._]8>S:6N)G;_B%O7-?66./^[(
MQ<RA09(_L>D.N<A$.3\"UME.H-%V/UG3WTOI:VT__%)96`Y:;;^YA?*XZCZ,
MOV52UD<EN'"_\VCWD7I)@K^6UD9?-WZ-O]3_H92#?I._H*;4%)@9E;\?]UC0
ML#:'/X+;_9-.-I$_^F$6`\ZA53]<T]]+Z6MM/W,P\1A0FIT_[BQRZ;H-BK^M
M-Q$ES'VAOX7(N^N._HJ_HM,`LZT$EK^OB^>PUK:CO_^<K%<F-JF_&!RX)6`A
ME;]L.B1N]9F>/[M@;-%5P*<_ZUND&\J?8;\!4UE8#EIMO_$L<NFZ#8J_0O::
M64Z[IS_E3*'`)TZGO]='L8I:HYF_2$"Z,KW#G;]C!?9X&:2AO\CYH#<!5*&_
M1(J&<A]<H#^(;O*6!AZA/S@/\K?RG:$_H-0L@:;=@;^\A?*XZCZ,OZLW$27,
M?:&_Y4RAP"=.I[_UW=NG_(S0/W[+SN,J]K*_#@O($33RK;_&O_*NG>FLOX+W
M.#^-(;&_/$YNJH5DQC_S/8+P.?BJ/]AXO5825K`_>Z8;-/S9?[]U4M9');AP
MOYW(N^N._HJ_X4>QBEJCF;^-R\[C*O:ROX)FA\(]"2!`9UM)@Y.N`T"<S;YX
MESSUOWJ$0_!D)`'`]$&V^T-L%\`PW[B$NQ[)/^&@G"PA0_X_FGH+69<ZB;_Q
M:/>1>DF"OZW3`+.M!):_3D"Z,KW#G;\:"\@1-/*MOV1;28.3K@-`ZP<]/*K(
M#$!TNLXV`J'M/](3\23?>?2_N+2'Y<3"!\#`%H'^86H%P)[O^E%+6^,_+D<*
M-%X'DK^6UD9?-WZ-OZV+Y[#6MJ._9`7V>!FDH;_/O_*NG>FLOYW-OGB7//6_
M>+K.-@*A[3]:.+7G`>D40+5*W'@'4!!`3G!U$_Z/\#\H]U:N`)D-P-A`\9>%
ML1/`)D"8:S8+D[_2_Z&4@WZ3O_^<K%<F-JF_R_F@-P%4H;]_]S@_C2&QOWJ$
M0_!D)`'`TQ/Q)-]Y]+^V2MQX!U`00$^/H=@);"5`WS[PW31N`4#-^Z^SE(_?
MOU`-S/)"\R'`^X>S:6N)G;^?IM04F!F5OQL<N"5@(96_2HJ&<A]<H#]`3FZJ
MA63&/_-!MOM#;!?`M;2'Y<3"!\!9<'43_H_P/]T^\-TT;@%`$*Z?"-88%D"<
MRRJ/)4'=/Z%B=;$FKOV_XQ;US7UECC\B]UC0L#:'/VXZ)&[UF9X_AV[RE@8>
MH3\"/H+P.?BJ/T#?N(2['LD_P!:!_F%J!<`N]U:N`)D-P,?[K[.4C]^_Q,LJ
MCR5!W3\DLA[+/^X10/8BG]\B2/H_[,C%S*%!DC]_V_V33C:1/[Q@;-%5P*<_
M-P_RM_*=H3_:>+U6$E:P/]R@G"PA0_X_F._Z44M;XS_70/&7A;$3P%`-S/)"
;\R'`FF)UL2:N_;_N(I_?(DCZ/UJ)'RN&=B!`
`
end
EOF
if [ $? -ne 0 ]; then echo "Failed output cat b1.bin.uue"; fail; fi
uudecode b1.bin.uue
if [ $? -ne 0 ]; then echo "Failed uudecode b1.bin.uue"; fail; fi

cat > svd_test.m << 'EOF'
format hex
svd_driver ("gesvd");
fid=fopen("b1.bin","rb");
[b1,cnt]=fread(fid,[12,12],"float64");
fclose(fid);
for k=1:100
  [u1,s1,v1]=svd(b1);
  u1(1,2)
endfor
EOF
if [ $? -ne 0 ]; then echo "Failed output cat svd_test.m"; fail; fi

#
# the output should look like this
#
cat > test.ok << 'EOF'
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
ans = bf4bf7a331fb18d2
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb" ; fail ; fi

#
# this much worked
#
pass
