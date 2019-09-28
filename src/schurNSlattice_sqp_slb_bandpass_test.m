% schurNSlattice_sqp_slb_bandpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

%{
Very slow! Results are:
Elapsed time is 2039.71 seconds.
sxx_2:fAsqS=[  0.000000   0.000000   0.027000   0.042000   0.050000   0.050000 
               0.100000   0.100000   0.122000   0.149000   0.177000   0.200000 
               0.200000   0.250000   0.250000   0.256000   0.266000   0.280000 
               0.294000   0.311000   0.328000   0.348000   0.367000   0.387000 
               0.405000   0.423000   0.450000   0.499000   0.499000  ] (fs==1)
sxx_2:AsqS=[ -63.329443 -63.329443 -40.711153 -58.375532 -36.031525 -36.031525 
              -1.825114  -1.825114   0.000000  -0.484095   0.000000  -1.793785 
              -1.793785 -36.162742 -36.162742 -56.342482 -40.629387 -58.878398 
             -42.651646 -62.838605 -43.955461 -67.967470 -44.883155 -75.932321
             -45.414630 -82.437299 -45.784221 -76.883605 -76.883605  ] (dB)
sxx_2:fTS=[    0.090000   0.090000   0.094000   0.105000   0.117000   0.132000
               0.151000   0.170000   0.187000   0.198000   0.208000   0.210000 
               0.210000  ] (fs==1)
sxx_2:TS=[   15.950000  15.950000  16.050000  15.964994  16.025895  15.953497
              16.050000  15.952935  16.020381  15.986768  16.034036  16.028117 
              16.028117  ] (samples)
s10_2 = [  -0.0270528775,  -0.4434759075,  -0.1125169872,  -0.2229033990, ... 
            0.3097756618,   0.3000181535,   0.1491750474,  -0.1022829875, ... 
           -0.1630077982,  -0.1528712702,  -0.0851329273,  -0.0042565775, ... 
            0.0261920621,   0.0281608428,   0.3766780790,   1.5717554025, ... 
            0.5888962650,   0.0239009013,  -0.0023765879,   0.0025788005 ];
s11_2 = [  -0.2683618858,   1.5088966685,   1.2864296377,   0.8120269882, ... 
            0.4691746004,   0.9489170972,   0.6317409956,   0.9958658795, ... 
            1.2769235085,   1.3601764123,   2.0608648790,   1.2566693860, ... 
            0.9736761598,   1.2124197427,   2.8286086072,   3.8365532840, ... 
            0.5016025115,   0.1515724651,   0.8785383643,   0.2932073106 ];
s20_2 = [   0.0000000000,   0.8158786150,   0.0000000000,   0.9603488777, ... 
            0.0000000000,   0.8451719395,   0.0000000000,   0.9997836869, ... 
            0.0000000000,   0.6902328773,   0.0000000000,   0.9999800000, ... 
            0.0000000000,   0.8688037280,   0.0000000000,   0.9582960012, ... 
            0.0000000000,   0.8133972671,   0.0000000000,   0.1215766546 ];
s00_2 = [   1.0000000000,   0.4244675969,   1.0000000000,   0.7910609892, ... 
            1.0000000000,   0.7631478585,   1.0000000000,   0.6210116757, ... 
            1.0000000000,   0.9297048080,   1.0000000000,   0.9770663118, ... 
            1.0000000000,   0.9992104863,   1.0000000000,   0.9878862188, ... 
            1.0000000000,   0.9965048096,   1.0000000000,   0.7843214950 ];
s02_2 = [  -0.0000000000,  -0.6503045309,  -0.0000000000,   0.7489530114, ... 
           -0.0000000000,  -0.3777981207,  -0.0000000000,  -0.1598060569, ... 
           -0.0000000000,   0.7184947022,  -0.0000000000,  -0.7512287564, ... 
           -0.0000000000,   0.0337287541,  -0.0000000000,  -0.0499802717, ... 
           -0.0000000000,  -0.6462899133,  -0.0000000000,  -0.9402032126 ];
s22_2 = [   1.0000000000,   0.8908667950,   1.0000000000,   0.9453830849, ... 
            1.0000000000,   0.9281924227,   1.0000000000,   0.7264388864, ... 
            1.0000000000,   0.9997670241,   1.0000000000,   0.9762949343, ... 
            1.0000000000,   0.9993504819,   1.0000000000,   0.9872584966, ... 
            1.0000000000,   0.9974925943,   1.0000000000,   0.9925820455 ];
.
.
.
stdxxf = [  31.7,  31.7,  53.5,  53.5, 101.5, 101.5, 114.4, 114.4, ... 
           168.4, 168.4, 254.6, 254.6, 194.6, 194.6, 197.9, 197.9, ... 
           195.2, 195.2, 151.6, 151.6 ];
%}

test_common;

unlink("schurNSlattice_sqp_slb_bandpass_test.diary");
unlink("schurNSlattice_sqp_slb_bandpass_test.diary.tmp");
diary schurNSlattice_sqp_slb_bandpass_test.diary.tmp


tol_mmse=1e-3
tol_pcls=2e-5
ctol=tol_pcls
maxiter=5000
verbose=false

% Bandpass R=2 filter specification
fapl=0.1,fapu=0.2,dBap=2,Wap=1
fasl=0.05,fasu=0.25,dBas=36
Wasl_mmse=1e8,Wasu_mmse=1e8,Wasl_pcls=1e6,Wasu_pcls=1e6
ftpl=0.09,ftpu=0.21,tp=16,tpr=0.1,Wtp_mmse=0.1,Wtp_pcls=1

% Initial filter (found by trial-and-error for iir_sqp_slb_bandpass_test.m)
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
Wa_mmse=[Wasl_mmse*ones(nasl,1); ...
         zeros(napl-nasl-1,1); ...
         Wap*ones(napu-napl+1,1); ...
         zeros(nasu-napu-1,1); ...
         Wasu_mmse*ones(n-nasu+1,1)];
Wa_pcls=[Wasl_pcls*ones(nasl,1); ...
         zeros(napl-nasl-1,1); ...
         Wap*ones(napu-napl+1,1); ...
         zeros(nasu-napu-1,1); ...
         Wasu_pcls*ones(n-nasu+1,1)];

% Group delay constraints
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/n;
ntp=length(wt);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt_mmse=Wtp_mmse*ones(ntp,1);
Wt_pcls=Wtp_pcls*ones(ntp,1);

% Constraints on the coefficients
dmax=0.05
rho=1-tol_pcls
Ns=length(s10_0);
sxx_u=reshape(kron([10*ones(2,1);rho*ones(4,1)],ones(1,Ns)),1,6*Ns);
sxx_l=-sxx_u;

% Find the active coefficients. Note the bitwise & operation!
[Esq,gradEsq]=...
  schurNSlatticeEsq(s10_0,s11_0,s20_0,s00_0,s02_0,s22_0,...
                    wa,Asqd,Wa_mmse,wt,Td,Wt_mmse);
sxx_0=reshape([s10_0;s11_0;s20_0;s02_0;s00_0;s22_0],1,6*Ns);
sxx_active=intersect(find(gradEsq),find((sxx_0~=0)&(sxx_0~=1)));

% Enforce s02=-s20,s22=s00?
sxx_symmetric=false;

% Common strings
strf="schurNSlattice_sqp_slb_bandpass_test";
strt=sprintf...
  ("%%s:fapl=%g,fapu=%g,dBap=%g,fasl=%g,fasu=%g,dBas=%g,Wtp=%%g,Was=%%g",
   fapl,fapu,dBap,fasl,fasu,dBas);

%
% SOCP MMSE pass
%
tic;
[s10_1,s11_1,s20_1,s00_1,s02_1,s22_1,opt_iter,func_iter,feasible] = ...
schurNSlattice_sqp_mmse([],s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                        sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                        wa,Asqd,Asqdu,Asqdl,Wa_mmse, ...
                        wt,Td,Tdu,Tdl,Wt_mmse, ...
                        maxiter,tol_mmse,verbose);
toc;
if feasible == 0 
  error("s10_1,s11_1,s20_1,s00_1,s02_1,s22_1(mmse) infeasible");
endif
% Plot the MMSE response
mmse_strf=strcat(strf,"_mmse_sxx_1");
mmse_strt=sprintf(strt,"Schur normalised-scaled SQP MMSE",Wtp_mmse,Wasl_mmse);
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
[s10_2,s11_2,s20_2,s00_2,s02_2,s22_2,slb_iter,opt_iter,func_iter,feasible] = ...
schurNSlattice_slb(@schurNSlattice_sqp_mmse, ...
                   s10_1,s11_1,s20_1,s00_1,s02_1,s22_1, ...
                   sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                   wa,Asqd,Asqdu,Asqdl,Wa_pcls, ...
                   wt,Td,Tdu,Tdl,Wt_pcls, ...
                   maxiter,tol_pcls,ctol,verbose);
toc;
if feasible == 0 
  error("s10_2,s11_2,s20_2,s00_2,s02_2,s22_2(pcls) infeasible");
endif
% Plot the PCLS response
pcls_strf=strcat(strf,"_pcls_sxx_2");
pcls_strt=sprintf(strt,"Schur normalised-scaled SQP PCLS",Wtp_pcls,Wasl_pcls);
schurNSlattice_sqp_slb_bandpass_plot ...
  (s10_2,s11_2,s20_2,s00_2,s02_2,s22_2,fapl,fapu,dBap,ftpl,ftpu,tp,tpr, ...
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

%
% Find simulated state standard deviation in bits
%
% Make a quantised noise signal with standard deviation 0.25*2^nbits
nbits=10;
scale=2^(nbits-1);
nsamples=2^15;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
dir_extra_bits=0;
u_dir_scaled=round(u*scale*(2^dir_extra_bits));
u=round(u*scale);
% Simulate
[yapf,yf,xxf]= ...
  schurNSlatticeFilter(s10_2,s11_2,s20_2,s00_2,s02_2,s22_2,u,"round");
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
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol_mmse=%g %% Tolerance on coef. update for MMSE\n",tol_mmse);
fprintf(fid,"tol_pcls=%g %% Tolerance on coef. update for PCLS\n",tol_pcls);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp_mmse=%d %% Delay pass band weight(MMSE)\n",Wtp_mmse);
fprintf(fid,"Wtp_pcls=%d %% Delay pass band weight(PCLS)\n",Wtp_pcls);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl_mmse=%d %% Ampl. lower stop band weight(MMSE)\n",Wasl_mmse);
fprintf(fid,"Wasu_mmse=%d %% Ampl. upper stop band weight(MMSE)\n",Wasu_mmse);
fprintf(fid,"Wasl_pcls=%d %% Ampl. lower stop band weight(PCLS)\n",Wasl_pcls);
fprintf(fid,"Wasu_pcls=%d %% Ampl. upper stop band weight(PCLS)\n",Wasu_pcls);
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

save schurNSlattice_sqp_slb_bandpass_test.mat fapl fapu fasl fasu ...
     ftpl ftpu dBap Wap dBas Wasl_mmse Wasu_mmse Wasl_pcls Wasu_pcls ...
     tp tpr Wtp_mmse Wtp_pcls dmax rho tol_mmse tol_pcls ctol ...
     x0 n0 d0 ...
     s10_0 s11_0 s20_0 s00_0 s02_0 s22_0 ...
     s10_1 s11_1 s20_1 s00_1 s02_1 s22_1 ...
     s10_2 s11_2 s20_2 s00_2 s02_2 s22_2 

% Done
diary off
movefile schurNSlattice_sqp_slb_bandpass_test.diary.tmp ...
         schurNSlattice_sqp_slb_bandpass_test.diary;
