% directFIRnonsymmetric_socp_slb_lowpass_test.m
% Optimisation of direct-form nonsymmetric FIR lowpass filter response
% Copyright (C) 2021 Robert G. Jenssen

%{
% See Example 1 of "Estimation of filter order for prescribed, reduced
% group delay FIR filter design", J. KONOPACKI and K. MOSCINSKA,
% BULLETIN OF THE POLISH ACADEMY OF SCIENCES TECHNICAL SCIENCES, Vol. 63,
% No. 1, 2015, (https://journals.pan.pl/Content/84137/PDF/24_paper.pdf)
ctol=1e-7
N=56
fap=0.1,dBap=0.002,Wap=1
Wat=1e-8;
fas=0.1625,dBas=60,Was=1000
ftp=0.097,td=18,tdr=0.1,Wtp=0.1
h0 = [  0.00147701,   0.00197770,   0.00142608,  -0.00091198, ... 
       -0.00412172,  -0.00577209,  -0.00326785,   0.00375066, ... 
        0.01180151,   0.01436945,   0.00586829,  -0.01316660, ... 
       -0.03294733,  -0.03680115,  -0.00914506,   0.05428082, ... 
        0.14012717,   0.21989614,   0.26163534,   0.24550409, ... 
        0.17486678,   0.07609370,  -0.01343896,  -0.06321853, ... 
       -0.06361734,  -0.02847064,   0.01458485,   0.03996092, ... 
        0.03702190,   0.01306551,  -0.01399355,  -0.02774156, ... 
       -0.02258388,  -0.00507051,   0.01207627,   0.01873191, ... 
        0.01295220,   0.00063130,  -0.00957827,  -0.01203878, ... 
       -0.00698576,   0.00090648,   0.00628892,   0.00658632, ... 
        0.00294315,  -0.00140330,  -0.00366681,  -0.00308203, ... 
       -0.00086369,   0.00112874,   0.00175980,   0.00111014, ... 
        0.00004608,  -0.00061050,  -0.00063028,  -0.00033279, ... 
        0.00036164 ]';
%}

test_common;

delete("directFIRnonsymmetric_socp_slb_lowpass_test.diary");
delete("directFIRnonsymmetric_socp_slb_lowpass_test.diary.tmp");
diary directFIRnonsymmetric_socp_slb_lowpass_test.diary.tmp

tic;

maxiter=5000
verbose=false
tol=1e-4
ctol=tol/10
n=500

strf="directFIRnonsymmetric_socp_slb_lowpass_test";

% Low pass filter specification
N=30
fap=0.15,dBap=1,Wap=1
Wat=1e-8;
fas=0.2,dBas=40,Was=1000
ftp=0.125,td=10,tdr=1,Wtp=0.5

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=td*ones(ntp,1);
Tdu=(td+(tdr/2))*ones(ntp,1);
Tdl=(td-(tdr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Make an initial band pass filter
h0=remez(N,[0 fap fas 0.5]*2,[1 1 0 0],[Wap Was]);
N=length(h0)-1;
h_active=1:(N+1);

% MMSE pass
[hmmse,socp_iter,func_iter,feasible]= ...
  directFIRnonsymmetric_socp_mmse([],h0,h_active,wa,Asqd,Asqdu,Asqdl,Wa, ...
                                  wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                                  maxiter,tol,verbose);
if feasible==false
  error("directFIRnonsymmetric_socp_mmse failed!");
endif

Asq_mmse=directFIRnonsymmetricAsq(wa,hmmse);
T_mmse=directFIRnonsymmetricT(wa,hmmse);

% Plot MMSE amplitude and delay response
subplot(211)
plot(wa*0.5/pi,10*log10(Asq_mmse));
axis([0 0.5 -50 5]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("Nonsymmetric FIR MMSE low pass : \
N=%d,fap=%4.2f,ftp=%5.3f,td=%d,fas=%4.2f",N,fap,ftp,td,fas);
title(strt);
subplot(212)
plot(wa*0.5/pi,T_mmse);
axis([0 0.5 0 20]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_mmse_response"),"-dpdflatex");
close

% PCLS pass
[h,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRnonsymmetric_slb(@directFIRnonsymmetric_socp_mmse, ...
                            hmmse,h_active,wa,Asqd,Asqdu,Asqdl,Wa, ...
                            wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                            maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRnonsymmetric_slb failed!");
endif

Asq=directFIRnonsymmetricAsq(wa,h);
T=directFIRnonsymmetricT(wt,h);

% Plot PCLS amplitude response
plot(wa*0.5/pi,10*log10(Asq));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -50 5]);
grid("on");
strt=sprintf("Nonsymmetric FIR low pass : \
N=%d,fap=%4.2f,dBap=%d,ftp=%5.3f,td=%d,fas=%4.2f,dBas=%d", ...
             N,fap,dBap,ftp,td,fas,dBas);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot pass band amplitude and delay
subplot(211)
plot(wa*0.5/pi,10*log10(Asq));
axis([0 fap -dBap 0.2]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("Nonsymmetric FIR low pass pass band : \
N=%d,fap=%4.2f,dBap=%d,ftp=%5.3f,td=%d,tdr=%d",N,fap,dBap,ftp,td,tdr);
title(strt);
subplot(212)
plot(wt*0.5/pi,T);
axis([0 fap td-0.6 td+0.6]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_passband"),"-dpdflatex");
close

% Amplitude at local peaks
vAsql=local_max(Asqdl-Asq);
vAsqu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAsql);wa(vAsqu);wa([1,nap,nas,end])]);
AsqS=directFIRnonsymmetricAsq(wAsqS,h);
printf("h:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("h:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% Delay at local peaks
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,ntp])]);
TS=directFIRnonsymmetricT(wTS,h);
printf("h:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("h:TS=[ ");printf("%f ",TS);printf(" ] (samples)\n");

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"td=%g %% Nominal pass band filter group delay\n",td);
fprintf(fid,"tdr=%g %% Delay pass band peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fclose(fid);

printf("h=[ ");printf("%g ",h');printf("]';\n");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%12.8f");

save directFIRnonsymmetric_socp_slb_lowpass_test.mat ...
     tol ctol n fap dBap Wap Wat fas dBas Was ftp td tdr Wtp h0 h
       
% Done
toc;
diary off
movefile directFIRnonsymmetric_socp_slb_lowpass_test.diary.tmp ...
         directFIRnonsymmetric_socp_slb_lowpass_test.diary;
