% directFIRnonsymmetric_socp_mmse_test.m
% Copyright (C) 2021 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetric_socp_mmse_test.diary");
delete("directFIRnonsymmetric_socp_mmse_test.diary.tmp");
diary directFIRnonsymmetric_socp_mmse_test.diary.tmp

strf="directFIRnonsymmetric_socp_mmse_test";

maxiter=2000
tol=1e-4
verbose=true
n=500

% Band-pass filter specification 
N=30
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.2
dBas=30 
Wap=1
Watl=1e-3
Watu=1e-3
Wasl=100
Wasu=100
ftpl=0.11
ftpu=0.19
td=10
tdr=td/10
Wtp=0.5
fppl=0.11
fppu=0.19
pd=2.5 % Initial phase offset in multiples of pi radians
ppr=1/10 % Peak-to-peak phase ripple in multiples of pi radians
Wpp=0.2

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
Td=td*ones(size(wt),1);
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt),1);

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

% Initial coefficients
h0=remez(N,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0],[Wasl Wap Wasu]);
h_active=find(h0~=0);

% SOCP
try
  [h,socp_iter,func_iter,feasible]= ...
    directFIRnonsymmetric_socp_mmse([],h0,h_active, ...
                                    wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                    wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
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

% Plot response
plot(wa*0.5/pi,10*log10(Asq));
axis([0 0.5 -40 5]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
s=sprintf("Nonsymmetric FIR : N=%d,td=%g", N,td);
title(s);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(311);
plot(wa(napl:napu)*0.5/pi,10*log10(Asq(napl:napu)));
ylabel("Amplitude(dB)");
axis([fapl fapu -3 1]);
grid("on");
title(s);
subplot(312);
plot(wt*0.5/pi,T);
ylabel("Delay(samples)");
axis([ftpl ftpu td-tdr td+tdr]);
grid("on");
subplot(313);
plot(wp*0.5/pi,(P+(wp*td))/pi);
ylabel("Phase error(rad./$\\pi$)");
xlabel("Frequency");
axis([fppl fppu pd-ppr pd+ppr]);
grid("on");
print(strcat(strf,"_passband"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(h),[]);
title(s);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"fapl=%f %% Pass band squared amplitude lower edge\n",fapl);
fprintf(fid,"fapu=%f %% Pass band squared amplitude upper edge\n",fapu);
fprintf(fid,"dBap=%f %% Pass band squared amplitude ripple\n",dBap);
fprintf(fid,"Wap=%f %% Pass band squared amplitude weight\n",Wap);
fprintf(fid,"fasl=%f %% Lower stop band squared amplitude lower edge\n",fasl);
fprintf(fid,"fasu=%f %% Upper stop band squared amplitude upper edge\n",fasu);
fprintf(fid,"dBas=%f %% Stop band squared amplitude response ripple\n",dBas);
fprintf(fid,"Wasl=%f %% Lower stop band squared amplitude weight\n",Wasu);
fprintf(fid,"Wasu=%f %% Upper stop band squared amplitude weight\n",Wasl);
fprintf(fid,"ftpl=%f %% Pass band group delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%f %% Pass band group delay response upper edge\n",ftpu);
fprintf(fid,"td=%f %% Pass band nominal group delay\n",td);
fprintf(fid,"tdr=%f %% Pass band group delay response ripple\n",tdr);
fprintf(fid,"Wtp=%f %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"fppl=%f %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%f %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"ppr=%f %% Pass band phase response ripple\n",ppr);
fprintf(fid,"Wpp=%f %% Pass band phase response weight\n",Wpp);
fclose(fid);

% Save results
print_polynomial(h,"h");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));

% Done 
save directFIRnonsymmetric_socp_mmse_test.mat tol n ...
     N fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ftpl ftpu td tdr Wtp ...
     fppl fppu ppr Wpp h0 h

diary off
movefile directFIRnonsymmetric_socp_mmse_test.diary.tmp ...
         directFIRnonsymmetric_socp_mmse_test.diary;
