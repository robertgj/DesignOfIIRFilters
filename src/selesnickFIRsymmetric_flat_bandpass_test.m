% selesnickFIRsymmetric_flat_bandpass_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

unlink("selesnickFIRsymmetric_flat_bandpass_test.diary");
unlink("selesnickFIRsymmetric_flat_bandpass_test.diary.tmp");
diary selesnickFIRsymmetric_flat_bandpass_test.diary.tmp

strf="selesnickFIRsymmetric_flat_bandpass_test";

%  
% Initialise
%
nplot=4000;
max_iter=100;
tol=1e-8;

% Specification
N=55;L=16;deltasl=1e-2;deltasu=2e-2;fp=0.2;ft=0.04;
strt=sprintf("Selesnick-Burrus Hofstetter flat band-pass FIR: \
N=%d,L=%d,$\\delta_{sl}$=%g,$\\delta_{su}$=%g,fp=%g,ft=%g", ...
             N,L,deltasl,deltasu,fp,ft);

% Filter design
[hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_flat_bandpass(N,L,deltasl,deltasu,fp,ft, ...
                                      nplot,max_iter,tol);
if feasible==false
  error("hM not feasible");
endif

%
% Plot solution
%
F=linspace(0,0.5,nplot)(:);
W=((-1)^(L/2))*(((cos(2*pi*fp)-cos(2*pi*F))/2).^(L/2));
AM=directFIRsymmetricA(2*pi*F,hM);
A=1+(AM(:).*W(:));
plot(F,20*log10(abs(A)))
axis([0 0.5 -50 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Selesnick-Burrus flat band-pass FIR : \
N=%d,L=%d,$\\delta_{sl}$=%g,$\\delta_{su}$=%g",N,L,deltasl,deltasu);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
ax=plotyy(F,A,F,A);
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 0.96 1.04]);
axis(ax(2),[0 0.5 [-2 2]*max(deltasl,deltasu)]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% Filter length\n",N);
fprintf(fid,"L=%d %% Filter maximal flat-ness\n",L);
fprintf(fid,"deltasl=%g %% Amplitude lower stop-band peak ripple\n",deltasl);
fprintf(fid,"deltasu=%g %% Amplitude upper stop-band peak ripple\n",deltasu);
fprintf(fid,"fp=%g %% Amplitude pass-band centre frequency\n",fp);
fprintf(fid,"ft=%g %% Initial amplitude pass-band half-width\n",ft);
fprintf(fid,"nplot=%d %% Number of frequency\n",nplot);
fprintf(fid,"tol=%g %% Tolerance\n",tol);
fclose(fid);

print_polynomial(hM,"hM","%15.7f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%15.7f");

save selesnickFIRsymmetric_flat_bandpass_test.mat  ...
     N L deltasl deltasu fp ft nplot max_iter tol hM fext

%
% Done
%
diary off
movefile selesnickFIRsymmetric_flat_bandpass_test.diary.tmp ...
         selesnickFIRsymmetric_flat_bandpass_test.diary;

