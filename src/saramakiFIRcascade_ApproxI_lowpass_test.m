% saramakiFIRcascade_ApproxI_lowpass_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% Design a low-pass FIR filter as the tapped cascade of sub-filters
% following Saramaki's Approximation Problem I.
%
% See: "Design of FIR Filters as a Tapped Cascaded Interconnection of
% Identical Subfilters", T. Saramaki, IEEE Transactions on Circuits and
% Systems, September, 1987, Vol. 34, No. 9, pp. 1011-1029.

test_common;

delete("saramakiFIRcascade_ApproxI_lowpass_test.diary");
delete("saramakiFIRcascade_ApproxI_lowpass_test.diary.tmp");
diary saramakiFIRcascade_ApproxI_lowpass_test.diary.tmp

tic();

strf="saramakiFIRcascade_ApproxI_lowpass_test";

maxiter=100;
tol=1e-8;
verbose=false;

%
% Filter design from Figure 5.
%
N=6;fap=0.1375;fas=0.15;deltap=0.01;deltas=0.001;

nplot=4000;
fa=(0:(nplot-1))'*0.5/nplot;
wa=2*pi*fa;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;
Ad=[ones(nap,1);zeros(nplot-nap,1)];
Wa=[ones(nap,1);zeros(nas-nap-1,1);(deltap/deltas)*ones(nplot-nas+1,1)];
Fap_step=0.002;
Fap_range=0.020:Fap_step:0.300;

%
% Part 1: Search for minimum prototype filter transition width
%
% Given the prototype filter order 2N, find the minimum subfilter order
% 2M which is required by the overall filter to meet the given
% specifications of (14), the zero-phase response of the omega-domain filter.
% This is done by designing the zero-phase response of the prototype filter
% Ht0 to meet the specifications by optimising over Omegap:
%    1-deltap <= Ht0(Omega) <= 1+deltap   for      0 <= Omega <= Omegap
%     -deltas <= Ht0(Omega) <=   deltas   for Omegas <= Omega <= pi
% and the Omega=PM(omega), omega-to-Omega-domain transformation to meet:
%    cos(Omegap) <= PM(omega) <= 1           for omega in Ip
%             -1 <= PM(omega) <= cos(Omegas) for omega in Is
% For fixed Omegap, the subfilter order  2M is minimised by determining the
% prototype filter Ht0 with the minimum Omegas. Minimising Omegas maximises
% the allowable variation of PM(omega) on Is and consequently minimises 2M.
% The desired solution is obtained by reducing Omegas until deltap and deltas
% attain the specified maximum values.

% Reproduce the transition bandwidth plot of Saramaki Figure 5.
Fapmin=[];
Fasmin=[];
hNmin=[];
ANmin=[];
for Fap=Fap_range,
  % 1. Equation 15: given Omegap, find the transition width, Omegas-Omegap,
  %    of the  prototype filter of order 2N, that meets the amplitude
  %    specification deltap and deltas.
  At=1-deltap;
  [ht0,fext,fiter,feasible]=selesnickFIRsymmetric_lowpass ...
                              (N,deltap,deltas,Fap,At,nplot,maxiter,tol,verbose);
  if ~feasible
    warning("Fap=%g,deltap=%g,deltas=%g not feasible",Fap,deltap,deltas);
    continue;
  endif
  hNmin=[hNmin,ht0(:)];
  AN=directFIRsymmetricA(wa,ht0);
  ANmin=[ANmin,AN(:)];
  nasNmax=max(find(AN>(deltas+tol)));
  % Find Fas
  Fas=halleyFIRsymmetricA(wa(nasNmax),ht0,deltas)/(2*pi);
  Fasmin=[Fasmin,Fas];
  Fapmin=[Fapmin,Fap];
endfor

% Alternative solution using remez
Fapmin_remez=[];
Fasmin_remez=[];
hNmin_remez=[];
ANmin_remez=[];
for Fap=Fap_range,
  % 1. Equation 15: given Omegap, find the transition width, Omegas-Omegap,
  %    of the  prototype filter of order 2N, that meets the amplitude
  %    specification deltap and deltas.
  found=false;
  for Fas=(Fap+0.01):Fap_step:0.49,
    try
      ht0=remez(2*N,[0 Fap Fas 0.5]*2,[1 1 0 0],[1 deltap/deltas]);
    catch
      err=lasterror();
      warning("Caught error at Fap=%g,Fas=%g : %s\n",Fap,Fas,err.message);
      continue;
    end_try_catch
    ht0=ht0(1:(N+1));
    AN=directFIRsymmetricA(wa,ht0);
    if (max(AN)<(1+deltap)) && (max(-AN)<deltas)
      found=true;
      break;
    endif
  endfor
  if found==false
    warning("Did not find Fas at Fap=%g",Fap);
    break;
  endif
  hNmin_remez=[hNmin_remez,ht0(:)];
  ANmin_remez=[ANmin_remez,AN(:)];
  Fasmin_remez=[Fasmin_remez,Fas];
  Fapmin_remez=[Fapmin_remez,Fap];
endfor

% Dual plot of transition width search results
plot(Fapmin_remez,(Fasmin_remez-Fapmin_remez),"--",Fapmin,(Fasmin-Fapmin),"-");
axis([0 0.35 0.16 0.24]);
xlabel("Pass-band edge($\\Omega_{p}/2\\pi$)");
ylabel("Transition width($\\Delta\\Omega/2\\pi$)");
legend("remez","selesnickFIRsymmetric\\_lowpass");
legend("location","south");
legend("boxoff");
legend("left");
strt=sprintf("Search for prototype filter minimum transition-width : \
N=%d,$f_{p}$=%g,$f_{s}$=%g,$\\delta_{p}$=%g,$\\delta_{s}$=%g", ...
             N,fap,fas,deltap,deltas);
title(strt);
print(strcat(strf,"_trans_width"),"-dpdflatex");
close

%
% Part 2 : Search for the minimum sub-filter order that satisfies the
% prototype filter pass-band and stop-band Omega frequencies
%
found_subfilter=[];
A_subfilter=[];
B_subfilter=[];
deltaphat_subfilter=[];
deltashat_subfilter=[];
Mmin_subfilter=[];
hMmin_subfilter=cell();
Omega_subfilter=[];
AMmin_subfilter=[];
Amin_subfilter=[];
for k=1:length(Fapmin),
  % 2. Equation 26c and 26d: given Omega_p and the corresponding Omega_s,
  % find the subfilter order, 2M, that meets the constraints on Omega
  Fap=Fapmin(k);
  Fas=Fasmin(k);
  cosOmegap=cos(2*pi*Fap);
  cosOmegas=cos(2*pi*Fas);
  deltahat=[3+cosOmegap,-1+cosOmegap;1+cosOmegas,-3+cosOmegas] ...
           \[1-cosOmegap;-1-cosOmegas];
  deltaphat=deltahat(1);
  deltashat=deltahat(2);
  found=false;
  % Search for mimimum M satisfying constraints fap,fas,deltaphat and deltashat
  for M=20:50,
  % Search for minimum subfilter order 2M with selesnickFIRsymmetric_lowpass
    [hh0,fext,fiter,feasible]= ...
      selesnickFIRsymmetric_lowpass ...
        (M,deltaphat,deltashat,fap,1-deltaphat,nplot,maxiter,tol,verbose);
    if ~feasible
      warning("fap=%g,deltap=%g,deltas=%g not feasible",fap,deltap,deltas);
      continue;
    endif
    AM=directFIRsymmetricA(wa,hh0);
    nasMmax=max(find(AM>(deltashat+tol)));
    fasM=halleyFIRsymmetricA(wa(nasMmax),hh0,deltashat)/(2*pi);
    if fasM<=fas
      found=true;
      break;
    endif
  endfor
  if found
    printf("Fap=%g,Fas=%g : found M=%d\n",Fap,Fas,M);
  else
    warning("Fap=%g,Fas=%g : M not found!",Fap,Fas);
    continue;
  endif
  
  % 3. Find the Omega output of the subfilter
  A=(1+deltaphat+deltashat)/2;
  B=(1+deltaphat-deltashat)/2;
  Omega=acos((AM-B)/A);
  
  % 4. Calculate the response
  AOmega=directFIRsymmetricA(Omega,hNmin(:,k));

  % Save results
  found_subfilter(k)=found;
  A_subfilter=[A_subfilter,A];
  B_subfilter=[B_subfilter,B];
  deltaphat_subfilter=[deltaphat_subfilter,deltaphat];
  deltashat_subfilter=[deltashat_subfilter,deltashat];
  Omega_subfilter=[Omega_subfilter,Omega(:)];
  Mmin_subfilter=[Mmin_subfilter,M];
  hMmin_subfilter{length(Mmin_subfilter)}=hh0(:);
  AMmin_subfilter=[AMmin_subfilter,AM(:)];
  Amin_subfilter=[Amin_subfilter,AOmega(:)];
endfor

%
% Plot results
%

% Plot prototype filter minimum transition width and minimum sub-filter order
strt=sprintf("Minimum transition-width and sub-filter order : \
N=%d,$f_{p}$=%g,$f_{s}$=%g,$\\delta_{p}$=%g,$\\delta_{s}$=%g", ...
             N,fap,fas,deltap,deltas);
Fapmin_subfilter=Fapmin(find(found_subfilter==1));
Fasmin_subfilter=Fasmin(find(found_subfilter==1));
if 0
  ax=plotyy(Fapmin_subfilter,2*Mmin_subfilter,Fapmin,(Fasmin-Fapmin));
  set(ax(2),'ycolor','black');
  set(ax(1),'ycolor','black');
  axis(ax(1),[0 0.3 40 100])
  axis(ax(2),[0 0.3 0.12 0.24])
  grid("on")
  ylabel(ax(1),"Minimum sub-filter order($2M$)")
  ylabel(ax(2),"Transition width($\\Delta\\Omega/2\\pi$)")
  xlabel("Pass-band edge($\\Omega_{p}/2\\pi$)")
  legend("M","Transition width");
  legend("location","south");
  legend("boxoff");
  legend("left");
  title(strt);
else
  subplot(211)
  plot(Fapmin_subfilter,2*Mmin_subfilter);
  axis([0 0.3 40 90]);
  grid("on");
  ylabel("Minimum sub-filter order($2M$)")
  title(strt);
  subplot(212)
  plot(Fapmin,(Fasmin-Fapmin));
  axis([0 0.3 0.15 0.25])
  grid("on")
  ylabel("Transition width($\\Delta\\Omega/2\\pi$)")
  xlabel("Pass-band edge($\\Omega_{p}/2\\pi$)")
endif
print(strcat(strf,"_trans_width_M"),"-dpdflatex");
close

% Plot subfilter response for minimum subfilter order 2M
[M,kM]=min(Mmin_subfilter);
if 1
  plot(fa,Omega_subfilter(:,kM)/(2*pi));
  ylabel("$\\Omega/2\\pi$");
else
  plot(fa,AMmin_subfilter(:,kM));
  ylabel("Amplitude");
endif
xlabel("Frequency");
grid("on");
strt=sprintf("Saramaki FIR cascade low-pass Approx. I sub-filter : \
N=%d,M=%d,$f_{p}$=%g,$f_{s}$=%g,$\\delta_{p}$=%g,$\\delta_{s}$=%g", ...
             N,M,fap,fas,deltap,deltas);
title(strt);
print(strcat(strf,"_subfilter_response"),"-dpdflatex");
close

% Plot overall response for minimum subfilter order 2M
plot(fa,20*log10(abs(Amin_subfilter(:,kM))))
axis([0 0.5 -70 1])
grid("on");
xlabel("Amplitude");
ylabel("Frequency");
strt=sprintf("Saramaki FIR cascade low-pass Approx. I : \
N=%d,M=%d,$f_{p}$=%g,$f_{s}$=%g,$\\delta_{p}$=%g,$\\delta_{s}$=%g", ...
             N,M,fap,fas,deltap,deltas);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close
ax=plotyy(fa,Amin_subfilter(:,kM),fa,Amin_subfilter(:,kM));
axis(ax(1),[0 0.5 1-2*deltap 1+2*deltap])
axis(ax(2),[0 0.5 -2*deltas 2*deltas])
grid("on");
ylabel("Amplitude");
xlabel("Frequency");
strt=sprintf("Saramaki FIR cascade low-pass Approx. I : \
N=%d,M=%d,$f_{p}$=%g,$f_{s}$=%g,$\\delta_{p}$=%g,$\\delta_{s}$=%g", ...
             N,M,fap,fas,deltap,deltas);
title(strt);
print(strcat(strf,"_response_detail"),"-dpdflatex");
close

% Plot three-way response similar to Saramaki Figure 6
Amp_line=linspace(-70,10,length(fa));
Fap_line=Fapmin_subfilter(kM)*ones(size(fa));
Fas_line=Fasmin_subfilter(kM)*ones(size(fa));
fap_line=fap*ones(1,length(fa));
fas_line=fas*ones(1,length(fa));
line_linewidth=2;
line_colour=[0,0,0];
subplot(221)
plot(20*log10(abs(ANmin(:,kM))),fa, ...
     Amp_line,Fap_line,"linewidth",line_linewidth,"color",line_colour, ...
     Amp_line,Fas_line,"linewidth",line_linewidth,"color",line_colour);
axis([min(Amp_line) max(Amp_line) min(fa) max(fa)]);
grid("on");
strt=sprintf("Prototype filter : N=%d,$\\delta_{p}$=%g,$\\delta_{s}$=%g", ...
             N,deltap,deltas);
title(strt);
ylabel("Frequency($\\Omega/2\\pi$)")
xlabel("Amplitude (dB)")
subplot(222)
plot(fa,Omega_subfilter(:,kM)/(2*pi), ...
     fa,Fap_line,"linewidth",line_linewidth,"color",line_colour, ...
     fa,Fas_line,"linewidth",line_linewidth,"color",line_colour, ...
     fap_line,fa,"linewidth",line_linewidth,"color",line_colour, ...
     fas_line,fa,"linewidth",line_linewidth,"color",line_colour);
axis([min(fa) max(fa) min(fa) max(fa)]);                      
grid("on");
strt=sprintf("Sub-filter : M=%d,$F_{p}$=%g,$F_{s}$=%g", ...
             M,Fapmin_subfilter(kM),Fasmin_subfilter(kM));
title(strt);
subplot(224)
plot(fa,20*log10(abs(Amin_subfilter(:,kM))), ...
     fap_line,Amp_line,"linewidth",line_linewidth,"color",line_colour, ...
     fas_line,Amp_line,"linewidth",line_linewidth,"color",line_colour);
axis([min(fa) max(fa) min(Amp_line) max(Amp_line)]);
grid("on");
strt=sprintf("Overall cascaded filter : $f_{p}$=%g,$f_{s}$=%g",fap,fas);
title(strt);
ylabel("Amplitude(dB)")
xlabel("Frequency($\\omega/2\\pi$)")
print(strcat(strf,"_threeway_response"),"-dpdflatex");
close
    
% Check subfilter response 
% Sanity check
if length(hMmin_subfilter{kM})~=(Mmin_subfilter(kM)+1)
  error("kM=%d,length(hMmin_subfilter{kM})~=(kM+1)",Mmin_subfilter(kM)+1);
endif
% Scale hMmin_subfilter{kM}
hMmin_hat=hMmin_subfilter{kM};
hMmin_hat(M+1)=hMmin_hat(M+1)-B_subfilter(kM);
hMmin_hat=hMmin_hat/A_subfilter(kM);
PMmin=directFIRsymmetricA(wa,hMmin_hat);
% Sanity checks
if norm(PMmin-cos(Omega_subfilter(:,kM)))>tol
  error("norm(PMmin-cos(Omega_subfilter(all,kM)))(%g)>tol", ...
        norm(PMmin-cos(Omega_subfilter(:,kM))));
endif
hM=[hMmin_hat;hMmin_hat(M:-1:1)]';
HM=freqz(hM,1,wa);
if norm((HM.*exp(j*M*wa))-PMmin)>tol
  error("norm((HM.*exp(j*M*wa))-PMmin)(%g)>tol",norm((HM.*exp(j*M*wa))-PMmin));
endif
% Plot scaled sub-filter response 
plot(fa,PMmin);
ylabel("$P_{M}$");
xlabel("Frequency");
grid("on");
strt=sprintf("Saramaki FIR cascade low-pass Approx. I sub-filter : \
N=%d,M=%d,$f_{p}$=%g,$f_{s}$=%g,$\\delta_{p}$=%g,$\\delta_{s}$=%g", ...
             N,M,fap,fas,deltap,deltas);
title(strt);
print(strcat(strf,"_subfilter_PM_response"),"-dpdflatex");
close

% Calculate the direct-form overall filter tap coefficients
aN=[zeros(1,N),hNmin(N+1,kM)];
for k=1:N,
  aN=aN+[zeros(1,N-k),2*hNmin(1+N-k,kM)*chebyshevT(k)];
endfor
aN=fliplr(aN);
% Calculate the overall impulse response
hMk=1;
h=zeros(1,(2*N*M)+1);
for k=0:N
  h=h+(aN(k+1)*[zeros(1,((N-k)*M)),hMk,zeros(1,((N-k)*M))]);
  hMk=conv(hMk,hM);
endfor
H=freqz(h,1,wa);
if norm((H.*exp(j*N*M*wa))-Amin_subfilter(:,kM))>tol
  error("norm((H.*exp(j*N*M*wa))-Amin_subfilter(all,kM))(%g)>tol",
        norm((H.*exp(j*N*M*wa))-Amin_subfilter(:,kM)));
endif

% Save prototype and subfilter coefficients
print_polynomial(aN,"aN",strcat(strf,"_tap_coef.m"));
print_polynomial(hNmin(:,kM),"hN",strcat(strf,"_prototype_coef.m"));
print_polynomial(hMmin_hat,"hM",strcat(strf,"_subfilter_coef.m"));

% Make a LaTeX table
fname=strcat(strf,".tab");
fid=fopen(fname,"wt");
fprintf(fid,"\\begin{table}[hptb]\n");
fprintf(fid,"\\centering\n");
fprintf(fid,"\\begin{threeparttable}\n");
fprintf(fid,"\\begin{tabular}{lr}  \\toprule\n");
fprintf(fid,"N & %d \\\\ \n",N);
fprintf(fid,"$f_{p}$ & %g \\\\ \n",fap);
fprintf(fid,"$f_{s}$ & %g \\\\ \n",fas);
fprintf(fid,"$\\delta_{p}$ & %g \\\\ \n",deltap);
fprintf(fid,"$\\delta_{s}$ & %g \\\\ \n",deltas);
fprintf(fid,"\\midrule\n");
fprintf(fid,"$M$ & %d \\\\ \n",Mmin_subfilter(kM));
fprintf(fid,"$2NM+1$ & %d \\\\ \n",2*Mmin_subfilter(kM)*N+1);
fprintf(fid,"$\\Omega_{p}/2\\pi$ & %8.6f \\\\ \n",Fapmin_subfilter(kM));
fprintf(fid,"$\\Omega_{s}/2\\pi$ & %8.6f \\\\ \n",Fasmin_subfilter(kM));
fprintf(fid,"A & %8.6f \\\\ \n",A_subfilter(kM));
fprintf(fid,"B & %8.6f \\\\ \n",B_subfilter(kM));
fprintf(fid,"$\\hat{\\delta}_{p}$ & %8.6f \\\\ \n",deltaphat_subfilter(kM));
fprintf(fid,"$\\hat{\\delta}_{s}$ & %8.6f \\\\ \n",deltashat_subfilter(kM));
fprintf(fid,"\\bottomrule\n");
fprintf(fid,"\\end{tabular}\n");
fprintf(fid,"\\end{threeparttable}\n");
fprintf(fid,"\\caption[\\emph{Saram\\\"{a}ki} Approximation Problem I example]");
fprintf(fid,"{Parameters of \\emph{Saram\\\"{a}ki} FIR cascade Approximation");
fprintf(fid," Problem I example filter.}");
fprintf(fid,"\\label{tab:Saramaki-FIR-cascade-Approximation-I-example}\n");
fprintf(fid,"\\end{table}\n");
fclose(fid);

% Save filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"2N=%d %% Order of prototype filter\n",2*N);
fprintf(fid,"fap=%8.6f %% Pass-band edge\n",fap);
fprintf(fid,"fas=%8.6f %% Stop-band edge\n",fas);
fprintf(fid,"deltap=%8.6f %% Pass-band ripple\n",deltap);
fprintf(fid,"deltas=%8.6f %% Stop-band ripple\n",deltas);
fprintf(fid,"tol=%g %% Tolerance\n",tol);
fprintf(fid,"maxiter=%d %% Maximum number of iterations\n",maxiter);
fprintf(fid,"nplot=%d %% Frequency points\n",nplot);
fclose(fid);

% Save results
save saramakiFIRcascade_ApproxI_lowpass_test.mat ...
     maxiter tol verbose deltap deltas nplot nap nas ...
     Fap_step Fap_range Fapmin Fasmin hNmin ...
     Fapmin_remez Fasmin_remez hNmin_remez ...
     found_subfilter A_subfilter B_subfilter deltaphat_subfilter ...
     deltashat_subfilter Mmin_subfilter hMmin_subfilter

% Done
toc();
diary off
movefile saramakiFIRcascade_ApproxI_lowpass_test.diary.tmp ...
         saramakiFIRcascade_ApproxI_lowpass_test.diary;
