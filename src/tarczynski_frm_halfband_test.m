% tarczynski_frm_halfband_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Design an FRM filter from IIR halfband model in parallel with a delay
% and FIR masking filters using the method of Tarczynski et al. The 
% masking filters have odd lengths (ie: even order) and are symmetric
% (ie: linear phase). See "A class of FRM-based all-pass digital filters with
% applications in half-band filters and Hilbert transformers", L. Milić et al.

test_common;

unlink("tarczynski_frm_halfband_test.diary");
unlink("tarczynski_frm_halfband_test.diary.tmp");
diary tarczynski_frm_halfband_test.diary.tmp

tic;

format compact
verbose=true
maxiter=5000
strf="tarczynski_frm_halfband_test";

function [n,r2M,r,aa,ac,au,av,q]=vec2frm_halfband(ra,mr,na,Mmodel,Dmodel)
  % Model filter
  ra=ra(:);
  r=[1;ra(1:mr)];
  r2M=zeros((2*Mmodel*mr)+1,1);
  r2M(1:(2*Mmodel):end)=r;

  % FIR masking filters
  dmask=(na-1)/2;
  aa=ra((mr+1):(mr+dmask+1));
  aa=[aa;flipud(aa(1:dmask))];
  zdmask=[zeros(dmask,1);1;zeros(dmask,1)];
  aam1=ones(size(aa));
  aam1(2:2:end)=-1;
  ac=(aa.*aam1)-zdmask;

  % Calculate numerator polynomial
  zDM=zeros(Dmodel*Mmodel,1);
  if nargout<=5
    n=0.5*([conv(flipud(r2M),aa+ac);zDM] + [zDM;conv(r2M,aa-ac)]);
  else
    au=zeros(size(aa));
    au(1:2:end)=aa(1:2:end);
    av=zeros(size(aa));
    av(2:2:end)=aa(2:2:end);
    q=[conv(flipud(r2M),(2*au)-zdmask);zDM] + [zDM;conv(r2M,2*av)];
    n=0.5*(q+[zeros((Dmodel*Mmodel)+dmask,1);r2M;zeros(dmask,1)]);
  endif
endfunction

function E=WISEJ_FRM_HB(ra,_mr,_na,_Mmodel,_Dmodel,_wa,_Ad,_Wa,_ws,_Sd,_Ws)

  persistent mr na Mmodel Dmodel wa Ad Wa ws Sd Ws
  persistent init_done=false

  if nargin==11
    mr=_mr; na=_na; Mmodel=_Mmodel; Dmodel=_Dmodel;
    wa=_wa; Ad=_Ad; Wa=_Wa; ws=_ws; Sd=_Sd; Ws=_Ws;
    init_done=true;
  endif
  if isempty(ra)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Find the FRM filter polynomials
  [n,r2M]=vec2frm_halfband(ra,mr,na,Mmodel,Dmodel);
 
  % Find the error response in the passband
  Ha=freqz(n,r2M,wa);
  EAd = Wa.*(abs(Ha-Ad).^2);

  % Find the error response in the stopband
  Hs=freqz(n,r2M,ws);
  ESd = Ws.*((abs(Hs)-abs(Sd)).^2);

  % Trapezoidal integration of the weighted error
  intEd = sum(diff(wa).*((EAd(1:(length(EAd)-1))+EAd(2:end))/2)) + ...
          sum(diff(ws).*((ESd(1:(length(ESd)-1))+ESd(2:end))/2));
 
  % Heuristics for the barrier function
  lambda = 0.001;
  if mr > 0
    b2M = mr*2*Mmodel;
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=r2M./(rho.^(0:(length(r2M)-1)))';
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    bD=[zeros(nDrho-2,1);1];
    cD=-Drho(nDrho:-1:2);
    dD=1;
    % Calculate barrier function
    f = zeros(b2M,1);
    cAD_Tk = cD*(AD^(T-1));
    for k=1:b2M
      f(k) = cAD_Tk*bD;
      cAD_Tk = cAD_Tk*AD;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intEd) + (lambda*EJ);
endfunction

% Filter specification (based on Lu and Hinamoto example)
tol=1e-4 % Tolerance on coefficient update vector
n=400 % Number of frequency points
if 1
  mr=5 % R=2 allpass model filter order is mr*2 with mr coefficients
  na=33 % FIR masking filter length
  Mmodel=7 % Decimation
  Dmodel=9 % Desired model filter passband delay
else
  mr=6 % R=2 allpass model filter order is mr*2 with mr coefficients
  na=41 % FIR masking filter length
  Mmodel=9 % Decimation
  Dmodel=11 % Desired model filter passband delay
endif
dmask=(na-1)/2 % Nominal masking filter delay (assumes odd length)
td=(Mmodel*Dmodel)+dmask % Nominal FRM filter delay
fpass=0.24 % Pass band edge
fstop=0.26 % Stop band edge
dBas=50 % Stop band attenuation
Wap=1 % Pass band weight
Wapextra=0 % Extra pass band amplitude weight for extra points
Wasextra=0 % Extra stop band amplitude weight for extra points
Was=10 % Stop band amplitude weight
edge_factor=0.1 % Add extra frequencies near band edges
edge_ramp=0 % Linear change of extra weights

% Frequencies and vectors
[wpass,Hpass,Wpass,wstop,Hstop,Wstop,fadp,fads,faap,faas,facp,facs]= ...
  frm_lowpass_vectors(n,Mmodel,Dmodel,dmask, ...
                      fpass,fstop,dBas,Wap,Wapextra,Wasextra,Was, ...
                      edge_factor,edge_ramp);
% Initial model filter
r0=[1;zeros(mr,1)];
% Initial masking filter
aa0=remez(na-1,2*[0 faap faas 0.5],[1 1 0 0]);
% Initial filter vector
ra0=[r0(2:end);aa0(1:((na+1)/2))];

% Unconstrained minimisation of zero phase response
WISEJ_FRM_HB([],mr,na,Mmodel,Dmodel,wpass,Hpass,Wpass,wstop,Hstop,Wstop);
[ra1,FVEC,INFO,OUTPUT] = ...
  fminunc(@WISEJ_FRM_HB,ra0,optimset("TolFun",tol,"TolX",tol));
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -1)
  printf("Algorithm terminated by OutputFcn.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Create the output polynomials
[n1,r2M1,r1,aa1,ac1,au1,av1,q1]=vec2frm_halfband(ra1,mr,na,Mmodel,Dmodel);

% Calculate filter response
nplot=512;
[Hw_frm,wplot]=freqz(n1,r2M1,nplot);
Tw_frm=grpdelay(n1,r2M1,nplot);
Hw_aa=freqz(aa1,1,nplot);
Hw_ac=freqz(ac1,1,nplot);
n_model=([flipud(r2M1);zeros(Mmodel*Dmodel,1)] + ...
         conv([zeros(Mmodel*Dmodel,1);1],r2M1))/2;
Hw_model=freqz(n_model,r2M1,nplot);
Tw_model=grpdelay(n_model,r2M1,nplot);

% Plot overall response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)));
ylabel("Amplitude(dB)");
axis([0 0.5 -70 10]);
grid("on");
strt=sprintf("F2M halfband/delay filter : \
fpass=%g,mr=%d,na=%d,Mmodel=%d,Dmodel=%d,Was=%d", ...
             fpass,mr,na,Mmodel,Dmodel,Was);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_frm);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-10 td+10]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)));
ylabel("Amplitude(dB)");
axis([0 0.25 -0.2 0.2]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_frm);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.25 td-2 td+2]);
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Plot masking filter responses
subplot(111);
plot(wplot*0.5/pi,20*log10(abs(Hw_aa)),"-", ...
     wplot*0.5/pi,20*log10(abs(Hw_ac)),"-.");
ylabel("Amplitude(dB)");
axis([0 0.5 -70 10]);
grid("on");
legend("Fma","Fmc","location","northeast");
legend("boxoff");
strt=sprintf("F2M masking filters : na=%d,",na);
title(strt);
print(strcat(strf,"_masking_response"),"-dpdflatex");
close

% Plot model filter response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_model)));
ylabel("Amplitude(dB)");
axis([0 0.5 -70 10]);
grid("on");
strt=sprintf("F2M halfband model filter plus delay : mr=%d,Mmodel=%d,Dmodel=%d",
             mr,Mmodel,Dmodel);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_model);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 60 120]);
grid("on");
print(strcat(strf,"_model_response"),"-dpdflatex");
close

% Calculate Hilbert function response
qm1=zeros(((2*mr+Dmodel)*Mmodel)+na,1);
qm1(1:4:end)=1;
qm1(3:4:end)=-1;
rm1=zeros((2*mr*Mmodel)+1,1);
rm1(1:(4*Mmodel):end)=1;
rm1(((2*Mmodel)+1):(4*Mmodel):end)=-1;
Hw_hilbert=freqz(q1.*qm1,r2M1.*rm1,wplot);
Tw_hilbert=grpdelay(q1.*qm1,r2M1.*rm1,nplot);
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(Hw_hilbert)))
ylabel("Amplitude(dB)");
axis([0 0.5 -0.1 0.1]);
grid("on");
strt=sprintf("F2M halfband Hilbert filter : mr=%d,Mmodel=%d,Dmodel=%d,na=%d",
             mr,Mmodel,Dmodel,na);
title(strt);
subplot(312);
plot(wplot*0.5/pi,(unwrap(arg(Hw_hilbert))+(wplot.*td))/pi)
ylabel("Phase(rad./pi)\Adjusted for delay");
xlabel("Frequency");
axis([0 0.5 -0.504 -0.496]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,Tw_hilbert);
ylabel("Group delay (samples)");
axis([0 0.5 td-1 td+1]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save the results
print_polynomial(r1,"r1");
print_polynomial(r1,"r1",strcat(strf,"_r1_coef.m"));
print_polynomial(aa1,"aa1");
print_polynomial(aa1,"aa1",strcat(strf,"_aa1_coef.m"));

save tarczynski_frm_halfband_test.mat ...
     n1 r1 r2M1 aa1 q1 au1 av1 Mmodel Dmodel dmask mr na fpass fstop ...
     dBas Wap Wapextra Was Wasextra edge_factor edge_ramp n tol nplot wplot

% Done
toc;
diary off
movefile tarczynski_frm_halfband_test.diary.tmp ...
         tarczynski_frm_halfband_test.diary;
