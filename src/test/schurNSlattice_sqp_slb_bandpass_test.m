% schurNSlattice_sqp_slb_bandpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurNSlattice_sqp_slb_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-3
ctol=ftol/10
maxiter=5000
verbose=false

% Bandpass R=2 filter specification
fapl=0.1,fapu=0.2,dBap=2;Wap=1
fasl=0.05,fasu=0.25,dBas=30,Wasl=10,Wasu=20
ftpl=0.1,ftpu=0.2,tp=16,tpr=0.4,Wtp=1

% Initial filter from iir_sqp_slb_bandpass_test.m
U=2,V=0,M=18,Q=10,R=2
x0=[ 0.00005, ...
     1, -1, ...
     0.9*ones(1,6), [1 1 1], (11:16)*pi/20, (7:9)*pi/10, ...
     0.81*ones(1,5), (4:8)*pi/10 ]';
[n0,d0]=x2tf(x0,U,V,M,Q,R);
[s10_0,s11_0,s20_0,s00_0,s02_0,s22_0]=tf2schurNSlattice(n0,d0);
  
% Amplitude constraints
n=500;
wa=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1); ...
      zeros(n-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1); ...
       (10^(-dBap/10))*ones(napu-napl+1,1); ...
       zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Group delay constraints
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/n;
ntp=length(wt);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Constraints on the coefficients
dmax=0.05
rho=1-ftol
Ns=length(s10_0);
sxx_u=reshape(kron([10*ones(2,1);rho*ones(4,1)],ones(1,Ns)),1,6*Ns);
sxx_l=-sxx_u;

% Find the active coefficients. Note the element-wise & operation!
[Esq,gradEsq]=...
  schurNSlatticeEsq(s10_0,s11_0,s20_0,s00_0,s02_0,s22_0,...
                    wa,Asqd,Wa,wt,Td,Wt);
sxx_0=reshape([s10_0;s11_0;s20_0;s02_0;s00_0;s22_0],1,6*Ns);
sxx_active=intersect(find(gradEsq),find((sxx_0~=0)&(sxx_0~=1)));

% Enforce s02=-s20,s22=s00?
sxx_symmetric=false;

% Common strings
strt=sprintf...
  ("%%s:fapl=%g,fapu=%g,dBap=%g,fasl=%g,fasu=%g,dBas=%g,Wtp=%%g,Was=%%g",
   fapl,fapu,dBap,fasl,fasu,dBas);

%
% SOCP MMSE pass
%
tic;
feasible=0;
[s10_1,s11_1,s20_1,s00_1,s02_1,s22_1,opt_iter,func_iter,feasible] = ...
schurNSlattice_sqp_mmse([],s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                        sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                        wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                        maxiter,ftol,ctol,verbose);
toc;
if feasible == 0 
  error("s10_1,s11_1,s20_1,s00_1,s02_1,s22_1(mmse) infeasible");
endif
% Plot the MMSE response
mmse_strf=strcat(strf,"_mmse_sxx_1");
mmse_strt=sprintf(strt,"Schur normalised-scaled SQP MMSE",Wtp,Wasl);
schurNSlattice_sqp_slb_bandpass_plot ...
  (s10_1,s11_1,s20_1,s00_1,s02_1,s22_1,fapl,fapu,dBap,ftpl,ftpu,tp,5*tpr, ...
   fasl,fasu,dBas,mmse_strf,mmse_strt);

%
% MMSE amplitude and delay at local peaks
%
Asq=schurNSlatticeAsq(wa,s10_1,s11_1,s20_1,s00_1,s02_1,s22_1);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurNSlatticeAsq(wAsqS,s10_1,s11_1,s20_1,s00_1,s02_1,s22_1);
printf("d1:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurNSlatticeT(wt,s10_1,s11_1,s20_1,s00_1,s02_1,s22_1);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurNSlatticeT(wTS,s10_1,s11_1,s20_1,s00_1,s02_1,s22_1);
printf("sxx_1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("sxx_1:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

%
% SOCP PCLS pass 1
%
tic;
feasible=0;
[s10_2,s11_2,s20_2,s00_2,s02_2,s22_2,slb_iter,opt_iter,func_iter,feasible] = ...
schurNSlattice_slb(@schurNSlattice_sqp_mmse, ...
                   s10_1,s11_1,s20_1,s00_1,s02_1,s22_1, ...
                   sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                   maxiter,ftol,ctol,verbose);
toc;
if feasible == 0 
  error("s10_2,s11_2,s20_2,s00_2,s02_2,s22_2(pcls) infeasible");
endif
% Plot the PCLS response
pcls_strf=strcat(strf,"_pcls_sxx_2");
pcls_strt=sprintf(strt,"Schur normalised-scaled SQP PCLS",Wtp,Wasl);
schurNSlattice_sqp_slb_bandpass_plot ...
  (s10_2,s11_2,s20_2,s00_2,s02_2,s22_2,fapl,fapu,dBap/10,ftpl,ftpu,tp,tpr/20, ...
   fasl,fasu,dBas,pcls_strf,pcls_strt);

%
% PCLS amplitude and delay at local peaks
%
Asq=schurNSlatticeAsq(wa,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurNSlatticeAsq(wAsqS,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
printf("sxx_2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("sxx_2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurNSlatticeT(wt,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurNSlatticeT(wTS,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
printf("sxx_2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("sxx_2:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% Check transfer function
[N2,D2]=schurNSlattice2tf(s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq)) > 100*eps
  error("max(abs((abs(HH).^2)-Asq))(%g*eps)>100*eps",
        max(abs((abs(HH).^2)-Asq))/eps);
endif

%
% Find simulated state standard deviation in bits
%
% Make a quantised noise signal with standard deviation 0.25*2^nbits
nbits=10;
scale=2^(nbits-1);
nsamples=2^15;
rand("seed",0xdeadbeef);
[~,dNS]=schurNSlattice2tf(s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
n60=p2n60(dNS);
u=rand(n60+nsamples,1)-0.5;
u=0.25*u/std(u);
dir_extra_bits=0;
u_dir_scaled=round(u*scale*(2^dir_extra_bits));
u=round(u*scale);
% Simulate
[yapf,yf,xxf]= ...
  schurNSlatticeFilter(s10_2,s11_2,s20_2,s00_2,s02_2,s22_2,u,"round");
% Remove initial transient
Rn60=(n60+1):length(u);
u=u(Rn60);
yapf=yapf(Rn60);
yf=yf(Rn60);
xxf=xxf(Rn60,:);
% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(u,yf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)));
xlabel("Frequency")
ylabel("Amplitude(dB)")
axis([0 0.5 -50 5]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close
% Show state variable std. deviation in bits
stdxxf=std(xxf)
print_polynomial(stdxxf,"stdxxf",strcat(strf,".stdxxf.val"),"%5.1f");

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Ampl. lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Ampl. upper stop band weight\n",Wasu);
fclose(fid);

print_polynomial(s10_2,"s10_2");
print_polynomial(s10_2,"s10_2",strcat(strf,"_s10_2_coef.m"));
print_polynomial(s11_2,"s11_2");
print_polynomial(s11_2,"s11_2",strcat(strf,"_s11_2_coef.m"));
print_polynomial(s20_2,"s20_2");
print_polynomial(s20_2,"s20_2",strcat(strf,"_s20_2_coef.m"));
print_polynomial(s00_2,"s00_2");
print_polynomial(s00_2,"s00_2",strcat(strf,"_s00_2_coef.m"));
print_polynomial(s02_2,"s02_2");
print_polynomial(s02_2,"s02_2",strcat(strf,"_s02_2_coef.m"));
print_polynomial(s22_2,"s22_2");
print_polynomial(s22_2,"s22_2",strcat(strf,"_s22_2_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf(["save %s.mat fapl fapu fasl fasu ", ...
 "ftpl ftpu dBap Wap dBas Wasl Wasu tp tpr Wtp dmax rho ftol ctol ", ...
 "s10_0 s11_0 s20_0 s00_0 s02_0 s22_0 ", ...
 "s10_1 s11_1 s20_1 s00_1 s02_1 s22_1 ", ...
 "s10_2 s11_2 s20_2 s00_2 s02_2 s22_2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
