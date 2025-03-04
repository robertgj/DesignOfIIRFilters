% directFIRnonsymmetric_socp_slb_bandpass_hilbert_test.m
% Copyright (C) 2021-2025 Robert G. Jenssen

test_common;

strf="directFIRnonsymmetric_socp_slb_bandpass_hilbert_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

strf="directFIRnonsymmetric_socp_slb_bandpass_hilbert_test";

maxiter=2000
ftol=1e-3
ctol=5e-6
verbose=false
n=500

% Band-pass filter specification 
N=50
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.25
dBas=40
Wap=1
Watl=1e-2
Watu=1e-2
Wasl=20
Wasu=10
ftpl=0.11
ftpu=0.19
td=10
tdr=td/25
Wtp=0.5
fppl=0.11
fppu=0.19
pd=2.5 % Initial phase offset in multiples of pi radians
ppr=1/50 % Peak-to-peak phase ripple in multiples of pi radians
Wpp=2

% Desired squared magnitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1);(10^(-dBap/10))*ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=td*ones(length(wt),1);
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(length(wt),1);

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pd*pi)-(td*wp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(nppu-nppl+1,1);

% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

nchkt=[ntpl-1,ntpl,ntpl+1,ntpu-1,ntpu,ntpu+1];
printf("0.5*wa(nchkt)'/pi=[ ");printf("%6.4g ",0.5*wa(nchkt)'/pi);printf("];\n");

nchkp=[nppl-1,nppl,nppl+1,nppu-1,nppu,nppu+1];
printf("0.5*wa(nchkp)'/pi=[ ");printf("%6.4g ",0.5*wa(nchkp)'/pi);printf("];\n");

% Find initial coefficients with hofstetterFIRsymmetric
M=floor(N/2);
deltap=1-(10^(-dBap/20));
deltas=10^(-dBas/20);
% Place 1+deltap at fapl,fapu and -deltas at fasl,fasu
sumfbands=fasl+(fapu-fapl)+(0.5-fasu);
nMp=ceil((M+1)*(fapu-fapl)/sumfbands);
if mod(nMp,2)==1
  nMp=nMp+1;
endif
f0p=linspace(fapl,fapu,nMp+1);
a0p=1+(((-1).^(0:nMp))*deltap);
nMsl=ceil((M+1)*fasl/sumfbands);
f0sl=linspace(0,fasl,nMsl);
a0sl=fliplr(((-1).^(1:nMsl))*deltas);
nMsu=M-nMp-nMsl;
f0su=linspace(fasu,0.5,nMsu);
a0su=((-1).^(1:nMsu))*deltas;
f0=[f0sl,f0p,f0su];
a0=[a0sl,a0p,a0su];
% Filter design
[hM,fext,fiter,feasible]=hofstetterFIRsymmetric(f0,a0,n,maxiter,ftol);
if feasible==false
  error("hM not feasible");
endif
h0=[hM(1:end);hM((end-1):-1:1)]';
h_active=find(h0~=0);

% SOCP MMSE optimisation
try
  [h1,opt_iter,func_iter,feasible]= ...
  directFIRnonsymmetric_socp_mmse([],h0,h_active,wa,Asqd,Asqdu,Asqdl,Wa,...
                                  wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                                  maxiter,ftol,ctol,verbose);
catch
  feasible=false;
  err=lasterror();
  fprintf(stderr,"%s\n", err.message);
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
end_try_catch
if !feasible
  error("h1 infeasible");
endif

% SOCP PCLS optimisation
try
  [h,slb_iter,opt_iter,func_iter,feasible]=directFIRnonsymmetric_slb ...
   (@directFIRnonsymmetric_socp_mmse,h1,h_active,wa,Asqd,Asqdu,Asqdl,Wa,...
    wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
catch
  feasible=false;
  err=lasterror();
  fprintf(stderr,"%s\n", err.message);
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
end_try_catch
if !feasible
  error("h infeasible");
endif

% Find response
Asq=directFIRnonsymmetricAsq(wa,h);
T=directFIRnonsymmetricT(wt,h);
P=directFIRnonsymmetricP(wp,h);

% Show squared-amplitude peaks
vAsql=local_max(Asqdl-Asq);
vAsqu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAsql);wa(vAsqu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=directFIRnonsymmetricAsq(wAsqS,h);
printf("h:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("h:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% Show delay peaks
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=directFIRnonsymmetricT(wTS,h);
printf("h:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("h:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% Show phase peaks
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=directFIRnonsymmetricP(wPS,h);
printf("h:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("h:PS=[ ");printf("%f ",(PS+(wPS*td))'/pi);printf(" ] (radians/pi)\n");

% Find response
Asq=directFIRnonsymmetricAsq(wa,h);
T=directFIRnonsymmetricT(wa,h);
P=directFIRnonsymmetricP(wa,h);

% Plot response
plot(wa*0.5/pi,10*log10(Asq));
axis([0 0.5 -dBas-10 5]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
s=sprintf("Non-symmetric FIR bandpass Hilbert filter : N=%d, td=%g", N,td);
title(s);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(311);
plot(wa(napl:napu)*0.5/pi,10*log10(Asq(napl:napu)));
ylabel("Amplitude(dB)");
axis([fapl fapu -0.6 0.2]);
grid("on");
title(s);
subplot(312);
plot(wa*0.5/pi,mod(P+(wa*td),2*pi)/pi);
ylabel("Phase(rad./$\\pi$)");
axis([fapl fapu mod(pd-0.01,2) mod(pd+0.01,2)]);
grid("on");
subplot(313);
plot(wa*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([fapl fapu td-0.2 td+0.2]);
grid("on");
print(strcat(strf,"_passband"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(h),[]);
title(s);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"fapl=%g %% Pass band squared amplitude lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band squared amplitude upper edge\n",fapu);
fprintf(fid,"dBap=%d %% Pass band squared amplitude ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band squared amplitude weight\n",Wap);
fprintf(fid,"fasl=%g %% Lower stop band squared amplitude lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Upper stop band squared amplitude upper edge\n",fasu);
fprintf(fid,"dBas=%d %% Stop band squared amplitude response ripple\n",dBas);
fprintf(fid,"Wasl=%d %% Lower stop band squared amplitude weight\n",Wasu);
fprintf(fid,"Wasu=%d %% Upper stop band squared amplitude weight\n",Wasl);
fprintf(fid,"ftpl=%g %% Pass band group delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group delay response upper edge\n",ftpu);
fprintf(fid,"td=%d %% Pass band nominal group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay response ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pd=%d %% Pass band initial phase (multiples of pi)\n",pd);
fprintf(fid,"ppr=%g %% Pass band phase response ripple\n",ppr);
fprintf(fid,"Wpp=%g %% Pass band phase response weight\n",Wpp);
fclose(fid);

% Save results
print_polynomial(h,"h");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));

eval(sprintf("save %s.mat ftol ctol n \
N fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ftpl ftpu td tdr Wtp \
fppl fppu ppr Wpp h0 h1 h",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
