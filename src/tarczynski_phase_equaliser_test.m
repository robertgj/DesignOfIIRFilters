% tarczynski_phase_equaliser_test.m
% Copyright (C) 2018-2020 Robert G. Jenssen

test_common;

delete("tarczynski_phase_equaliser_test.diary");
delete("tarczynski_phase_equaliser_test.diary.tmp");
diary tarczynski_phase_equaliser_test.diary.tmp

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
    T1=grpdelay(N1,D1,nf);

    % Plot results
    subplot(211)
    plot(w*0.5/pi,20*log10(abs(H1(:))));
    ylabel("Amplitude(dB)");
    axis([0 0.5 -60 0]);
    grid("on");
    s=sprintf("Elliptic filter with all-pass delay equaliser : \
nh=%d,na=%d,ftp=%g,tp=%g",nh,na,ftp,tp);
    title(s);
    subplot(212)
    plot(w*0.5/pi,T1(:)-tp);
    axis([0 0.5 -2 2]);
    ylabel("Delay error(samples)");
    xlabel("Frequency");
    grid("on");
    strf=sprintf("tarczynski_phase_equaliser_test_nh%d_na%d_%%s",nh,na);
    print(sprintf(strf,"a1"),"-dpdflatex");
    close
    subplot(111)
    zplane(N1',D1');
    grid("on");
    title(s);
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
