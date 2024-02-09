% mcclellanFIRsymmetric_linear_differentiator_fail_test.m
% Copyright (C) 2020-2022 Robert G. Jenssen
%
% Failed implementation of a maximally-linear FIR differentiator filter. The
% stop-band filter is calculated with mcclellanFIRsymmetric.m Small errors in
% the response of this filter are greatly magnified in the final filter.
%
% See: Section IV of "Exchange Algorithms for the Design of Linear Phase
% FIR Filters and Differentiators Having Flat Monotonic Passbands and
% Equiripple Stopband", Ivan W. Selesnick and C. Sidney Burrus, IEEE
% TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND
% DIGITAL SIGNAL PROCESSING, VOL. 43, NO. 9, SEPTEMBER 1996, pp. 671-675

test_common;

delete("mcclellanFIRsymmetric_linear_differentiator_fail_test.diary");
delete("mcclellanFIRsymmetric_linear_differentiator_fail_test.diary.tmp");
diary mcclellanFIRsymmetric_linear_differentiator_fail_test.diary.tmp

strf="mcclellanFIRsymmetric_linear_differentiator_fail_test";

%  
% Initialise
%
nplot=1000;
tol=1e-10;

%
% Filter design with fs fixed, N odd, L even
%
N=59;L=34;fs=0.2;
M=(N-L-1)/2;
L2m1=(L/2)-1;
strt=sprintf("McClellan symmetric FIR differentiator : N=%d,L=%d,$f_{s}$=%g",
             N,L,fs);
F=((1:nplot)'/nplot)/2;
nas=floor(fs*nplot/0.5);

% Construct weighting function
Ck=(1-cos(2*pi*F)).^(1:L2m1);
CL2=(1-cos(2*pi*F)).^(L/2);
if mod(N,2)
  % N odd
  S=sin(2*pi*F);
  d0=1;
  dk=cumprod(1:L2m1)./cumprod((2*(1:L2m1))+1);
else
  % N even:
  S=sin(pi*F);
  d0=2;
  dk=cumprod((1:2:((2*L2m1)-1))./(4*(1:L2m1))).*(2./(3:2:((2*L2m1)+1)));
endif
W=S.*CL2;
sumdkCk=d0+(sum(kron(ones(nplot,1),dk).*Ck,2));
D=-sumdkCk./CL2;

%
% Filter desigm with mcclellanFIRsymmetric fails!
%
[hM,rho,fext,fiter,feasible]= ...
  mcclellanFIRsymmetric(M,F(nas:end),D(nas:end),W(nas:end));
if feasible==false
  error("hM not feasible");
endif

%
% Plot failed solution
%

% Dual plot of hM response 
AhM=directFIRsymmetricA(2*pi*F,hM);
[ax,h1,h2]=plotyy(F(1:nas),AhM(1:nas),F(nas:end),AhM(nas:end));
axis(ax(1),[0 0.5 -1100e3 100e3]);
axis(ax(2),[0 0.5 -110e-3 10e-3]);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
title(strt);
print(strcat(strf,"_hM_dual"),"-dpdflatex");
close

% Plot the overall response 
A=S.*(sumdkCk+(AhM(:).*CL2));
plot(F,A);
axis([0 0.5 -0.2 1.2]);
xlabel("Frequency");
ylabel("Amplitude");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% Filter length\n",N);
fprintf(fid,"L=%d %% Filter linearity\n",L);
fprintf(fid,"fs=%g %% Amplitude stop band frequency\n",fs);
fclose(fid);

print_polynomial(hM,"hM","%14.7f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%14.7f");

save mcclellanFIRsymmetric_linear_differentiator_fail_test.mat ...
     N L fs nplot tol hM fext

%
% Done
%
diary off
movefile mcclellanFIRsymmetric_linear_differentiator_fail_test.diary.tmp ...
         mcclellanFIRsymmetric_linear_differentiator_fail_test.diary;

