% johansson_cascade_allpass_bandstop_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("johansson_cascade_allpass_bandstop_test.diary");
delete("johansson_cascade_allpass_bandstop_test.diary.tmp");
diary johansson_cascade_allpass_bandstop_test.diary.tmp

maxiter=2000
tol=1e-8
ctol=1e-8
verbose=false
strf="johansson_cascade_allpass_bandstop_test";

% Band-stopfilter specification
M=6,fapl=0.15,fasl=0.2,fasu=0.25,fapu=0.3
delta_p=5e-6
delta_s=delta_p
Fap=0.016

% Frequencies
nf=5000;
wa=(0:nf)'*pi/nf;
napl=ceil(fapl*nf/0.5)+1;
nasl=floor(fasl*nf/0.5)+1;
nasu=ceil(fasu*nf/0.5)+1;
napu=floor(fapu*nf/0.5)+1;
% Sanity check
nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...
         nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];
printf("nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...\n");
printf("         nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];\n");
printf("nchk=[     ");printf("%d ",nchk(1:7));printf(" ... \n");
printf("             ");printf("%d ",nchk(8:end));printf("];\n");
printf("wa(nchk)=[ ");printf("%g ",wa(nchk(1:7))*0.5/pi);printf(" ... \n");
printf("             ");printf("%g ",wa(nchk(8:end))*0.5/pi);printf("]*2*pi;\n");

%
% Step 1 : design FIR filter
%
% Desired low-pass magnitude response
Wap=10;Wat=tol;Was=1;
nFap=ceil(Fap*nf/0.5)+1;
Fas=0.5-Fap;
nFas=floor(Fas*nf/0.5)+1;
Ad=[(1-tol)*ones(nFap,1);zeros(nf-nFap+1,1)];
Adu=[(1-tol)*ones(nFas-1,1);delta_s*ones(nf-nFas+2,1)];
Adl=[(1-delta_p)*ones(nFap,1);zeros(nf-nFap+1,1)];
Wa=[Wap*ones(nFap,1);Wat*ones(nFas-nFap-1,1);Was*ones(nf-nFas+2,1)]; 
na=[1 nFap nFas length(wa)];
% Sanity check
nachk=[1, nFap-1,nFap,nFap+1,nFas-1,nFas,nFas+1,nf+1];
printf("nachk=[1, nFap-1,nFap,nFap+1,nFas-1,nFas,nFas+1,nf+1];\n");
printf("nachk=[ ");printf("%d ",nachk);printf("%d ",nachk);printf("];\n");
printf("wa(nachk)=[  ");printf("%g ",wa(nachk)*0.5/pi);printf("]*2*pi;\n");
printf("Ad(nachk)=[  ");printf("%g ",Ad(nachk));printf("];\n");
printf("Adu(nachk)=[ ");printf("%g ",Adu(nachk));printf("];\n");
printf("Adl(nachk)=[ ");printf("%g ",Adl(nachk));printf("];\n");
printf("Wa(nachk)=[  ");printf("%g ",Wa(nachk));printf("];\n");

% Make an initial low pass filter
f0=remez(M,[0 (5*Fap) (0.5-(5*Fap)) 0.5]*2,[1 1 0 0]);
fM0=f0(1:((M/2)+1));
fM_active=1:length(fM0);

% Find SLB solution
[fM1,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRsymmetric_slb(@directFIRsymmetric_socp_mmse, ...
                         fM0,fM_active,na,wa,Ad,Adu,Adl,Wa, ...
                         maxiter,tol,ctol,verbose);
if feasible==false
  error("fM1 not feasible");
endif
f1=[fM1;fM1((end-1):-1:1)];

% Plot FIR response
Hf=freqz(f1,1,wa);
subplot(211);
plot(wa(1:nFap)*0.5/pi,20*log10(abs(Hf(1:nFap))));
axis([0 Fap -50e-6 0]);
ylabel("Amplitude(dB)");
grid("on");
title("Johansson-and-Saram\\\"{a}ki FIR pass-band and stop-band responses");
subplot(212);
plot(wa(nFas:end)*0.5/pi,20*log10(abs(Hf(nFas:end))));
axis([Fas 0.5 -150 -100]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_fir"),"-dpdflatex");
close

%
% Step 2 : design an all-pass transformation
%
% Low-pass prototype
Delta_p=1-cos(pi*Fap);
Delta_s=cos(pi*Fas);
[lpB,lpA]=ellip(3,-20*log10(1-Delta_p),-20*log10(Delta_s),0.25);
Hlp=freqz(lpB,lpA,wa);
% Band-stop filter
phi=[fasl fasu];
p=phi2p(phi);
[bsB,bsA]=tfp2g(lpB,lpA,p,1);
% Parallel all-pass decomposition
[lpA0,lpA1]=tf2pa(lpB,lpA,tol);
[~,bsA0]=tfp2g(flipud(lpA0(:)),lpA0(:),p,1);
[~,bsA1]=tfp2g(flipud(lpA1(:)),lpA1(:),p,1);
HbsA0=freqz(flipud(bsA0(:)),bsA0(:),wa);
HbsA1=freqz(flipud(bsA1(:)),bsA1(:),wa);
Hbs=(HbsA0+HbsA1)/2;
plot(wa*0.5/pi,20*log10(abs(Hbs)));
axis([0 0.5 -30 1]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
title("Johansson-and-Saram\\\"{a}ki parallel all-pass band-stop IIR response");
print(strcat(strf,"_iir"),"-dpdflatex");
close
ax=plotyy(wa*0.5/pi,20*log10(abs(Hbs)), ...
          wa(nasl:nasu)*0.5/pi,20*log10(abs(Hbs(nasl:nasu))));
axis(ax(1),[0 0.5 -0.012 0]);
axis(ax(2),[0 0.5 -30 -24]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
title("Johansson-and-Saram\\\"{a}ki parallel all-pass band-stop IIR response");
print(strcat(strf,"_iir_dual"),"-dpdflatex");
close

%
% Step 3: All-pass transformation of the FIR filter
%
HbsA0M=cell(M+1);
HbsA0M{1}=ones(size(HbsA0));
for k=2:M+1,
  HbsA0M{k}=HbsA0M{k-1}.*HbsA0;
endfor
HbsA1M=cell(M+1);
HbsA1M{M+1}=ones(size(HbsA1));
for k=M:-1:1,
  HbsA1M{k}=HbsA1M{k+1}.*HbsA1;
endfor
H=zeros(size(Hbs));
for k=1:M+1,
  H=H+(f1(k)*(HbsA0M{k}.*HbsA1M{k}));
endfor
Hc=(HbsA0M{(M/2)+1}.*HbsA1M{(M/2)+1})-H;

% Check complementary all-pass response
if max(abs(abs(H+Hc)-1)) > 100*eps
  error("max(abs(abs(H+Hc)-1))(%g) > 100*eps", max(abs(abs(H+Hc)-1)));
endif

% Check complementary magnitude response
if max(abs(abs(H)+abs(Hc)-1)) > 100*eps
  error("max(abs(abs(H)+abs(Hc)-1))(%g) > 100*eps", max(abs(abs(H)+abs(Hc)-1)));
endif

% Plot magnitude responses
subplot(111);
plot(wa*0.5/pi,20*log10(abs([H Hc])));
axis([0 0.5 -120 5]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title("Johansson-and-Saram\\\"{a}ki band-stop complementary responses");
print(strcat(strf,"_comp"),"-dpdflatex");
close
subplot(211);
plot(wa*0.5/pi,20*log10(abs([H Hc])));
axis([0 0.5 -5e-5 0]);
ylabel("Amplitude(dB)");
grid("on");
title("Johansson-and-Saram\\\"{a}ki band-stop complementary responses");
subplot(212);
plot(wa*0.5/pi,20*log10(abs([H Hc])));
axis([0 0.5 -110 -105]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_comp_dual"),"-dpdflatex");
close

% Compare with zero-phase amplitude
Fr=johansson_cascade_allpassAzp(wa,fM1,bsA0,bsA1);
if max(abs(abs(H)-Fr))/eps > 100
  error("max(abs(abs(H)-Fr))/eps > 100");
endif
subplot(111);
plot(wa*0.5/pi,20*log10(abs(Fr)));
axis([0 0.5 -120 5]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title("Johansson-and-Saram\\\"{a}ki band-stop zero-phase response");
print(strcat(strf,"_zp"),"-dpdflatex");
close
ax=plotyy(wa*0.5/pi,20*log10(abs(Fr)), ...
          wa(nasl:nasu)*0.5/pi,20*log10(abs(Fr(nasl:nasu))));
axis(ax(1),[0 0.5 -0.00005 0]);
axis(ax(2),[0 0.5 -110 -105]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
title("Johansson-and-Saram\\\"{a}ki band-stop zero-phase response");
print(strcat(strf,"_zp_dual"),"-dpdflatex");
close

% Save the filter specification
fid=fopen("johansson_cascade_allpass_bandstop_test_spec.m","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nf=%d %% Frequency points across the band\n",nf);
fprintf(fid,"M=%d %% Prototype FIR filter order\n",M);
fprintf(fid,"Fap=%g %% Prototype FIR pass-band amplitude response edge\n",Fap);
fprintf(fid,"delta_p=%f %% FIR pass-band amplitude response ripple\n",delta_p);
fprintf(fid,"delta_s=%f %% FIR stop-band amplitude response ripple\n",delta_s);
fprintf(fid,"fapl=%g %% Pass-band amplitude response lower edge\n",fapl);
fprintf(fid,"fasl=%g %% Stop-band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Stop-band amplitude response upper edge\n",fasu);
fprintf(fid,"fapu=%g %% Pass-band amplitude response upper edge\n",fapu);
fclose(fid);
    
% Print filter
print_polynomial(f1,"f1");
print_polynomial(f1,"f1",strcat(strf,"_f1_coef.m"));
print_polynomial(bsA0,"bsA0");
print_polynomial(bsA0,"bsA0",strcat(strf,"_bsA0_coef.m"));
print_polynomial(bsA1,"bsA1");
print_polynomial(bsA1,"bsA1",strcat(strf,"_bsA1_coef.m"));

% Done
diary off
movefile johansson_cascade_allpass_bandstop_test.diary.tmp ...
         johansson_cascade_allpass_bandstop_test.diary;
