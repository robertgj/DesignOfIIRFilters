% mcclellanFIRantisymmetric_flat_differentiator_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

unlink("mcclellanFIRantisymmetric_flat_differentiator_test.diary");
unlink("mcclellanFIRantisymmetric_flat_differentiator_test.diary.tmp");
diary mcclellanFIRantisymmetric_flat_differentiator_test.diary.tmp

strf="mcclellanFIRantisymmetric_flat_differentiator_test";

%  
% Initialise
%
nplot=4000;
maxiter=100;

%
% Filter design with N even
%
% N=16;L=6;deltas=0.01;tol=1e-14
N=58;L=34;deltas=0.001;tol=1e-7;
strt=sprintf("Selesnick-Burrus flat differentiator FIR : N=%d,L=%d,deltas=%g",
             N,L,deltas);

[hA58,hAM58,dk58,err58,fext58,fiter,feasible]= ...
mcclellanFIRantisymmetric_flat_differentiator(N,L,deltas,nplot,maxiter,tol);
if feasible==false
  error("hA58 not feasible");
endif

%
% Filter design with N odd
%
N=59;L=34;deltas=0.0001;tol=1e-8;
strt=sprintf("Selesnick-Burrus flat differentiator FIR : N=%d,L=%d,deltas=%g",
             N,L,deltas);
[hA59,hAM59,dk59,err59,fext59,fiter,feasible]= ...
mcclellanFIRantisymmetric_flat_differentiator(N,L,deltas,nplot,maxiter,tol);
if feasible==false
  error("hA59 not feasible");
endif
%
% Calculate response
%
w=pi*(0:nplot)'/nplot;
if mod(N,2)
  A=2*sin(w.*((((N-1)/2):-1:0)))*hA59(1:((N+1)/2));
else
  A=2*sin(w.*(((N/2):-1:1)-0.5))*hA59(1:(N/2));
endif

%
% Plot
%

% Plot the overall response (allow for -j)
plot(w*0.5/pi,-A);
axis([0 0.5 -0.2 1.2]);
xlabel("Frequency");
ylabel("Amplitude");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot the amplitude error response (allow for -j)
plot(w*0.5/pi,[w(1:nplot/2)+A(1:nplot/2);-A((nplot/2)+1:end)]);
axis([0 0.5 -2*deltas 2*deltas]);
xlabel("Frequency");
ylabel("Amplitude error");
grid("on");
title(strt);
print(strcat(strf,"_error"),"-dpdflatex");
close

% Plot phase with:
%{
H=freqz(hA59,1,w);
plot(w*0.5/pi,mod((unwrap(angle(H))+(w*((N-1)/2)))/pi,2))
xlabel("Frequency");
ylabel("Phase/$\\pi$ (Adjusted for delay)");
grid("on");
title(strt);
%}

% Plot zeros
zplane(roots(hA59));
title(strt);
grid("on");
print(strcat(strf,"_zeros"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% Filter length\n",N);
fprintf(fid,"L=%d %% Filter flat-ness\n",L);
fprintf(fid,"deltas=%g %% Amplitude stop band ripple\n",deltas);
fclose(fid);

print_polynomial(hAM58,"hAM58","%14.8f");
print_polynomial(hAM58,"hAM58",strcat(strf,"_hAM58_coef.m"),"%14.8f");

print_polynomial(hA58,"hA58","%15.12f");
print_polynomial(hA58,"hA58",strcat(strf,"_hA58_coef.m"),"%15.12f");

print_polynomial(hAM59,"hAM59","%14.8f");
print_polynomial(hAM59,"hAM59",strcat(strf,"_hAM59_coef.m"),"%14.8f");

print_polynomial(hA59,"hA59","%15.12f");
print_polynomial(hA59,"hA59",strcat(strf,"_hA59_coef.m"),"%15.12f");

save mcclellanFIRantisymmetric_flat_differentiator_test.mat ...
     N L deltas nplot maxiter tol hA59 hAM59 dk59 err59 fext59

%
% Done
%
diary off
movefile mcclellanFIRantisymmetric_flat_differentiator_test.diary.tmp ...
         mcclellanFIRantisymmetric_flat_differentiator_test.diary;

