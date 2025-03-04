% selesnickFIRsymmetric_flat_lowpass_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("selesnickFIRsymmetric_flat_lowpass_test.diary");
delete("selesnickFIRsymmetric_flat_lowpass_test.diary.tmp");
diary selesnickFIRsymmetric_flat_lowpass_test.diary.tmp

strf="selesnickFIRsymmetric_flat_lowpass_test";

%  
% Initialise
%
nplot=4000;
maxiter=100;
tol=1e-10;

%
% Filter design with deltas fixed
%
N=33;L=22;deltas=0.01;initial_fs=0.3;
try
  [hA,hM,fext,fiter,feasible]= ...
    selesnickFIRsymmetric_flat_lowpass(N,L,deltas,initial_fs,nplot,maxiter,tol);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n",err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n",err.stack(e).name,err.stack(e).line);
  endfor
  error("selesnickFIRsymmetric_flat_lowpass() failed");
end_try_catch
if feasible==false
  warning("hA not feasible for fixed deltas");
endif
Aext=directFIRsymmetricA(2*pi*fext,hA);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

% Check the overall impulse response
F=linspace(0,0.5,nplot+1)(:);
W=((-1)^(L/2)*(sin(pi*F).^L));
AM=directFIRsymmetricA(2*pi*F,hM);
A=1+(AM(:).*W(:));
AA=directFIRsymmetricA(2*pi*F,hA);
if max(abs(A-AA))>tol
  error("max(abs(A-AA))>tol");
endif

%
% Plot solution
%
plot(F,20*log10(abs(A)))
axis([0 0.5 -40 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Selesnick-Burrus flat low-pass FIR : N=%d,L=%d,$\\delta_{s}$=%g",
             N,L,deltas);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
nas=min(find(abs(A)<(deltas+tol)))-1;
ax=plotyy(F(1:nas),A(1:nas),F(nas:end),A(nas:end));
axis(ax(1),[0 0.5 0.985 1.005]);
axis(ax(2),[0 0.5 -0.02 0.02]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% Filter length\n",N);
fprintf(fid,"L=%d %% Filter flat-ness\n",L);
fprintf(fid,"deltas=%d %% Amplitude stop band peak ripple\n",deltas);
fclose(fid);

print_polynomial(hM,"hM","%14.8f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%14.8f");

print_polynomial(hA,"hA","%15.12f");
print_polynomial(hA,"hA",strcat(strf,"_hA_coef.m"),"%15.12f");

save selesnickFIRsymmetric_flat_lowpass_test.mat ...
     N L deltas nplot maxiter tol hM hA fext Aext

%
% Done
%
diary off
movefile selesnickFIRsymmetric_flat_lowpass_test.diary.tmp ...
         selesnickFIRsymmetric_flat_lowpass_test.diary;

