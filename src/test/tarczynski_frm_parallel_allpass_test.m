% tarczynski_frm_parallel_allpass_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen
%
% Design an FRM filter from a parallel allpass IIR model filter
% and FIR masking filters using the method of Tarczynski et al.
% Masking filters are not assumed to be symmetric.

test_common;

pkg load optim;

delete("tarczynski_frm_parallel_allpass_test.diary");
delete("tarczynski_frm_parallel_allpass_test.diary.tmp");
diary tarczynski_frm_parallel_allpass_test.diary.tmp

tic;

verbose=true
no_phase=true
strf="tarczynski_frm_parallel_allpass_test";

function [nfrm,dfrm,xr,xrM,xs,xsM,xaa,xac] = ...
          vec2frm_parallel_allpass(adac,mr,ms,na,nc,Mmodel)
  if length(adac) ~= (mr+ms+na+nc)
    error("Expected length(adac) == (mr+ms+na+nc)");
  endif
  adac=adac(:);
  xr=[1;adac(1:mr)];
  xs=[1;adac((mr+1):(mr+ms))];
  xrM=[xr(1);kron(xr(2:end),[zeros(Mmodel-1,1);1])];
  xsM=[xs(1);kron(xs(2:end),[zeros(Mmodel-1,1);1])];
  xaa=adac((mr+ms+1):(mr+ms+na));
  xac=adac((mr+ms+na+1):end);
  if na>nc
    xac=[xac;zeros(na-nc,1)];
  elseif na<nc
    xaa=[xaa;zeros(nc-na,1)];
  endif
  nfrm=(conv(conv(flipud(xrM),xaa+xac),xsM) + ...
        conv(conv(flipud(xsM),xaa-xac),xrM))/2;
  dfrm=conv(xrM,xsM);
endfunction

function E=WISEJ_FRM_PA(adac,_mr,_ms,_na,_nc,_Mmodel, ...
                        _no_phase,_wp,_Hd,_Wp,_ws,_Sd,_Ws)

  persistent mr ms na nc Mmodel wp Hd Wp ws Sd Ws
  persistent no_phase
  persistent init_done=false

  if nargin==13
    mr=_mr; ms=_ms; na=_na; nc=_nc; Mmodel=_Mmodel;
    wp=_wp; Hd=_Hd; Wp=_Wp; ws=_ws; Sd=_Sd; Ws=_Ws;
    no_phase=_no_phase;
    init_done=true;
  endif
  if isempty(adac)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Find the FRM filter polynomials
  [nfrm,dfrm]=vec2frm_parallel_allpass(adac,mr,ms,na,nc,Mmodel);
 
  % Find the response error in the passband
  Hp=freqz(nfrm,dfrm,wp);
  if no_phase
    EHd = Wp.*((abs(Hp)-abs(Hd)).^2);
  else
    EHd = Wp.*((abs(Hp-Hd)).^2);
  endif

  % Find the error response in the stopband
  Hs=freqz(nfrm,dfrm,ws);
  ESd = Ws.*((abs(Hs)-abs(Sd)).^2);

  % Trapezoidal integration of the weighted error
  intEd = sum(diff(wp).*((EHd(1:(length(EHd)-1))+EHd(2:end))/2)) + ...
          sum(diff(ws).*((ESd(1:(length(ESd)-1))+ESd(2:end))/2));
 
  % Heuristics for the barrier function
  lambda = 0.001;
  if (mr+ms) > 0
    bM = (mr+ms)*Mmodel;
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=dfrm./(rho.^(0:(length(dfrm)-1)))';
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    bD=[zeros(nDrho-2,1);1];
    cD=-Drho(nDrho:-1:2);
    dD=1;
    % Calculate barrier function
    f = zeros(bM,1);
    cAD_Tk = cD*(AD^(T-1));
    for k=1:bM
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

if no_phase
  maxiter=2000
  tol=1e-8 % Tolerance on coefficient update vector
  n=200 % Number of frequency points
  mr=8 % Allpass model filter order 
  ms=7 % Allpass model filter order
  na=25 % 21 % Masking filter FIR length
  nc=25 % 21 % Complementary masking filter FIR length
  Mmodel=9 % Decimation
  Dmodel=0 % Desired model filter passband delay
  dmask=0 % Nominal masking filter delay
  Tnominal=0 % Nominal FRM filter passband delay
  fpass=0.3 % Pass band edge
  fstop=0.305 % Stop band edge
  dBas=50 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=10 % Extra pass band amplitude weight for extra points
  Wasextra=500 % Extra stop band amplitude weight for extra points
  Was=100 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edge
  edge_ramp=0 % Linear change of extra weights
else
  maxiter=1000
  tol=1e-5 % Tolerance on coefficient update vector
  n=200 % Number of frequency points
  mr=10 % Allpass model filter order 
  ms=9 % Allpass model filter order
  na=25 % Masking filter FIR length
  nc=25 % Complementary masking filter FIR length
  Mmodel=9 % Decimation
  Dmodel=(mr+ms)/2 % Desired model filter passband delay
  dmask=8.5 % Nominal masking filter delay
  Tnominal=(Mmodel*Dmodel)+dmask % Nominal FRM filter passband delay
  fpass=0.3 % Pass band edge
  fstop=0.31 % Stop band edge
  dBas=50 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=0 % Extra pass band amplitude weight for extra points
  Wasextra=0 % Extra stop band amplitude weight for extra points
  Was=100 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edge
  edge_ramp=0 % Linear change of extra weights
endif
% Frequencies and vectors
[wpass,Hpass,Wpass,wstop,Hstop,Wstop,fadp,fads,faap,faas,facp,facs]=...
frm_lowpass_vectors(n,Mmodel,Dmodel,dmask,fpass,fstop, ...
                    dBas,Wap,Wapextra,Wasextra,Was,edge_factor,edge_ramp);

% Initial model filter
r0=[1;zeros(mr,1)];
s0=[1;zeros(ms,1)];
% Initial masking filter
aa0=remez(na-1,2*[0 faap faas 0.5],[1 1 0 0]);
% Initial complementary masking filter
ac0=remez(nc-1,2*[0 facp facs 0.5],[1 1 0 0]);
% Initial filter vector
adac0=[r0(2:end);s0(2:end);aa0;ac0];

% Unconstrained minimisation
WISEJ_FRM_PA([],mr,ms,na,nc,Mmodel,no_phase,wpass,Hpass,Wpass,wstop,Hstop,Wstop);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[adac1,FVEC,INFO,OUTPUT] = fminunc(@WISEJ_FRM_PA,adac0,opt);
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
[nfrm,dfrm,r1,r1M,s1,s1M,aa1,ac1]= ...
  vec2frm_parallel_allpass(adac1,mr,ms,na,nc,Mmodel);

% Plot overall response
nplot=1000;
[Hw_frm,wplot]=freqz(nfrm,dfrm,nplot);
Tw_frm=delayz(nfrm,dfrm,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)),'linestyle','-');
axis([0 0.5 -60 5]);
ylabel("Amplitude(dB)");
grid("on");
if no_phase
  strt=sprintf("FRM filter:mr=%d,ms=%d,na=%d,nc=%d,Mmodel=%d,Was=%d,tol=%4.3g",
               mr,ms,na,nc,Mmodel,Was,tol);
else
  strt=sprintf("FRM filter:mr=%d,ms=%d,na=%d,nc=%d,Mmodel=%d,Dmodel=%3.1f,\
dmask=%3.1f,Was=%d,tol=%4.3g",mr,ms,na,nc,Mmodel,Dmodel,dmask,Was,tol);
endif
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_frm,'linestyle','-');
axis([0 0.5 0 120]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)),'linestyle','-');
axis([0 fpass -2 2]);
ylabel("Amplitude(dB)");
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_frm,'linestyle','-');
axis([0 fpass 90 100]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Plot masking filter responses
Hw_aa=freqz(aa1,1,nplot);
Tw_aa=delayz(aa1,1,nplot);
Hw_ac=freqz(ac1,1,nplot);
Tw_ac=delayz(ac1,1,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_aa)),'linestyle','-', ...
     wplot*0.5/pi,20*log10(abs(Hw_ac)),'linestyle','--');
legend("Mask","Comp","location","northeast");
legend("boxoff");
axis([0 0.5 -40 5]);
ylabel("Amplitude(dB)");
grid("on");
s=sprintf("FRM masking filters : na=%d,nc=%d",na,nc);
title(s);
subplot(212);
plot(wplot*0.5/pi,Tw_aa,'linestyle','-', ...
     wplot*0.5/pi,Tw_ac,'linestyle','--');
axis([0 0.5 0 30]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_masking_response"),"-dpdflatex");
close

% Plot model filter response
Hw_ad=freqz((conv(r1M,flipud(s1M))+conv(s1M,flipud(r1M)))/2, ...
            conv(r1M,s1M),nplot);
Tw_ad=delayz((conv(r1M,flipud(s1M))+conv(s1M,flipud(r1M)))/2, ...
               conv(r1M,s1M),nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_ad)),'linestyle','-');
axis([0 0.5 -30 10]);
ylabel("Amplitude(dB)");
grid("on");
if no_phase
  s=sprintf("FRM IIR model filter:mr=%d,ms=%d,Mmodel=%d",mr,ms,Mmodel);
else
  s=sprintf("FRM IIR model filter:mr=%d,ms=%d,Mmodel=%d,\
Dmodel=%3.1f,dmask=%3.1f",mr,ms,Mmodel,Dmodel,dmask);
endif
title(s);
subplot(212);
plot(wplot*0.5/pi,Tw_ad,'linestyle','-');
axis([0 0.5 60 100]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_model_response"),"-dpdflatex");
close

% Save the results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%4.1g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mr=%d %% Model filter numerator order (mn+1 coefficients)\n",mr);
fprintf(fid,"ms=%d %% Model filter denominator order (mr coefficients)\n",ms);
fprintf(fid,"na=%d %% Model masking filter FIR length\n",na);
fprintf(fid,"nc=%d %% Model complementary masking filter FIR length\n",nc);
fprintf(fid,"Mmodel=%d %% Decimation\n",Mmodel);
fprintf(fid,"Dmodel=%3.1f %% Model filter pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%3.1f %% Masking filter nominal delay\n",dmask);
fprintf(fid,"fpass=%5.3g %% Pass band edge\n",fpass);
fprintf(fid,"fstop=%5.3g %% Stop band edge\n",fstop);
fprintf(fid,"dBas=%d %% Stop band attenuation\n",dBas);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"Wapextra=%d %% Extra weight for extra pass band points\n",Wapextra);
fprintf(fid,"Wasextra=%d %% Extra weight for extra stop band points\n",Wasextra);
fprintf(fid,"Was=%d %% Stop band weight\n",Was);
fprintf(fid,"edge_factor=%3.1g %% Add extra frequencies near band edges\n",
        edge_factor);
fprintf(fid,"edge_ramp=%d %% Linear change in extra weights over edge region\n",
        edge_ramp);
fclose(fid);
print_polynomial(r1,"x0.r");
print_polynomial(r1,"r",strcat(strf,"_r_coef.m"));
print_polynomial(s1,"x0.s");
print_polynomial(s1,"s",strcat(strf,"_s_coef.m"));
print_polynomial(aa1,"x0.aa");
print_polynomial(aa1,"aa",strcat(strf,"_aa_coef.m"));
print_polynomial(ac1,"x0.ac");
print_polynomial(ac1,"ac",strcat(strf,"_ac_coef.m"));

save tarczynski_frm_parallel_allpass_test.mat ...
     nfrm dfrm r1 s1 aa1 ac1 Mmodel Dmodel dmask mr ms na nc ...
     fpass fstop Wap Wapextra Wasextra Was

% Done
toc;
diary off
movefile tarczynski_frm_parallel_allpass_test.diary.tmp ...
         tarczynski_frm_parallel_allpass_test.diary;
