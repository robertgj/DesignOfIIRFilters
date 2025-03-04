% saramakiFIRcascade_ApproxII_multiband_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen
%
% Design a multi-band FIR filter as the tapped cascade of sub-filters
% following Saramaki's Approximation Problem II.
%
% See Figure 17 and Section VI of:
% "Design of FIR Filters as a Tapped Cascaded Interconnection of
% Identical Subfilters", T. Saramaki, IEEE Transactions on Circuits and
% Systems, September, 1987, Vol. 34, No. 9, pp. 1011-1029.

test_common;

tic();

strf="saramakiFIRcascade_ApproxII_multiband_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tol=1e-12;
nplot=2000;

%
% Filter design from Section VI
%

% Specification: sub-filter order is 2*M
M=25;deltap=0.01;deltas=0.001;
fasu1=0.0625;
fapl1=0.0750;fapu1=0.1250;
fasl2=0.1375;fasu2=0.2375;
fapl2=0.2500;fapu2=0.4000;
fasl3=0.4125;

% Constants 
f=(0:nplot)'*0.5/nplot;
w=2*pi*f;
nasu1=ceil(fasu1*nplot/0.5)+1;
napl1=floor(fapl1*nplot/0.5)+1;
napu1=ceil(fapu1*nplot/0.5)+1;
nasl2=floor(fasl2*nplot/0.5)+1;
nasu2=ceil(fasu2*nplot/0.5)+1;
napl2=floor(fapl2*nplot/0.5)+1;
napu2=ceil(fapu2*nplot/0.5)+1;
nasl3=floor(fasl3*nplot/0.5)+1;
Ad=[zeros(napl1-1,1); ...
    ones(napu1-napl1+1,1); ...
    zeros(napl2-napu1-1,1); ...
    ones(napu2-napl2+1,1); ...
    zeros(nplot-napu2+1,1)];
F=[f(1:(nasu1-1));fasu1; ...
   fapl1;f((napl1+1):(napu1-1));fapu1; ...
   fasl2;f((nasl2+1):(nasu2-1));fasu2; ...
   fapl2;f((napl2+1):(napu2-1));fapu2; ...
   fasl3;f(nasl3+1:end)];
D=[zeros(nasu1,1); ...
   ones(napu1-napl1+1,1); ...
   zeros(nasu2-nasl2+1,1); ...
   ones(napu2-napl2+1,1); ...
   zeros(nplot-nasl3+2,1)];
Wp=[zeros(nasu1,1); ...
    ones(napu1-napl1+1,1); ...
    zeros(nasu2-nasl2+1,1); ...
    ones(napu2-napl2+1,1); ...
    zeros(nplot-nasl3+2,1)];
Ws=1-Wp;

% Sanity check
nchk=[1, ...
      nasu1-1,nasu1,nasu1+1,...
      napl1-1,napl1,napl1+1,...
      napu1-1,napu1,napu1+1,...
      nasl2-1,nasl2,nasl2+1,...
      nasu2-1,nasu2,nasu2+1,...
      napl2-1,napl2,napl2+1,...
      napu2-1,napu2,napu2+1,...
      nasl3-1,nasl3,nasl3+1, ...
      nplot,(nplot+1)];
printf("nchk=[ ");printf("%d ",nchk(:)');printf("]=\n");
printf("f(nchk)=[ ");printf("%d ",f(nchk)(:)');printf("]\n");
printf("Ad(nchk)=[ ");printf("%d ",Ad(nchk)(:)');printf("]\n");
Fchk=[...
       % First stop-band
       1, ...
       2, ...
       nasu1-1, ...
       nasu1, ...  
       % First pass-band
       nasu1+1, ...
       nasu1+2, ...
       nasu1+napu1-napl1, ...
       nasu1+napu1-napl1+1, ... 
       % Second stop-band
       nasu1+napu1-napl1+2, ...
       nasu1+napu1-napl1+3,...
       nasu1+napu1-napl1+2+nasu2-nasl2-1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2, ...
       % Second pass-band
       nasu1+napu1-napl1+2+nasu2-nasl2+1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+2, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2-1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2, ...
       % Third stop-band
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2+1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2+2, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2+nplot-nasl3+1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2+nplot-nasl3+2 ...
     ];
printf("Fchk=[ ");printf("%7d ",Fchk);printf("]\n");
printf("F(Fchk)=[ ");printf("%7.5f ",F(Fchk)');printf("]\n");
printf("D(Fchk)=[ ");printf("%7.5f ",D(Fchk)');printf("]\n");
printf("Wp(Fchk)=[ ");printf("%7.5f ",Wp(Fchk)');printf("]\n");
printf("Ws(Fchk)=[ ");printf("%7.5f ",Ws(Fchk)');printf("]\n");

% Search for minimum order, 2N, prototype filter
Kmin=[];
Nmin=[];
deltaphatmin=[];
deltashatmin=[];
Fapmin=[];
Fasmin=[];
hMmin=[];
hNmin=cell();
AMmin=[];
ANmin=[];
FasNmin=[];
Amin=[];
Bmin=[];
Omegamin=[];
ANMmin=[];
Emin=[];
for K=0.700:0.001:1.000,
  % Find a sub-filter meeting the omega-domain frequency specifications
  [hM,rho,fext,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,Wp+(K*Ws));
  if feasible==false
    printf("K=%g,hM not feasible\n",K);
    continue;
  endif
  
  % Find the Omega domain band edges
  AM=directFIRsymmetricA(w,hM);
  deltaphat=max(AM)-1;
  deltashat=abs(min(AM));
  A=(1+deltaphat+deltashat)/2;
  B=(1+deltaphat-deltashat)/2;
  cosOmegap=(1+deltashat-(3*deltaphat))/(1+deltaphat+deltashat);
  cosOmegas=((3*deltashat)-deltaphat-1)/(1+deltaphat+deltashat);
  Fap=acos(cosOmegap)/(2*pi);
  Fas=acos(cosOmegas)/(2*pi);

  % Find the minimum order prototype filter meeting the amplitude specifications
  Nfound=false;
  for N=3:20,
    [hN,fext,fiter,feasible]= ...
      selesnickFIRsymmetric_lowpass(N,deltap,deltas,Fap,1-deltap,nplot);
    if feasible==false
      printf("K=%g,N=%d,hN not feasible\n",K,N);
      continue;
    endif
    AN=directFIRsymmetricA(w,hN);
    nasNmax=max(find(AN>(deltas+tol)));
    % Find Fas
    FasN=halleyFIRsymmetricA(w(nasNmax),hN,deltas)/(2*pi);
    if FasN<=Fas
      Nfound=true;
      break;
    else
      printf("K=%g,N=%d,hN feasible but Fas=%g<FasN=%g\n",K,N,Fas,FasN);
    endif
  endfor
  if Nfound
    printf("Found feasible N=%d,K=%g\n",N,K);
    %{
      % Recalculate deltaphat and deltashat
      cosOmegasN=cos(2*pi*FasN);
      deltahat=[3+cosOmegap,-1+cosOmegap;1+cosOmegasN,-3+cosOmegasN] ...
               \[1-cosOmegap;-1-cosOmegasN];
      deltaphat=deltahat(1);
      deltashat=deltahat(2);
      A=(1+deltaphat+deltashat)/2;
      B=(1+deltaphat-deltashat)/2;
    %}
    % Store results
    Kmin=[Kmin,K];
    Nmin=[Nmin,N];
    deltaphatmin=[deltaphatmin,deltaphat];
    deltashatmin=[deltashatmin,deltashat];
    Amin=[Amin,A];
    Bmin=[Bmin,B];
    Fapmin=[Fapmin,Fap];
    Fasmin=[Fasmin,Fas];
    hMmin=[hMmin,hM(:)];
    hNmin{length(Kmin)}=hN(:);
    AMmin=[AMmin,AM];
    ANmin=[ANmin,AN];
    FasNmin=[FasNmin,FasN];
    % Calculate the filter response and RMS error
    Omega=acos((AM-B)/A);
    Omegamin=[Omegamin,Omega(:)];
    ANM=directFIRsymmetricA(Omega,hN);
    ANMmin=[ANMmin,ANM(:)];
    E=norm((Ad-ANM)/nplot);
    Emin=[Emin,E];
  else
    printf("Minimum order prototype filter not found at K=%g\n",K);
  endif
endfor

% Choose the minimum order prototype filter with minimum RMS error E
N=min(Nmin);
kminNmin=find(Nmin==N);
[E,kEmin]=min(Emin(kminNmin));
kNEmin=kminNmin(kEmin);
K=Kmin(kNEmin);
Fap=Fapmin(kNEmin);
Fas=Fasmin(kNEmin);
FasN=FasNmin(kNEmin);
A=Amin(kNEmin);
B=Bmin(kNEmin);
AM=AMmin(:,kNEmin);
Omega=Omegamin(:,kNEmin);
AN=ANmin(:,kNEmin);
ANM=ANMmin(:,kNEmin);
hM=hMmin(:,kNEmin);
hN=hNmin{kNEmin};

% Scale the sub-filter
hM_hat=hM;
hM_hat(M+1)=hM_hat(M+1)-B;
hM_hat=hM_hat/A;

% Calculate the direct-form overall filter tap coefficients
aN=[zeros(1,N),hN(N+1)];
for k=1:N,
  aN=aN+[zeros(1,N-k),2*hN(1+N-k)*chebyshevT(k)];
endfor
aN=fliplr(aN);

% Calculate the overall impulse response
hMk=1;
h=zeros((2*N*M)+1,1);
for k=0:N
  h=h+(aN(k+1)*[zeros(((N-k)*M),1);hMk;zeros(((N-k)*M),1)]);
  hMk=conv(hMk,[hM_hat;hM_hat(end-1:-1:1)]);
endfor
% Sanity check
H=freqz(h,1,w);
if norm((H.*exp(j*N*M*w))-ANM)>tol
  error("norm((H.*exp(j*N*M*w))-ANM)(%g)>tol",norm((H.*exp(j*N*M*w))-ANM));
endif

%
% Plot results
%

% Plot subfilter response for minimum prototype filter order 2N
plot(f,Omega/(2*pi));
ylabel("$\\Omega/2\\pi$");
xlabel("Frequency");
grid("on");
strt=sprintf("Saramaki FIR cascade multi-band Approx. II sub-filter : M=%d,N=%d",
             M,N);
title(strt);
print(strcat(strf,"_subfilter_response"),"-dpdflatex");
close

% Plot overall response for minimum subfilter order 2M
plot(f,20*log10(abs(ANM)))
axis([0 0.5 -70 1])
grid("on");
xlabel("Amplitude");
ylabel("Frequency");
strt=sprintf("Saramaki FIR cascade multi-band Approx. II : M=%d,N=%d",M,N);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close
% Pass-band and stop-band detail
ax=plotyy(f,ANM,f,ANM);
axis(ax(1),[0 0.5 1-2*deltap 1+2*deltap])
axis(ax(2),[0 0.5 -2*deltas 2*deltas])
grid("on");
ylabel("Amplitude");
xlabel("Frequency");
title(strt);
print(strcat(strf,"_response_detail"),"-dpdflatex");
close

% Plot three-way response similar to Saramaki Figure 6
Amp_line=linspace(-70,10,length(f));
Fap_line=Fap*ones(size(f));
Fas_line=Fas*ones(size(f));
fasu1_line=fasu1*ones(size(f));
fapl1_line=fapl1*ones(size(f));
fapu1_line=fapu1*ones(size(f));
fasl2_line=fasl2*ones(size(f));
fasu2_line=fasu2*ones(size(f));
fapl2_line=fapl2*ones(size(f));
fapu2_line=fapu2*ones(size(f));
fasl3_line=fasl3*ones(size(f));
line_linewidth=0.5;
line_colour='red';
subplot(221)
plot(20*log10(abs(AN)),f, ...
     Amp_line,Fap_line,"linewidth",line_linewidth,"color",line_colour, ...
     Amp_line,Fas_line,"linewidth",line_linewidth,"color",line_colour);
axis([min(Amp_line) max(Amp_line) min(f) max(f)]);
grid("on");
strt=sprintf("Prototype filter : M=%d,N=%d,$\\delta_{p}$=%g,$\\delta_{s}$=%g",...
             M,N,deltap,deltas);
title(strt);
ylabel("Frequency($\\Omega/2\\pi$)")
xlabel("Amplitude (dB)")
subplot(222)
plot(f,Omega/(2*pi), ...
     f,Fap_line,"linewidth",line_linewidth,"color",line_colour, ...
     f,Fas_line,"linewidth",line_linewidth,"color",line_colour, ...
     fasu1_line,f,"linewidth",line_linewidth,"color",line_colour, ...
     fapl1_line,f,"linewidth",line_linewidth,"color",line_colour, ...
     fapu1_line,f,"linewidth",line_linewidth,"color",line_colour, ...
     fasl2_line,f,"linewidth",line_linewidth,"color",line_colour, ...
     fasu2_line,f,"linewidth",line_linewidth,"color",line_colour, ...
     fapl2_line,f,"linewidth",line_linewidth,"color",line_colour, ...
     fapu2_line,f,"linewidth",line_linewidth,"color",line_colour, ...
     fasl3_line,f,"linewidth",line_linewidth,"color",line_colour);
axis([min(f) max(f) min(f) max(f)]);                      
grid("on");
strt=sprintf("Sub-filter : M=%d,$F_{p}$=%5.3f,$F_{s}$=%5.3f",M,Fap,Fas);
title(strt);
subplot(224)
plot(f,20*log10(abs(ANM)), ...
     fasu1_line,Amp_line,"linewidth",line_linewidth,"color",line_colour, ...
     fapl1_line,Amp_line,"linewidth",line_linewidth,"color",line_colour, ...
     fapu1_line,Amp_line,"linewidth",line_linewidth,"color",line_colour, ...
     fasl2_line,Amp_line,"linewidth",line_linewidth,"color",line_colour, ...
     fasu2_line,Amp_line,"linewidth",line_linewidth,"color",line_colour, ...
     fapl2_line,Amp_line,"linewidth",line_linewidth,"color",line_colour, ...
     fapu2_line,Amp_line,"linewidth",line_linewidth,"color",line_colour, ...
     fasl3_line,Amp_line,"linewidth",line_linewidth,"color",line_colour);
axis([min(f) max(f) min(Amp_line) max(Amp_line)]);
grid("on");
strt=sprintf("Overall cascaded filter : $M$=%d,$N$=%d",M,N);
title(strt);
ylabel("Amplitude(dB)")
xlabel("Frequency($\\omega/2\\pi$)")
print(strcat(strf,"_threeway_response"),"-dpdflatex");
close

% Save prototype and subfilter coefficients
print_polynomial(aN,"aN",strcat(strf,"_tap_coef.m"));
print_polynomial(hN,"hN",strcat(strf,"_prototype_coef.m"));
print_polynomial(hM_hat,"hM",strcat(strf,"_subfilter_coef.m"));

% Make a LaTeX table
fname=strcat(strf,".tab");
fid=fopen(fname,"wt");
fprintf(fid,"\\begin{table}[hptb]\n");
fprintf(fid,"\\centering\n");
fprintf(fid,"\\begin{threeparttable}\n");
fprintf(fid,"\\begin{tabular}{lr}  \\toprule\n");
fprintf(fid,"M & %d \\\\ \n",M);
fprintf(fid,"$f_{su1}$ & %g \\\\ \n",fasu1);
fprintf(fid,"$f_{pl1}$ & %g \\\\ \n",fapl1);
fprintf(fid,"$f_{pu1}$ & %g \\\\ \n",fapu1);
fprintf(fid,"$f_{sl2}$ & %g \\\\ \n",fasl2);
fprintf(fid,"$f_{su2}$ & %g \\\\ \n",fasu2);
fprintf(fid,"$f_{pl2}$ & %g \\\\ \n",fapl2);
fprintf(fid,"$f_{pu2}$ & %g \\\\ \n",fapu2);
fprintf(fid,"$f_{sl3}$ & %g \\\\ \n",fasl3);
fprintf(fid,"$\\delta_{p}$ & %g \\\\ \n",deltap);
fprintf(fid,"$\\delta_{s}$ & %g \\\\ \n",deltas);
fprintf(fid,"\\midrule\n");
fprintf(fid,"$N$ & %d \\\\ \n",N);
fprintf(fid,"$2NM+1$ & %d \\\\ \n",(2*N*M)+1);
fprintf(fid,"$K$ ($W_{s}/W_{p}$) & %8.6f \\\\ \n",K);
fprintf(fid,"$E$ (RMS error) & %8.6f \\\\ \n",E);
fprintf(fid,"$\\Omega_{p}/2\\pi$ & %8.6f \\\\ \n",Fap);
fprintf(fid,"$\\Omega_{s}/2\\pi$ & %8.6f \\\\ \n",Fas);
fprintf(fid,"$\\Omega_{sN}/2\\pi$ & %8.6f \\\\ \n",FasN);
fprintf(fid,"A & %8.6f \\\\ \n",A);
fprintf(fid,"B & %8.6f \\\\ \n",B);
fprintf(fid,"$\\hat{\\delta}_{p}$ & %8.6f \\\\ \n",deltaphat);
fprintf(fid,"$\\hat{\\delta}_{s}$ & %8.6f \\\\ \n",deltashat);
fprintf(fid,"\\bottomrule\n");
fprintf(fid,"\\end{tabular}\n");
fprintf(fid,"\\end{threeparttable}\n");
fprintf(fid,"\\caption[\\emph{Saram\\\"{a}ki} Approximation Problem II]");
fprintf(fid,"{Parameters of \\emph{Saram\\\"{a}ki} FIR cascade Approximation");
fprintf(fid," Problem II multi-band example filter.}");
fprintf(fid,"\\label{tab:Saramaki-FIR-cascade-Approximation-II-example}\n");
fprintf(fid,"\\end{table}\n");
fclose(fid);

% Save filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"%% 2M=%d %% Order of sub-filter\n",2*M);
fprintf(fid,"fasu1=%g %% Amplitude first stop-band upper edge\n",fasu1);
fprintf(fid,"fapl1=%g %% Amplitude first pass band lower edge\n",fapl1);
fprintf(fid,"fapu1=%g %% Amplitude first pass band upper edge\n",fapu1);
fprintf(fid,"fasl2=%g %% Amplitude second stop band lower edge\n",fasl2);
fprintf(fid,"fasu2=%g %% Amplitude second stop band upper edge\n",fasu2);
fprintf(fid,"fapl2=%g %% Amplitude second pass band lower edge\n",fapl2);
fprintf(fid,"fapu2=%g %% Amplitude second pass band upper edge\n",fapu2);
fprintf(fid,"fasl3=%g %% Amplitude third stop band lower edge\n",fasl3);
fprintf(fid,"deltap=%8.6f %% Pass-band ripple\n",deltap);
fprintf(fid,"deltas=%8.6f %% Stop-band ripple\n",deltas);
fprintf(fid,"tol=%g %% Tolerance\n",tol);
fprintf(fid,"nplot=%d %% Frequency points\n",nplot);
fclose(fid);

% Save results
eval(sprintf("save %s.mat ...\n\
 tol nplot M deltap deltas fasu1 fapl1 fapu1 fasl2 fasu2 fapl2 fapu2 fasl3 ...\n\
 kNEmin K E N hN aN Fap Fas FasN deltaphat deltashat A B hM hM_hat ...\n\
 Kmin Nmin deltaphatmin deltashatmin Fapmin Fasmin hMmin ...\n\
 hNmin FasNmin Amin Bmin Emin",strf));

% Done
toc();
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
