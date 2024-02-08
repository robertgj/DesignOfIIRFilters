% schurNSPAlattice_socp_mmse_test.m
% Copyright (C) 2023 Robert G. Jenssen

test_common;

strf="schurNSPAlattice_socp_mmse_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

maxiter=5000
verbose=true

%
% Initial coefficients from tarczynski_parallel_allpass_bandpass_hilbert_test.m
%
Da0 = [   1.0000000000,  -1.3194189839,   0.9026437097,   0.9023795686, ... 
         -1.9388654819,   1.7221502269,  -0.3547090588,  -0.6015708606, ... 
          0.8119338853,  -0.4295212306,   0.1309442168 ]';
Db0 = [   1.0000000000,  -1.9070171016,   1.2051021976,   1.1412058992, ... 
         -2.6024028324,   2.1182582375,  -0.3848100195,  -0.8142384509, ... 
          0.9958802405,  -0.5209397586,   0.1409537083 ]';

% Lattice decomposition of Da0, Db0
[~,~,A1s20_0,A1s00_0,A1s02_0,A1s22_0] = tf2schurNSlattice(flipud(Da0),Da0);
[~,~,A2s20_0,A2s00_0,A2s02_0,A2s22_0] = tf2schurNSlattice(flipud(Db0),Db0);

%
% Band-pass filter specification for parallel all-pass filters
%
sxx_symmetric=true;  % Enforce s02=-s20,s22=s00?
tol=1e-4
difference=true
dmax=inf;
rho=127/128
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.5
dBas=30 
Wap=1
Watl=1e-3
Watu=1e-3
Wasl=100
Wasu=100
ftpl=0.11
ftpu=0.19
tp=16
tpr=tp/200
Wtp=10
fppl=0.11
fppu=0.19
pd=3.5 % Initial phase offset in multiples of pi radians
pdr=1/500 % Peak-to-peak phase ripple in multiples of pi radians
Wpp=200

%
% Frequency vectors
%
n=1000;
wa=(0:(n-1))'*pi/n;

% Desired squared magnitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
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
Td=tp*ones(length(wt),1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(length(wt),1);

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pd*pi)-(tp*wp);
Pdu=Pd+(pdr*pi/2);
Pdl=Pd-(pdr*pi/2);
Wp=Wpp*ones(length(wp),1);

% Linear constraints
sxx_0=[A1s20_0,A1s00_0,A1s02_0,A1s22_0,A2s20_0,A2s00_0,A2s02_0,A2s22_0];
sxx_u=rho*ones(size(sxx_0));
sxx_l=-sxx_u;
sxx_active=1:length(sxx_0);
vS=[];

% SOCP
%try
  [A1s20_1,A1s00_1,A1s02_1,A1s22_1,A2s20_1,A2s00_1,A2s02_1,A2s22_1, ...
   socp_iter,func_iter,feasible]= ...
     schurNSPAlattice_socp_mmse(vS, ...
                                A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                                A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                                difference, ...
                                sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                                wa,Asqd,Asqdu,Asqdl,Wa, ...
                                wt,Td,Tdu,Tdl,Wt, ...
                                wp,Pd,Pdu,Pdl,Wp, ...
                                maxiter,tol,verbose);
%catch
%  feasible=false;
%end_try_catch
if ~feasible
  error("A1,A2 mmse infeasible");
endif

% Find response
Asq=schurNSPAlatticeAsq(wa,A1s20_1,A1s00_1,A1s02_1,A1s22_1, ...
                        A2s20_1,A2s00_1,A2s02_1,A2s22_1, ...
                        difference);
P=schurNSPAlatticeP(wp,A1s20_1,A1s00_1,A1s02_1,A1s22_1, ...
                    A2s20_1,A2s00_1,A2s02_1,A2s22_1, ...
                    difference);
T=schurNSPAlatticeT(wt,A1s20_1,A1s00_1,A1s02_1,A1s22_1, ...
                    A2s20_1,A2s00_1,A2s02_1,A2s22_1, ...
                    difference);

% Plot response
subplot(311);
ax=plotyy(wa*0.5/pi,10*log10(Asq),wa*0.5/pi,10*log10(Asq));
axis(ax(1),[0 0.5 -2*dBap dBap]);
axis(ax(2),[0 0.5 -dBas-10 -dBas+10]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Parallel all-pass bandpass Hilbert : dBap=%g,dBas=%g",dBap,dBas);
title(strt);
subplot(312);
plot(wp*0.5/pi,((P+(tp*wp))/pi)-pd);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 -pdr pdr]);
grid("on");
subplot(313);
plot(wt*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp-(tpr) tp+(tpr)]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save results
print_polynomial(A1s20_1,"A1s20_1");
print_polynomial(A1s20_1,"A1s20_1",strcat(strf,"_A1s20_1_coef.m"));
print_polynomial(A1s00_1,"A1s00_1");
print_polynomial(A1s00_1,"A1s00_1",strcat(strf,"_A1s00_1_coef.m"));
print_polynomial(A1s02_1,"A1s02_1");
print_polynomial(A1s02_1,"A1s02_1",strcat(strf,"_A1s02_1_coef.m"));
print_polynomial(A1s22_1,"A1s22_1");
print_polynomial(A1s22_1,"A1s22_1",strcat(strf,"_A1s22_1_coef.m"));

print_polynomial(A2s20_1,"A2s20_1");
print_polynomial(A2s20_1,"A2s20_1",strcat(strf,"_A2s20_1_coef.m"));
print_polynomial(A2s00_1,"A2s00_1");
print_polynomial(A2s00_1,"A2s00_1",strcat(strf,"_A2s00_1_coef.m"));
print_polynomial(A2s02_1,"A2s02_1");
print_polynomial(A2s02_1,"A2s02_1",strcat(strf,"_A2s02_1_coef.m"));
print_polynomial(A2s22_1,"A2s22_1");
print_polynomial(A2s22_1,"A2s22_1",strcat(strf,"_A2s22_1_coef.m"));

% Done
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
