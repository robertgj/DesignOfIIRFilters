% tarczynski_frm_allpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Design an FRM filter from IIR allpass model in parallel with a delay
% and FIR masking filters using the method of Tarczynski et al. The 
% masking filters have odd lengths (ie: even order) and are symmetric
% (ie: linear phase).

test_common;

pkg load optim;

delete("tarczynski_frm_allpass_test.diary");
delete("tarczynski_frm_allpass_test.diary.tmp");
diary tarczynski_frm_allpass_test.diary.tmp

tic;

verbose=true
maxiter=5000
strf="tarczynski_frm_allpass_test";

function [n,rRM,r,aa,ac]=vec2frm_allpass(rac,mr,na,nc,R,Mmodel,Dmodel)
  rac=rac(:);
  r=[1;rac(1:mr)];
  rRM=[1;kron(rac(1:mr),[zeros((R*Mmodel)-1,1);1])];
  aa=rac((mr+1):(mr+((na+1)/2)));
  aa=[aa;flipud(aa(1:((na-1)/2)))];
  ac=rac((mr+((na+1)/2)+1):end);
  ac=[ac;flipud(ac(1:((nc-1)/2)))];
  if na>nc
    ac=[zeros((na-nc)/2,1);ac; zeros((na-nc)/2,1)];
  elseif na<nc
    aa=[zeros((nc-na)/2,1);aa; zeros((nc-na)/2,1)];
  endif
  n=([conv(flipud(rRM),aa+ac);zeros(Mmodel*Dmodel,1)] + ...
     [zeros(Mmodel*Dmodel,1);conv(aa-ac,rRM)])/2;
endfunction

function E=WISEJ_FRM_AP(rac,_mr,_na,_nc,_R,_Mmodel,_Dmodel, ...
                        _wa,_Ad,_Wa,_ws,_Sd,_Ws)

  persistent mr na nc R Mmodel Dmodel wa Ad Wa ws Sd Ws
  persistent init_done=false

  if nargin==13
    mr=_mr; na=_na; nc=_nc; R=_R; Mmodel=_Mmodel; Dmodel=_Dmodel;
    wa=_wa; Ad=_Ad; Wa=_Wa; ws=_ws; Sd=_Sd; Ws=_Ws;
    init_done=true;
  endif
  if isempty(rac)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Find the FRM filter polynomials
  [n,rRM]=vec2frm_allpass(rac,mr,na,nc,R,Mmodel,Dmodel);
 
  % Find the error response in the passband
  Ha=freqz(n,rRM,wa);
  EAd = Wa.*(abs(Ha-Ad).^2);

  % Find the error response in the stopband
  Hs=freqz(n,rRM,ws);
  ESd = Ws.*((abs(Hs)-abs(Sd)).^2);

  % Trapezoidal integration of the weighted error
  intEd = sum(diff(wa).*((EAd(1:(length(EAd)-1))+EAd(2:end))/2)) + ...
          sum(diff(ws).*((ESd(1:(length(ESd)-1))+ESd(2:end))/2));
 
  % Heuristics for the barrier function
  lambda = 0.001;
  if mr > 0
    bRM = mr*R*Mmodel;
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=rRM./(rho.^(0:(length(rRM)-1)))';
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    bD=[zeros(nDrho-2,1);1];
    cD=-Drho(nDrho:-1:2);
    dD=1;
    % Calculate barrier function
    f = zeros(bRM,1);
    cAD_Tk = cD*(AD^(T-1));
    for k=1:bRM
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
if 0
  % For iir_frm_allpass_test.m
  tol=1e-4 % Tolerance on coefficient update vector
  n=1000 % Number of frequency points
  R=2 % Model filter decimation factor
  mr=5 % Model filter numerator order
  fpass=0.3 % Pass band edge
  fstop=0.31 % Stop band edge
  Mmodel=9 % Decimation of model filter
  Dmodel=9 % Desired model filter passband delay  
  na=41 % Masking filter FIR length
  nc=41 % Complementary masking filter FIR length
  dmask=(max(na,nc)-1)/2 % Nominal masking filter delay (assumes odd length)
  dBas=60 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=1 % Extra pass band amplitude weight for extra points
  Wasextra=0 % 200 % Extra stop band amplitude weight for extra points
  Was=200 % 200 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edges
  edge_ramp=1 % Linear change of extra weights
elseif 0
  % For FRM halfband filter
  tol=1e-4 % Tolerance on coefficient update vector
  n=400 % Number of frequency points
  R=2 % Model filter decimation factor
  mr=5 % Model filter order is mr*R (mr+1 coefficients)
  na=33 % Masking filter FIR length
  nc=33 % Complementary masking filter FIR length
  Mmodel=7 % Decimation
  Dmodel=9 % Desired model filter passband delay
  dmask=(max(na,nc)-1)/2 % Nominal masking filter delay (assumes odd length)
  fpass=0.24 % Pass band edge
  fstop=0.26 % Stop band edge
  dBas=50 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=0 % Extra pass band amplitude weight for extra points
  Wasextra=0 % Extra stop band amplitude weight for extra points
  Was=100 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edges
  edge_ramp=0 % Linear change of extra weights
else
  % For iir_frm_allpass_socp_slb_test.m
  tol=1e-4 % Tolerance on coefficient update vector
  n=1000 % Number of frequency points
  R=1 % Model filter decimation factor
  mr=10 % Model filter numerator order
  fpass=0.3 % Pass band edge
  fstop=0.31 % Stop band edge
  Mmodel=9 % Decimation of model filter
  Dmodel=9 % Desired model filter passband delay  
  na=41 % Masking filter FIR length
  nc=41 % Complementary masking filter FIR length
  dmask=(max(na,nc)-1)/2 % Nominal masking filter delay (assumes odd length)
  dBas=40 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=1 % Extra pass band amplitude weight for extra points
  Wasextra=1 % Extra stop band amplitude weight for extra points
  Was=10 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edges
  edge_ramp=1 % Linear change of extra weights
endif

% Frequencies and vectors
[wpass,Hpass,Wpass,wstop,Hstop,Wstop,fadp,fads,faap,faas,facp,facs]= ...
  frm_lowpass_vectors(n,Mmodel,Dmodel,dmask, ...
                      fpass,fstop,dBas,Wap,Wapextra,Wasextra,Was, ...
                      edge_factor,edge_ramp);

% Initial model filter
r0=[1;zeros(mr,1)];
% Initial masking filter
aa0=remez(na-1,2*[0 faap faas 0.5],[1 1 0 0]);
% Initial complementary masking filter
ac0=remez(nc-1,2*[0 facp facs 0.5],[1 1 0 0]);
% Initial filter vector
rac0=[r0(2:end);aa0(1:((na+1)/2));ac0(1:((nc+1)/2))];

% Unconstrained minimisation of zero phase response
WISEJ_FRM_AP([],mr,na,nc,R,Mmodel,Dmodel,wpass,Hpass,Wpass,wstop,Hstop,Wstop);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[rac1,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_FRM_AP,rac0,opt);
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
[n1,rRM1,r1,aa1,ac1]=vec2frm_allpass(rac1,mr,na,nc,R,Mmodel,Dmodel);

% Calculate filter response
nplot=512;
[Hw_frm,wplot]=freqz(n1,rRM1,nplot);
Tw_frm=delayz(n1,rRM1,nplot);
Hw_aa=freqz(aa1,1,nplot);
Hw_ac=freqz(ac1,1,nplot);
n_model=([flipud(rRM1);zeros(Mmodel*Dmodel,1)] + ...
         conv([zeros(Mmodel*Dmodel,1);1],rRM1))/2;
Hw_model=freqz(n_model,rRM1,nplot);
Tw_model=delayz(n_model,rRM1,nplot);

% Plot overall response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf(["FRM allpass/delay filter : ", ...
 "fpass=%g,mr=%d,na=%d,nc=%d,R=%d,Mmodel=%d,Dmodel=%d,Was=%d"], ...
          fpass,mr,na,nc,R,Mmodel,Dmodel,Was);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_frm);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 80 120]);
grid("on");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)));
ylabel("Amplitude(dB)");
axis([0 fpass -0.4 0.4]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_frm);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 fpass 90 110]);
grid("on");
zticks([]);
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Plot masking filter responses
subplot(111);
plot(wplot*0.5/pi,20*log10(abs(Hw_aa)),wplot*0.5/pi,20*log10(abs(Hw_ac)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf("FRM masking filters : na=%d,nc=%d",na,nc);
title(strt);
zticks([]);
print(strcat(strf,"_masking_response"),"-dpdflatex");
close

% Plot model filter response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_model)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf(["FRM allpass model filter plus delay : ", ...
 "mr=%d,R=%d,Mmodel=%d,Dmodel=%d"],mr,R,Mmodel,Dmodel);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_model);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 50 150]);
grid("on");
zticks([]);
print(strcat(strf,"_model_response"),"-dpdflatex");
close

% Save the results
print_polynomial(r1,"r1");
print_polynomial(r1,"r1",strcat(strf,"_r1_coef.m"));
print_polynomial(aa1,"aa1");
print_polynomial(aa1,"aa1",strcat(strf,"_aa1_coef.m"));
print_polynomial(ac1,"ac1");
print_polynomial(ac1,"ac1",strcat(strf,"_ac1_coef.m"));

save tarczynski_frm_allpass_test.mat ...
    r1 rRM1 aa1 ac1 R Mmodel Dmodel mr na nc fpass fstop Was

% Done
toc;
diary off
movefile tarczynski_frm_allpass_test.diary.tmp tarczynski_frm_allpass_test.diary;
