% schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd_symbolic_test.m
% Copyright (C) 2026 Robert G. Jenssen
%
% Create a symbolic version of the doubly pipelined anti-aliased Schur
% one-multiplier parallel all-pass filter. 

test_common;

pkg load symbolic

strf="schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd_symbolic_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-9;

%
% Example of a doubly pipelined anti-aliased parallel all-pass
% one-multiplier Schur lattice filter.
%
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_A1k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_A2k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_Aaa1k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_Aaa2k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_DA1k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_DA2k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_DAaa1k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_DAaa2k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_D2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_N2_coef;

A1k=A1k2; clear A1k2;
A1epsilon = schurOneMscale(A1k);
A2k=A2k2; clear A2k2;
A2epsilon = schurOneMscale(A2k);

Aaa1k = Aaa1k2; clear Aaa1k2;
Aaa1epsilon = schurOneMscale(Aaa1k);
Aaa2k = Aaa2k2; clear Aaa2k2;
Aaa2epsilon = schurOneMscale(Aaa2k);

DA1=DA1k2; clear DA1k2;
DA2=DA2k2; clear DA2k2;
Dpa=conv(DA1,DA2);
Npa=(conv(DA1,fliplr(DA2))+conv(DA2,fliplr(DA1)))/2;

DAaa1=DAaa1k2(1:5); clear DAaa1k2;
DAaa2=DAaa2k2(1:4); clear DAaa2k2;
Daa=conv(DAaa1,DAaa2);
Naa=(conv(DAaa1,fliplr(DAaa2))+conv(DAaa2,fliplr(DAaa1)))/2;

Daapa=conv(Daa,Dpa)(1:length(D2));
Naapa=conv(Naa,Npa)(1:length(N2));
if max(abs(Daapa-D2))>tol
  error("max(abs(Daapa-D2))>tol");
endif
if max(abs(Naapa-N2))>tol
  error("max(abs(Naapa-N2))>tol");
endif

[apA1,apB1,apC1,apD1,apA1k_0,apA1k_l] =  ...
  schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[apA2,apB2,apC2,apD2,apA2k_0,apA2k_l] = ...
  schurOneMAPlatticeDoublyPipelined2Abcd(A2k);

[apAaa1,apBaa1,apCaa1,apDaa1] = schurOneMAPlattice2Abcd(Aaa1k);
[apAaa2,apBaa2,apCaa2,apDaa2] = schurOneMAPlattice2Abcd(Aaa2k);

% Sanity checks
[~,chDA1] = Abcd2tf(apA1,apB1,apC1,apD1);
if max(abs(DA1-chDA1)) > tol
  error("max(abs(DA1-chDA1)) (%g) > tol(%g)", ...
        max(abs(DA1-chDA1)),tol);
endif
[~,chDA2] = Abcd2tf(apA2,apB2,apC2,apD2);
if max(abs(DA2-chDA2)) > tol
  error("max(abs(D21k-chDA2)) (%g) > tol(%g)", ...
        max(abs(DA2-chDA2)),tol);
endif
[~,chDAaa1] = Abcd2tf(apAaa1,apBaa1,apCaa1,apDaa1);
if max(abs(DAaa1(1:length(chDAaa1))-chDAaa1)) > tol
  error("max(abs(DAaa1(1_to_length(chDAaa1))--chDAaa1)) (%g) > tol(%g)", ...
        max(abs(DAaa1(1:length(chDAaa1))-chDAaa1)),tol);
endif
if max(abs(DAaa1((length(chDAaa1)+1):end))) > tol
  error("max(abs(DAaa1((length(chDAaa1)+1)_to_end))) (%g) > tol(%g)", ...
        max(abs(DAaa1((length(chDAaa1)+1):end))),tol);
endif
[~,chDAaa2] = Abcd2tf(apAaa2,apBaa2,apCaa2,apDaa2);
if max(abs(DAaa2(1:length(chDAaa2))-chDAaa2)) > tol
  error("max(abs(DAaa2(1_to_length(chDAaa2))-chDAaa2)) (%g) > tol(%g)", ...
        max(abs(DAaa2(1:length(chDAaa2))-chDAaa2)),tol);
endif
if max(abs(DAaa2((length(chDAaa2)+1):end))) > tol
  error("max(abs(DAaa2((length(chDAaa2)+1)_to_end))) (%g) > tol(%g)", ...
        max(abs(DAaa2((length(chDAaa2)+1):end))),tol);
endif

%
% Structure of a doubly pipelined anti-aliased parallel all-pass
% one-multiplier Schur lattice filter
%
% Parallel all-pass filter order
NA1k=length(A1k);
NA2k=length(A2k);
NDA1=length(DA1)-1;
NDA2=length(DA2)-1;
% Parallel all-pass low-pass filter 
difference=false;
% Anti-aliasing filter order
NAaa1k=length(Aaa1k);
NAaa2k=length(Aaa2k);
NDAaa1=length(DAaa1)-1;
NDAaa2=length(DAaa2)-1;

%
% Define symbols
%
str_syms="";
for l=1:NA1k
  str_syms=strcat(str_syms,sprintf(" sA1k%d",l));
endfor
for l=1:NA2k
  str_syms=strcat(str_syms,sprintf(" sA2k%d",l));
endfor
for l=1:NAaa1k
  str_syms=strcat(str_syms,sprintf(" sAaa1k%d sAaa1E%d",l,l));
endfor
for l=1:NAaa2k
  str_syms=strcat(str_syms,sprintf(" sAaa2k%d sAaa2E%d",l,l));
endfor
eval(sprintf("syms %s",str_syms));
for l=1:NA1k
  assume(sprintf("sA1k%d",l),"real");
endfor
for l=1:NA2k
  assume(sprintf("sA2k%d",l),"real");
endfor
for l=1:NAaa1k
  assume(sprintf("sAaa1k%d",l),"real");
  assume(sprintf("sAaa1E%d",l),"real");
endfor
for l=1:NAaa2k
  assume(sprintf("sAaa2k%d",l),"real");
  assume(sprintf("sAaa2E%d",l),"real");
endfor

%
% Find symbolic representation of the doubly-pipelined allpass filters
%

% Convert basis matrices to syms
sapA1k_0=sym(apA1k_0,"r");
for l=1:NA1k
  sapA1k_l{l}=sym(apA1k_l{l},"r");
endfor
sapB1=sym(apB1,"r");
sapC1=sym(apC1,"r");
sapD1=sym(apD1,"r");

sapA2k_0=sym(apA2k_0,"r");
for l=1:NA2k
  sapA2k_l{l}=sym(apA2k_l{l},"r");
endfor
sapB2=sym(apB2,"r");
sapC2=sym(apC2,"r");
sapD2=sym(apD2,"r");

% For A1k, modules 1 to NA1k have NDA1 states.
sapA1=sym("sapA1",[NDA1,NDA1]);
sapA1=sapA1k_0;
for l=1:NA1k,
  eval(sprintf("sapA1=sapA1+(sA1k%d*sapA1k_l{%d});",l,l));
endfor

% For A2k, modules 1 to NA2k have NDA2 states.
sapA2=sym("sapA2",[NDA2,NDA2]);
sapA2=sapA2k_0;
for l=1:NA2k,
  eval(sprintf("sapA2=sapA2+(sA2k%d*sapA2k_l{%d});",l,l));
endfor

% Construct the doubly pipelined parallel allpass filter
papA=[[sapA1, zeros(NDA1,NDA2)]; ...
      [zeros(NDA2,NDA1), sapA2]];
papB=[sapB1;sapB2];
if difference, m1=-1; else,  m1=1; endif;
papC=[sapC1,m1*sapC2]/2;
papD=(sapD1+(m1*sapD2))/2;
papABCD=[[papA,papB];[papC,papD]];

%
% Find symbolic representation of the anti-aliasing allpass filters
%
for p=1:2,
  eval(sprintf("N=NAaa%1dk;",p));
  % Modules 1 to Nk
  for l=1:N,
    eval(sprintf(["pAaa%1dM%d=[[-sAaa%1dk%d, 1+(sAaa%1dk%d*sAaa%1dE%d)];", ...
                  " [1-(sAaa%1dk%d*sAaa%1dE%d),sAaa%1dk%d]];"], ...
                 p,l,p,l,p,l,p,l,p,l,p,l,p,l));
    eval(sprintf(["sapAaa%1dM%d=[[eye(%d-1),zeros(%d-1,2),zeros(%d-1,N-%d)];",...
                  " [zeros(2,%d-1),pAaa%1dM%d,zeros(2,N-%d)]; ", ...
                  " [zeros(N-%d,%d-1),zeros(N-%d,2),eye(N-%d)]];"],
                 p,l,l,l,l,l, ...
                 l,p,l,l, ...
                 l,l,l,l));
  endfor
    
  % Generate the all-pass state variable description
  eval(sprintf("sapAaa%1dABCapDap=eye(N+1);",p,p));
  for l=1:N
    eval(sprintf("sapAaa%1dABCapDap=sapAaa%1dM%d*sapAaa%1dABCapDap;",p,p,l,p));
  endfor
  eval(sprintf("sapAaa%1dA=sapAaa%1dABCapDap(1:N,1:N);",p,p));
  eval(sprintf("sapAaa%1dB=sapAaa%1dABCapDap(1:N,N+1);",p,p));
  eval(sprintf("sapAaa%1dCap=sapAaa%1dABCapDap(N+1,1:N);",p,p));
  eval(sprintf("sapAaa%1dDap=sapAaa%1dABCapDap(N+1,N+1);",p,p));
endfor

%
% Construct the parallel allpass anti-aliasing filter
%
papAaa=[[sapAaa1A, zeros(rows(sapAaa1A),columns(sapAaa2A))]; ...
        [zeros(rows(sapAaa2A),columns(sapAaa1A)), sapAaa2A]];
papBaa=[sapAaa1B;sapAaa2B];
papCaa=[sapAaa1Cap,sapAaa2Cap]/2;
papDaa=(sapAaa1Dap+sapAaa2Dap)/2;
papABCDaa=[[papAaa,papBaa];[papCaa,papDaa]];

%
% Construct the series cascade filter
%
NA=rows(papA);
NAaa=rows(papAaa);
cpapABCD=[[papC,zeros(1,NAaa),papD]; ...
          [papA,zeros(NA,NAaa),papB]; ...
          [zeros(NAaa,NA),eye(NAaa),zeros(NAaa,1)]];
cpapABCDaa=[[zeros(NA,1),eye(NA,NA),zeros(NA,NAaa)]; ...
            [papBaa,zeros(NAaa,NA),papAaa]; ...
            [papDaa,zeros(1,NA),papCaa]];
ABCD=cpapABCDaa*cpapABCD;
% Compare
altABCD=[[papA,zeros(rows(papA),columns(papAaa)),papB]; ...
         [papBaa*papC,papAaa,papBaa*papD]; ...
         [papDaa*papC,papCaa,papDaa*papD]];
if any(any(value(ABCD-altABCD)))
  error("any(any(value(ABCD-altABCD)))");
endif

for l=1:NAaa1k,
  eval(sprintf("sAaa1E%d=vpa(Aaa1epsilon(l));",l)); 
endfor
for l=1:NAaa2k,
  eval(sprintf("sAaa2E%d=vpa(Aaa2epsilon(l));",l)); 
endfor
rEABCDaa=eval(cpapABCDaa);

%
% Sanity checks.
%

% Evaluate the symbolic version
for l=1:NA1k,
  eval(sprintf("sA1k%d=vpa(A1k(l));",l)); 
endfor
for l=1:NA2k,
  eval(sprintf("sA2k%d=vpa(A2k(l));",l)); 
endfor
for l=1:NAaa1k,
  eval(sprintf("sAaa1k%d=vpa(Aaa1k(l));",l)); 
  eval(sprintf("sAaa1E%d=vpa(Aaa1epsilon(l));",l)); 
endfor
for l=1:NAaa2k,
  eval(sprintf("sAaa2k%d=vpa(Aaa2k(l));",l)); 
  eval(sprintf("sAaa2E%d=vpa(Aaa2epsilon(l));",l)); 
endfor

% Check doubly-pipelined filter
rpapA=double(eval(papA));
rpapB=double(eval(papB));
rpapC=double(eval(papC));
rpapD=double(eval(papD));
[rNpa,rDpa]=Abcd2tf(rpapA,rpapB,rpapC,rpapD);
if max(abs(Dpa-rDpa))>tol
  error("max(abs(Dpa-rDpa))>tol");
endif
if max(abs(Npa-rNpa))>tol
  error("max(abs(Npa-rNpa))>tol");
endif

% Check anti-aliasing filter
rpapAaa=double(eval(papAaa));
rpapBaa=double(eval(papBaa));
rpapCaa=double(eval(papCaa));
rpapDaa=double(eval(papDaa));
[rNaa,rDaa]=Abcd2tf(rpapAaa,rpapBaa,rpapCaa,rpapDaa);
if max(abs(Daa-rDaa))>tol
  error("max(abs(Daa-rDaa))>tol");
endif
if max(abs(Naa-rNaa))>tol
  error("max(abs(Naa-rNaa))>tol");
endif

% Check the transfer function of the cascaded filter
rNaapa=conv(rNaa,rNpa);
rDaapa=conv(rDaa,rDpa);
if max(abs(D2-rDaapa))>tol
  error("max(abs(D2-rDaaap))>tol");
endif
if max(abs(N2-rNaapa))>tol
  error("max(abs(N2-rNaapa))>tol");
endif

rABCD=double(eval(cpapABCDaa))*double(eval(cpapABCD));
RA=1:(NA+NAaa);
RB=1:(NA+NAaa);
RC=1:(NA+NAaa);
RD=(NA+NAaa+1);
[rN,rD]=Abcd2tf(rABCD(RA,RA),rABCD(RB,RD),rABCD(RD,RC),rABCD(RD,RD));

if max(abs(rN-N2)) > tol
  error("max(abs(rN-N2)) > tol");
endif
if max(abs(rD-D2)) > tol
  error("max(abs(rD-D2)) > tol");
endif

rpapA=double(eval(papA));
rpapB=double(eval(papB));
rpapC=double(eval(papC));
rpapD=double(eval(papD));
rpapAaa=double(eval(papAaa));
rpapBaa=double(eval(papBaa));
rpapCaa=double(eval(papCaa));
rpapDaa=double(eval(papDaa));

raltABCD=[ [rpapA,zeros(rows(rpapA),columns(rpapAaa)),rpapB]; ...
           [rpapBaa*rpapC,rpapAaa,rpapBaa*rpapD]; ...
           [rpapDaa*rpapC,rpapCaa,rpapDaa*rpapD] ];

if max(max(abs(raltABCD-rABCD))) > tol
  error("max(max(abs(raltABCD-rABCD))) > tol");
endif

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
