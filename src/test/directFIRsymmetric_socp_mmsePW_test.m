% directFIRsymmetric_socp_mmsePW_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="directFIRsymmetric_socp_mmsePW_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=5e-5
ctol=ftol
verbose=false

% Band pass filter
M=15;
fapl=0.1;fapu=0.2;Wap=1;dBap=2;
fasl=0.05;fasu=0.25;Wasl=20;Wasu=40;dBas=47;

% Desired magnitude response
npoints=1000;
wa=(0:npoints)'*pi/npoints;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;  
na=[1 nasl napl napu nasu length(wa)];
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(npoints-napu+1,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBas/20))*ones(npoints-nasu+2,1)];
Adl=[-(10^(-dBas/20))*ones(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
     -(10^(-dBas/20))*ones(npoints-napu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+2,1)];

% Make an initial band pass filter
h0=remez(2*M,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0], ...
         [Wasl Wap Wasu],"bandpass");
hM0=h0(1:(M+1));
hM_active=1:length(hM0);

%
% SOCP SLB solution
%
try
  [hM1,slb_iter,socp_iter,func_iter,feasible]= ...
    directFIRsymmetric_slb(@directFIRsymmetric_socp_mmsePW, ...
                           hM0,hM_active,na,wa,Ad,Adu,Adl,Wa, ...
                           maxiter,ftol,ctol,verbose);
catch
  feasible=false;
  err=lasterror();
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("%s\n", err.message);
end_try_catch
if feasible==false
  error("directFIRsymmetric_slb failed! Filter not feasible!");
endif

% Amplitude and delay at local peaks
A=directFIRsymmetricA(wa,hM1);
vAl=local_max(-A);
vAu=local_max(A);
wAS=unique([wa(vAl);wa(vAu);wa([nasl,napl,napu,nasu])]);
AS=directFIRsymmetricA(wAS,hM1);
wAS=wAS(find(abs(AS)>0));
AS=AS(find(abs(AS)>0));
printf("hM1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM1:AS=[ ");printf("%f ",20*log10(abs(AS)'));printf(" ] (dB)\n");

% Plot passband response
subplot(211)
plot(wa*0.5/pi,20*log10(A));
ylabel("Amplitude(dB)");
axis([0 0.5 -3 1]);
grid("on");
strt=sprintf(["Direct-form symmetric FIR pass-band : ", ...
 "fapl=%g,fapu=%g,dBap=%g,Wap=%g"],fapl,fapu,dBap,Wap);
title(strt);
% Plot stop-band response
subplot(212)
plot(wa*0.5/pi,20*log10(A));
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 -40]);
grid("on");
strt=sprintf(["Direct-form symmetric FIR stop-band : ", ...
 "fasl=%g,fasu=%g,dBas=%g,Wasl=%g,Wasu=%g"],fasl,fasu,dBas,Wasl,Wasu);
title(strt);
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"fapl=%f %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%f %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%f %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"fasl=%f %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%f %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Wasl=%f %% Stop band amplitude response lower weight\n",Wasl);
fprintf(fid,"Wasu=%f %% Stop band amplitude response upper weight\n",Wasu);
fclose(fid);

% Save results
print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"),"%12.8f");

eval(sprintf(["save %s.mat ", ...
 "ftol ctol npoints fapl fapu dBap Wap fasl fasu dBas Wasl Wasu hM0 hM1"],strf));

% Done 
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));

