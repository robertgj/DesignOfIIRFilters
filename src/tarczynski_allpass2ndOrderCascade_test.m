% tarczynski_allpass2ndOrderCascade_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen
%
% Design a lowpass filter that is the parallel combination of two 2nd order
% cascade allpass filters using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

delete("tarczynski_allpass2ndOrderCascade_test.diary");
delete("tarczynski_allpass2ndOrderCascade_test.diary.tmp");
diary tarczynski_allpass2ndOrderCascade_test.diary.tmp

tic;

verbose=true;

% Objective function
function E=WISEJ_AB(ab,_flat_delay,_ma,_mb, ...
                    _wa,_Ad,_Wa,_ws,_Sd,_Ws,_wt,_Td,_Wt,_verbose)
  persistent flat_delay ma mb wa Ad Wa ws Sd Ws wt Td Wt verbose
  persistent init_done=false
  if nargin==14
    flat_delay=_flat_delay;
    ma=_ma;mb=_mb;
    wa=_wa;Ad=_Ad;Wa=_Wa;
    ws=_ws;Sd=_Sd;Ws=_Ws;
    wt=_wt;Td=_Td;Wt=_Wt;
    verbose=_verbose;
    % Sanity checks
    if (length(wa) ~= length(Ad))
      error("Expected length(Ad) == length(Ad)!");
    endif
    if (length(wa) ~= length(Wa))
      error("Expected length(wa) == length(Wa)!");
    endif
    if (length(ws) ~= length(Sd))
      error("Expected length(Sd) == length(Sd)!");
    endif
    if (length(ws) ~= length(Ws))
      error("Expected length(ws) == length(Ws)!");
    endif
    if (length(wt) ~= length(Td))
      error("Expected length(wt) == length(Td)!");
    endif
    if (length(wt) ~= length(Wt))
      error("Expected length(wt) == length(Wt)!");
    endif
    % Initialise
    init_done=true;
    if isempty(ab)
      return;
    endif
  elseif nargin~=1
    print_usage
    ("E=WISEJ_AB(ab[,flat_delay,ma,mb,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,verbose])");
  endif
  if init_done == false
    error("init_done==false");
  endif
  if (length(ab) ~= (ma+mb))
    error("Expected length(ab) == (ma+mb)!");
  endif
  if verbose
    printf("WISEJ_AB: ab=[ ");printf(" %g",ab');printf("]'\n");
  endif
  % Passband amplitude error
  Aa=allpass2ndOrderCascade(ab(1:ma),wa);
  Ab=allpass2ndOrderCascade(ab((ma+1):end),wa);
  Aab=0.5*(Aa+Ab);
  if flat_delay
    EAd=(Wa.*abs(Aab-Ad)).^2;
  else
    EAd=(Wa.*(abs(Aab)-abs(Ad))).^2;
  endif
  % Pass band delay error
  if flat_delay
    Pa=allpass2ndOrderCascade(ab(1:ma),wt);
    Pb=allpass2ndOrderCascade(ab((ma+1):end),wt);
    P=unwrap(arg(Pa+Pb));
    ETd=(Wt.*[0;Td(2:end)+(diff(P)./diff(wt))]).^2;
  else
    ETd=zeros(size(wt));
  endif
  % Stop band amplitude error
  Sa=allpass2ndOrderCascade(ab(1:ma),ws);
  Sb=allpass2ndOrderCascade(ab((ma+1):end),ws);
  Sab=0.5*(Sa+Sb);
  ESd=(Ws.*(abs(Sab)-abs(Sd))).^2;
  % Trapezoidal integration of the error
  intEHd = sum(diff(wa).*((EAd(1:(length(EAd)-1))+EAd(2:end))/2)) + ...
           sum(diff(wt).*((ETd(1:(length(ETd)-1))+ETd(2:end))/2)) + ...
           sum(diff(ws).*((ESd(1:(length(ESd)-1))+ESd(2:end))/2));
  % Heuristics for the barrier function
  lambda = 0.001;
  if (ma+mb) > 0
    M = ma+mb;
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    Da=casc2tf(ab(1:ma));
    Da=Da(:)';
    Na=fliplr(Da);
    Db=casc2tf(ab((ma+1):end));
    Db=Db(:)';
    Nb=fliplr(Db);
    D=conv(Da,Db);
    Drho=D./(rho.^(0:(length(D)-1)));
    Drho=Drho/Drho(1);
    nDrho=length(Drho);
    dD=1;
    cD=-Drho(nDrho:-1:2);
    bD=[zeros(nDrho-2,1);1];
    AD=[zeros(nDrho-2,1) eye(nDrho-2); cD];
    % Calculate barrier function
    f = zeros(M,1);
    cAD_Tk = cD*(AD^(T-1));
    for k=1:M
      f(k) = cAD_Tk*bD;
      cAD_Tk = cAD_Tk*AD;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intEHd) + (lambda*EJ);
  if verbose
    printf("E=%g\n",E);
  endif
endfunction

% Filter specification
maxiter=10000;
tol=1e-6;
n=1000;
strf="tarczynski_allpass2ndOrderCascade_test";

for flat_delay=[false,true],
  
  if flat_delay
    display(strcat(strf," with flat delay\n"));
    flatstr="_flat_delay";
    ma=11;
    mb=12;
    fap=0.15;
    Wap=1;
    ftp=0.175;
    td=(ma+mb)/2;
    Wtp=0.25;
    fas=0.2;
    Was=10;
  else 
    display(strcat(strf," without flat delay\n"));
    flatstr="";
    ma=5;
    mb=6;
    fap=0.15;
    Wap=1;
    ftp=0.175;
    td=(ma+mb)/2;
    Wtp=0;
    fas=0.17;
    Was=250;
  endif

  % Frequency points
  nap=ceil(fap*n/0.5)+1;
  wa=pi*(0:(nap-1))'/n;
  ntp=ceil(ftp*n/0.5)+1;
  wt=pi*(0:(ntp-1))'/n;
  nas=floor(fas*n/0.5);
  ws=pi*(nas:(n-1))'/n;

  % Frequency vectors
  Ad=exp(-j*td*wa);
  Wa=Wap*ones(nap,1);
  Td=td*ones(ntp,1);
  Wt=Wtp*ones(ntp,1);
  Sd=zeros(n-nas,1);
  Ws=Was*ones(n-nas,1);

  % Unconstrained minimisation
  abi=0.1*ones(ma+mb,1);
  WISEJ_AB([],flat_delay,ma,mb,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,verbose);
  opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
  [ab0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_AB,abi,opt);
  if (INFO == 1)
    printf("Converged to a solution point.\n");
  elseif (INFO == 2)
    printf("Last relative step size was less that TolX.\n");
  elseif (INFO == 3)
    printf("Last relative decrease in function value was less than TolF.\n");
  elseif (INFO == 0)
    printf("Iteration limit exceeded.\n");
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
  Da0=casc2tf(ab0(1:ma));
  Da0=Da0(:)';
  Na0=fliplr(Da0);
  Db0=casc2tf(ab0((ma+1):(ma+mb)));
  Db0=Db0(:)';
  Nb0=fliplr(Db0);
  N0=0.5*(conv(Na0,Db0)+conv(Nb0,Da0));
  D0=conv(Da0,Db0);

  % Plot results
  nplot=512;

  % Overall frequency response
  [H,wplot]=freqz(N0,D0,nplot);
  T=grpdelay(N0,D0,nplot);
  clf();
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(H)));
  ylabel("Amplitude(dB)");
  axis([0 0.5 -80 5]);
  grid("on");
  if flat_delay
    s=sprintf("Parallel all-pass 2nd order cascade (flat delay): \
ma=%d,mb=%d,fap=%g,fas=%g",ma,mb,fap,fas);
  else
    s=sprintf("Parallel all-pass 2nd order cascade : ma=%d,mb=%d",ma,mb);
  endif
  title(s);
  subplot(212);
  plot(wplot*0.5/pi,T);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  grid("on");
  print(sprintf("%s%s_response",strf,flatstr),"-dpdflatex");
  close
  % Plot passband response
  clf();
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(H)));
  ylabel("Amplitude(dB)");
  axis([0 max(ftp,fap) -3 1]);
  grid("on");
  title(s);
  subplot(212);
  plot(wplot*0.5/pi,T);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  if flat_delay
    axis([0 max(ftp,fap) td-0.5 td+0.5]);
  else
    axis([0 max(ftp,fap) 0 40]);
  endif
  grid("on");
  print(sprintf("%s%s_passband_response",strf,flatstr),"-dpdflatex");
  close
  % Plot passband and stopband response (fails with gnuplot graphics toolkit)
  np=ceil(fap*nplot/0.5)+1;
  ns=floor(fas*nplot/0.5)+1;
  clf();
  subplot(211);
  ax=plotyy(wplot(1:np)*0.5/pi,20*log10(abs(H(1:np))),...
            wplot(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  axis([0 0.5 -3 1]);
  ylabel("Amplitude(dB)");
  grid("on");
  title(s);
  subplot(212);
  ax=plotyy(wplot(1:np)*0.5/pi,T(1:np),wplot(ns:end)*0.5/pi,T(ns:end));
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  ylabel("Delay(samples)");
  xlabel("Frequency");
  grid("on");
  print(sprintf("%s%s_pass_stop_response",strf,flatstr),"-dpdflatex");
  close
  % Plot the relative phase response of the parallel filters
  clf();
  subplot(111);
  Ha=freqz(Na0,Da0,nplot);
  Hb=freqz(Nb0,Db0,nplot);
  plot(wplot*0.5/pi,[unwrap(arg(Ha)),unwrap(arg(Hb))]+wplot*td)
  title(s);
  ylabel("Zero-phase response(rad.)");
  xlabel("Frequency");
  legend("A","B","location","southwest");
  legend("boxoff");
  grid("on");
  print(sprintf("%s%s_ABphase",strf,flatstr),"-dpdflatex");
  close
  % Plot phase response error
  clf();
  subplot(111);
  phase_diff=(unwrap(arg(Ha))-unwrap(arg(Hb)));
  ax=plotyy(wplot(1:np)*0.5/pi,phase_diff(1:np), ...
            wplot(ns:end)*0.5/pi,phase_diff(ns:end));
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  ylabel("Allpass filter phase difference(rad)");
  xlabel("Frequency");
  grid("on");
  title(s);
  print(sprintf("%s%s_phase_error",strf,flatstr),"-dpdflatex");
  close
  % Plot poles and zeros
  zplane(roots(Na0),roots(Da0))
  s=sprintf("All-pass 2nd order cascade A : ma=%d",ma);
  title(s);
  print(sprintf("%s%s_Apz",strf,flatstr),"-dpdflatex");
  close
  zplane(roots(Nb0),roots(Db0))
  s=sprintf("All-pass 2nd order cascade B : mb=%d",mb);
  title(s);
  print(sprintf("%s%s_Bpz",strf,flatstr),"-dpdflatex");
  close
  subplot(111);
  zplane(roots(N0),roots(D0))
  title(s);
  print(sprintf("%s%s_pz",strf,flatstr),"-dpdflatex");
  close

  % Save the filter specification
  fid=fopen(sprintf("%s%s.spec",strf,flatstr),"wt");
  fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
  fprintf(fid,"maxiter=%d %% Maximum optimiser iterations\n",maxiter);
  fprintf(fid,"n=%d %% Frequency points across the band\n",n);
  fprintf(fid,"flat_delay=%d %% Optimise for flat pass band delay\n",flat_delay);
  fprintf(fid,"ma=%d %% Allpass model filter A denominator order\n",ma);
  fprintf(fid,"mb=%d %% Allpass model filter B denominator order\n",mb);
  fprintf(fid,"td=%d %% Filter delay\n",td);
  fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
  fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
  fprintf(fid,"ftp=%d %% Pass band group delay response edge\n",ftp);
  fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
  fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
  fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
  fclose(fid);

  % Save the result
  print_polynomial(ab0,"ab0");
  print_polynomial(ab0,"ab0",sprintf("%s%s_ab0_coef.m",strf,flatstr));
  print_polynomial(Da0,"Da0");
  print_polynomial(Da0,"Da0",sprintf("%s%s_Da0_coef.m",strf,flatstr));
  print_polynomial(Db0,"Db0");
  print_polynomial(Db0,"Db0",sprintf("%s%s_Db0_coef.m",strf,flatstr));

endfor

% Done
toc;
diary off
save tarczynski_allpass2ndOrderCascade_test.mat ...
     tol maxiter n ma mb td fap Wap ftp Wtp fas Was abi ab0
movefile tarczynski_allpass2ndOrderCascade_test.diary.tmp ...
         tarczynski_allpass2ndOrderCascade_test.diary;
