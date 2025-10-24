% tarczynski_phase_equaliser_test.m
% Copyright (C) 2018-2025 Robert G. Jenssen

test_common;

pkg load optim;

delete("tarczynski_phase_equaliser_test.diary");
delete("tarczynski_phase_equaliser_test.diary.tmp");
diary tarczynski_phase_equaliser_test.diary.tmp

function E=WISEJ_PhaseEq(a,_Va,_Qa,_Ra,_x,_Ux,_Vx,_Mx,_Qx,_Rx,_w,_tp)
% E=WISEJ_PhaseEq(a,Va,Qa,Ra,x,Ux,Vx,Mx,Qx,Rx,w,tp)
% Objective function for equalising the group delay of the response
% of an IIR filter with gain, zeros and poles given by x, Ux, Vx, Mx,
% Qx, Rx, and nominal group delay, tp, over angular frequencies, w, using
% the method of Tarczynski et al. See "A WISE Method for Designing IIR
% Filters", A. Tarczynski et al., IEEE Transactions on Signal Processing,
% Vol. 49, No. 7, pp. 1421-1432

  persistent Va Qa Ra x Ux Vx Mx Qx Rx w tp
  persistent Px init_done=false

  if (nargin ~= 1) && (nargin ~= 12)
    print_usage("E=WISEJ_PhaseEq(a[,Va,Qa,Ra,x,Ux,Vx,Mx,Qx,Rx,w,tp])");
  elseif nargin==12
    Va=_Va;Qa=_Qa;Ra=_Ra;
    x=_x;Ux=_Ux;Vx=_Vx;Mx=_Mx;Qx=_Qx;Rx=_Rx;
    w=_w(:);tp=_tp;
    Px=iirP(w,x,Ux,Vx,Mx,Qx,Rx);
    init_done=true;
     return;
  elseif ~init_done
    error("~init_done");    
  endif

  % Calculate phase or group delay error
  Pa=allpassP(w,a,Va,Qa,Ra);
  E=(Pa+Px+(tp*w)).^2;
  intE=sum(diff(w).*(E(1:(end-1))+E(2:end)))/2;
  
  % Heuristics for the barrier function
  [~,Da]=a2tf(a,Va,Qa,Ra);
  Da=Da(:)';
  nDa=length(Da)-1;
  lambda = 0.001;
  t = 300;
  rho = 31/32;
  % Calculate barrier function state-variable filter
  Drho=Da./(rho.^(0:nDa));
  Drho=Drho/Drho(1);
  nDrho=length(Drho);
  AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
  bD=[zeros(nDrho-2,1);1];
  cD=-Drho(nDrho:-1:2);
  dD=1;
  % Calculate barrier function error
  f = zeros(nDa,1);
  cAD_t = cD*(AD^(t-1));
  for k=1:nDa
    f(k) = cAD_t*bD;
    cAD_t = cAD_t*AD;
  endfor
  f = real(f);
  EJ = sum(f.*f);

  % Return error
  E=((1-lambda)*intE)+(lambda*EJ); 
endfunction

tic;

tol=1e-3
maxiter=1000
verbose=false

% Filter specifications
for nh=3:4,
  for na=3:4,
    fap=0.1,dBap=1
    ftp=0.08,tp=2+nh+na
    fas=0.15,dBas=40

    % Frequency points
    nf=1024;
    nap=ceil(nf*fap/0.5)+1;
    nas=floor(nf*fas/0.5)+1;  
    ntp=ceil(nf*ftp/0.5)+1;
    w=(0:(nf-1))'*pi/nf;

    % Unconstrained minimisation
    [N0,D0]=ellip(nh,dBap,dBap,2*fap);
    [x0,Ux,Vx,Mx,Qx]=tf2x(N0,D0);
    Rx=1;
    [~,A0]=butter(na,2*fap);
    [a0,Va,Qa]=tf2a(A0);
    Ra=1;
    WISEJ_PhaseEq([],Va,Qa,Ra,x0,Ux,Vx,Mx,Qx,Rx,w(1:ntp),tp);
    opt=optimset("TolFun",tol,"TolX",tol, ...
                 "MaxIter",maxiter,"MaxFunEvals",maxiter);
    [a1,FVEC1,INFO,OUTPUT]=fminunc(@WISEJ_PhaseEq,a0,opt);
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
    printf("Function value=%f\n", FVEC1);
    printf("fminunc iterations=%d\n", OUTPUT.iterations);
    printf("fminunc successful=%d??\n", OUTPUT.successful);
    printf("fminunc funcCount=%d\n", OUTPUT.funcCount);
    [~,Da1]=a2tf(a1,Va,Qa,Ra);
    N1=conv(N0(:),flipud(Da1(:)));
    D1=conv(D0(:),Da1(:));
    H1=freqz(N1,D1,nf);
    T1=delayz(N1,D1,nf);

    % Plot results
    subplot(211)
    plot(w*0.5/pi,20*log10(abs(H1(:))));
    ylabel("Amplitude(dB)");
    axis([0 0.5 -60 0]);
    grid("on");
    s=sprintf(["Elliptic filter with all-pass delay equaliser : ", ...
               "nh=%d,na=%d,ftp=%g,tp=%g"],nh,na,ftp,tp);
    title(s);
    subplot(212)
    plot(w*0.5/pi,T1(:)-tp);
    axis([0 0.5 -2 2]);
    ylabel("Delay error(samples)");
    xlabel("Frequency");
    grid("on");
    strf=sprintf("tarczynski_phase_equaliser_test_nh%d_na%d_%%s",nh,na);
zticks([]);
    print(sprintf(strf,"a1"),"-dpdflatex");
    close
    subplot(111)
    zplane(N1',D1');
    grid("on");
    title(s);
zticks([]);
    print(sprintf(strf,"a1pz"),"-dpdflatex");
    close

    % Show a1
    print_polynomial(a1,"a1",sprintf(strf,"a1_coef.m"),"%12.8f");
  endfor
endfor

% Done
diary off
movefile tarczynski_phase_equaliser_test.diary.tmp ...
         tarczynski_phase_equaliser_test.diary;
