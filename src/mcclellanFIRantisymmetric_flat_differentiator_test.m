% mcclellanFIRantisymmetric_flat_differentiator_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("mcclellanFIRantisymmetric_flat_differentiator_test.diary");
delete("mcclellanFIRantisymmetric_flat_differentiator_test.diary.tmp");
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
strt=sprintf("Selesnick-Burrus maximally-linear differentiator FIR : \
N=%d,L=%d,deltas=%g,maxiter=%d,tol=%g",N,L,deltas,maxiter,tol);
[hA58,hAM58,dk58,err58,fext58,fiter,feasible]= ...
mcclellanFIRantisymmetric_flat_differentiator(N,L,deltas,nplot,maxiter,tol);
if feasible==false
  error("hA58 not feasible");
endif
w=pi*(0:nplot)'/nplot;
A58=2*sin(w.*((((N-1)/2):-1:0)))*hA58(1:(N/2));

%
% Filter design with N odd
%
N=59;L=34;deltas=1e-4;tol=1e-8;
strt=sprintf("Selesnick-Burrus maximally-linear differentiator FIR : \
N=%d,L=%d,deltas=%g,maxiter=%d,tol=%g",N,L,deltas,maxiter,tol);
[hA59,hAM59,dk59,err59,fext59,fiter,feasible]= ...
mcclellanFIRantisymmetric_flat_differentiator(N,L,deltas,nplot,maxiter,tol);
if feasible==false
  error("hA59 not feasible");
endif

%
% Calculate response
%
w=pi*(0:nplot)'/nplot;
A59=2*sin(w.*((((N-1)/2):-1:0)))*hA59(1:((N+1)/2));

%
% Plot
%

% Plot the overall response (allow for -j)
plot(w*0.5/pi,-A59);
axis([0 0.5 -0.2 1.2]);
xlabel("Frequency");
ylabel("Amplitude");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot the amplitude error response (allow for -j)
plot(w*0.5/pi,[w(1:nplot/2)+A59(1:nplot/2);-A59((nplot/2)+1:end)]);
axis([0 0.5 -2*deltas 2*deltas]);
xlabel("Frequency");
ylabel("Amplitude error");
grid("on");
title(strt);
print(strcat(strf,"_error"),"-dpdflatex");
close

% Plot phase with:
%{
H59=freqz(hA59,1,w);
plot(w*0.5/pi,mod((unwrap(angle(H59))+(w*((N-1)/2)))/pi,2))
xlabel("Frequency");
ylabel("Phase/$\\pi$ (Adjusted for delay)");
grid("on");
title(strt);
%}

% Dual plot
fas=0.3;
nas=floor(fas*nplot/0.5)+1;
ax=plotyy(w(1:nas)*0.5/pi,-A59(1:nas),w(nas-10:end)*0.5/pi,-A59(nas-10:end));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.5 1.5 ]);
axis(ax(2),[0 0.5 -2*deltas 2*deltas]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Plot zeros
zplane(roots(hA59));
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
      [h,~,~,~,~,~,feasible]=mcclellanFIRantisymmetric_flat_differentiator ...
                               (n,l,deltas,nplot,maxiter,tol);
    catch
      nl_feasible(n,l)=0;
      feasible=false;
      warning("mcclellanFIRantisymmetric_flat_differentiator:n=%d,l=%d",n,l);
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
       ("Feasible N and L for mcclellanFIRantisymmetric\\_flat\\_differentiator \
: deltas=%g,maxiter=%d,tol=%g",deltas,maxiter,tol);
title(tstr);
print(strcat(strf,"_feasible"),"-dpdflatex");
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
