% mcclellanFIRantisymmetric_linear_differentiator_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("mcclellanFIRantisymmetric_linear_differentiator_test.diary");
delete("mcclellanFIRantisymmetric_linear_differentiator_test.diary.tmp");
diary mcclellanFIRantisymmetric_linear_differentiator_test.diary.tmp

strf="mcclellanFIRantisymmetric_linear_differentiator_test";

%  
% Initialise
%
nplot=4000;
maxiter=100;

%
% Filter design with N even
%
N=56;L=34;deltas=0.001;tol=1e-7;
strt=sprintf("Parks-McClellan maximally-linear differentiator FIR : \
N=%d,L=%d,deltas=%g,maxiter=%d,tol=%g",N,L,deltas,maxiter,tol);
[hA56,hAM56,dk56,err56,fext56,fiter,feasible]= ...
mcclellanFIRantisymmetric_linear_differentiator(N,L,deltas,nplot,maxiter,tol);
if feasible==false
  error("hA56 not feasible");
endif
w=pi*(0:nplot)'/nplot;
A56=2*sin(w.*((((N-1)/2):-1:0)))*hA56(1:(N/2));

%
% Filter design with N odd
%
N=57;L=34;deltas=1e-4;tol=1e-8;
strt=sprintf("Parks-McClellan maximally-linear differentiator FIR : \
N=%d,L=%d,deltas=%g,maxiter=%d,tol=%g",N,L,deltas,maxiter,tol);
[hA57,hAM57,dk57,err57,fext57,fiter,feasible]= ...
mcclellanFIRantisymmetric_linear_differentiator(N,L,deltas,nplot,maxiter,tol);
if feasible==false
  error("hA57 not feasible");
endif

%
% Calculate response
%
w=pi*(0:nplot)'/nplot;
A57=2*sin(w.*((((N-1)/2):-1:0)))*hA57(1:((N+1)/2));

%
% Plot
%

% Plot the overall response (allow for -j)
plot(w*0.5/pi,-A57/(2*pi));
axis([0 0.5 -0.05 0.2]);
xlabel("Frequency");
ylabel("Amplitude/2$\\pi$");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot the amplitude error response (allow for -j)
plot(w*0.5/pi,[w(1:nplot/2)+A57(1:nplot/2);-A57((nplot/2)+1:end)]);
axis([0 0.5 -2*deltas 2*deltas]);
xlabel("Frequency");
ylabel("Amplitude error");
grid("on");
title(strt);
print(strcat(strf,"_error"),"-dpdflatex");
close

% Plot phase with:
%{
H57=freqz(hA57,1,w);
plot(w*0.5/pi,mod((unwrap(angle(H57))+(w*((N-1)/2)))/pi,2))
xlabel("Frequency");
ylabel("Phase/$\\pi$ (Adjusted for delay)");
grid("on");
title(strt);
%}

% Dual plot
fas=0.3;
nas=floor(fas*nplot/0.5)+1;
ax=plotyy(w(1:nas)*0.5/pi,-A57(1:nas),w(nas-10:end)*0.5/pi,-A57(nas-10:end));
axis(ax(1),[0 0.5 -0.5 1.5 ]);
axis(ax(2),[0 0.5 -2*deltas 2*deltas]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Plot zeros
zplane(qroots(hA57));
title(strt);
grid("on");
print(strcat(strf,"_zeros"),"-dpdflatex");
close

%
% Find the feasible region
%
nmax=100;
nl_feasible=-ones(nmax,nmax);
fs_feasible=zeros(nmax,nmax);
for n=1:nmax,
  for l=2:2:n,
    try
      [h,~,~,~,~,~,feasible]=mcclellanFIRantisymmetric_linear_differentiator ...
                               (n,l,deltas,nplot,maxiter,tol);
    catch
      nl_feasible(n,l)=0;
      feasible=false;
      warning("mcclellanFIRantisymmetric_linear_differentiator:n=%d,l=%d",n,l);
    end_try_catch
    if feasible==false
      nl_feasible(n,l)=0;
    else
      nl_feasible(n,l)=1;
    endif
  endfor
endfor
[p,q]=find(nl_feasible==1);
plot(p,q,".","markersize",4);
ylabel("L");
xlabel("N");
grid("on");
tstr=sprintf ...
("Feasible N and L for mcclellanFIRantisymmetric\\_linear\\_differentiator \
: deltas=%g,maxiter=%d,tol=%g",deltas,maxiter,tol);
title(tstr);
print(strcat(strf,"_feasible"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% Filter length\n",N);
fprintf(fid,"L=%d %% Filter linearity\n",L);
fprintf(fid,"deltas=%g %% Amplitude stop band ripple\n",deltas);
fclose(fid);

print_polynomial(hAM56,"hAM56","%14.8f");
print_polynomial(hAM56,"hAM56",strcat(strf,"_hAM56_coef.m"),"%14.8f");

print_polynomial(hA56,"hA56","%15.12f");
print_polynomial(hA56,"hA56",strcat(strf,"_hA56_coef.m"),"%15.12f");

print_polynomial(hAM57,"hAM57","%14.8f");
print_polynomial(hAM57,"hAM57",strcat(strf,"_hAM57_coef.m"),"%14.8f");

print_polynomial(hA57,"hA57","%15.12f");
print_polynomial(hA57,"hA57",strcat(strf,"_hA57_coef.m"),"%15.12f");

save mcclellanFIRantisymmetric_linear_differentiator_test.mat ...
     N L deltas nplot maxiter tol ...
     hA56 hAM56 dk56 err56 fext56 ...
     hA57 hAM57 dk57 err57 fext57

%
% Done
%
diary off
movefile mcclellanFIRantisymmetric_linear_differentiator_test.diary.tmp ...
         mcclellanFIRantisymmetric_linear_differentiator_test.diary;
