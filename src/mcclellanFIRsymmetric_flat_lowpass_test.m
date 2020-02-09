% mcclellanFIRsymmetric_flat_lowpass_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

unlink("mcclellanFIRsymmetric_flat_lowpass_test.diary");
unlink("mcclellanFIRsymmetric_flat_lowpass_test.diary.tmp");
diary mcclellanFIRsymmetric_flat_lowpass_test.diary.tmp

strf="mcclellanFIRsymmetric_flat_lowpass_test";

%  
% Initialise
%
nplot=4000;
maxiter=100;
tol=1e-5;

%
% Filter design with fs fixed
%
if 1
  % Figure 3 of Selesnick and Burrus
  N=33;L=22;fs=0.3;
else
  % Example in Selesnick's cheblp2.m:
  N=25;L=18;fs=0.3;
endif
M=(N-L+1)/2;
strt=sprintf("Selesnick-Burrus flat low-pass FIR : N=%d,L=%d,$f_{s}$=%g",N,L,fs);
nas=floor(fs*nplot/0.5)+1;
F=linspace(0,0.5,nplot+1)(:);
W=(-1)^(L/2)*(sin(pi*F).^L);
D=-1./W;
[hM,rho,fext,fiter,feasible]= ...
  mcclellanFIRsymmetric(M,F(nas:end),D(nas:end),W(nas:end));
if feasible==false
  error("hM not feasible");
endif
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.7f");

% Plot solution
AM=directFIRsymmetricA(2*pi*F,hM);
A=1+(AM(:).*W);
plot(F,20*log10(abs(A)))
axis([0 0.5 -60 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Selesnick-Burrus flat low-pass FIR : N=%d,L=%d,$f_{s}$=%g",N,L,fs);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
if 0
  ax=plotyy(F(1:nas),20*log10(abs(A(1:nas))), ...
            F(nas:end),20*log10(abs(A(nas:end))));
  axis(ax(1),[0 0.5 -0.02 0.002]);
  axis(ax(2),[0 0.5 -50 -44]);
else
  ax=plotyy(F(1:nas),A(1:nas),F(nas:end),A(nas:end));
  axis(ax(1),[0 0.5 0.99 1.002]);
  axis(ax(2),[0 0.5 -0.006 0.006]);
endif
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Check response at extremal frequencies
maxA=local_max(A);
minA=local_max(-A);
[mm,imm]=unique([maxA;minA]);
[Fmm,imm]=unique(F([maxA;minA]));
Amm=[A(maxA);A(minA)];
Amm=Amm(imm);
print_polynomial(Fmm,"Fmm","%13.10f");
print_polynomial(Amm,"Amm","%13.10f");

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% Filter length\n",N);
fprintf(fid,"L=%d %% Filter flat-ness\n",L);
fprintf(fid,"fs=%d %% Amplitude stop band frequency\n",fs);
fprintf(fid,"nplot=%d %% Number of frequency points\n",nplot);
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM","%14.8f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%14.8f");

save mcclellanFIRsymmetric_flat_lowpass_test.mat ...
     N L fs nplot maxiter tol hM fext Aext

%
% Done
%
diary off
movefile mcclellanFIRsymmetric_flat_lowpass_test.diary.tmp ...
         mcclellanFIRsymmetric_flat_lowpass_test.diary;

