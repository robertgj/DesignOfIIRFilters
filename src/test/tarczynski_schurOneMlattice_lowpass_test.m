% tarczynski_schurOneMlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Design a Schur one-multiplier lattice lowpass filter using the method
% of Tarczynski et al. to optimise the lattice coefficients directly.

test_common;

pkg load optim;

delete("tarczynski_schurOneMlattice_lowpass_test.diary");
delete("tarczynski_schurOneMlattice_lowpass_test.diary.tmp");
diary tarczynski_schurOneMlattice_lowpass_test.diary.tmp

tic;

verbose=true

function E=WISEJ_ONEM(kc,_k0,_c0,_k_max,_k_active,_c_active, ...
                      _wa,_Asqd,_Wa,_wt,_Td,_Wt)

  persistent k0 c0 k_max k_active c_active wa Asqd Wa wt Td Wt iter
  persistent init_done=false

  if nargin==12
    k0=_k0;c0=_c0;
    k_max=_k_max;k_active=_k_active;c_active=_c_active;
    wa=_wa;Asqd=_Asqd;Wa=_Wa;wt=_wt;Td=_Td;Wt=_Wt;
    iter=0;
    init_done=true;
    return;
  elseif nargin ~= 1
    print_usage("E=WISEJ_ONEM(kc) \n\
WISEJ_ONEM(kc,k0,c0,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)");
  endif
  if init_done==false
    error("init_done == false!");
  endif
  if length(kc) ~= (length(k_active)+length(c_active))
    error("length(kc) ~= (length(k_active)+length(c_active))");
  endif

  % Find the response
  k=k0;
  k(k_active)=kc(1:length(k_active));
  if any(abs(k)>k_max)
    E=100;
    return;
  endif
  c=c0;
  c(c_active)=kc(length(k_active)+c_active);

  % Find the amplitude response error
  Asq=schurOneMlatticeAsq(wa,k,ones(size(k)),ones(size(k)),c);
  EAsq = Wa.*((Asq-Asqd).^2);

  % Find the delay response error
  t=schurOneMlatticeT(wt,k,ones(size(k)),ones(size(k)),c);
  Et = Wt.*((t-Td).^2);

  % Trapezoidal integration of the weighted error
  intE = sum(diff(wa).*((EAsq(1:(length(EAsq)-1))+EAsq(2:end))/2)) + ...
         sum(diff(wt).*((Et(1:(length(Et)-1))+Et(2:end))/2));
 
  % Heuristics for the barrier function
  [n,d]=schurOneMlattice2tf(k,ones(size(k)),ones(size(k)),c);
  lambda = 0.01;
  if (length(d)) > 0
    M =30;
    T = 300;
    rho = 255/256;
    % Convert d to state variable form
    drho=d./(rho.^(0:(length(d)-1))');
    drho=drho(:)'/drho(1);
    ndrho=length(drho);
    A=[zeros(ndrho-2,1) eye(ndrho-2); -drho(ndrho:-1:2)];
    B=[zeros(ndrho-2,1);1];
    C=-drho(ndrho:-1:2);
    % Calculate barrier function
    f = zeros(M,1);
    CA_Tm = C*(A^(T-1));
    for m=1:M
      f(m) = CA_Tm*B;
      CA_Tm = CA_Tm*A;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intE) + (lambda*EJ);
  % Echo
  iter = iter+1;
endfunction

% Lowpass filter specification
norder=10
fap=0.15,Wap=1
fas=0.25,Was=1e6
ftp=0.25,tp=6,Wtp=0.2
k_max=0.99

% Amplitude constraints
n=100;
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap,1);Was*ones(n-nas,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Unconstrained minimisation
tol=1e-9;
maxiter=10000;
k0=0.1*ones(1,norder);
k_active=find(k0~=0);
c0=0.1*ones(1,norder+1);
c_active=1:length(c0);
kc0=[k0(k_active),c0(c_active)];
WISEJ_ONEM([],k0,c0,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[kc1,FVEC,INFO,OUTPUT] = fminunc(@WISEJ_ONEM,kc0,opt);
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
k1=k0;
k1(k_active)=kc1(k_active);
c1=c0;
c1(c_active)=kc1(length(k_active)+c_active);
[n1,d1]=schurOneMlattice2tf(k1,ones(size(k1)),ones(size(k1)),c1);

% Plot overall response
nplot=1000;
[H,wplot]=freqz(n1,d1,nplot);
T=delayz(n1,d1,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -60 5]);
ylabel("Amplitude(dB)");
grid("on");
subplot(212);
plot(wplot*0.5/pi,T);
axis([0 0.5 0 20]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print("tarczynski_schurOneMlattice_lowpass_test_response","-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
axis([0 max(fap,ftp) -4 4]);
ylabel("Amplitude(dB)");
grid("on");
subplot(212);
plot(wplot*0.5/pi,T);
axis([0 max(fap,ftp) tp-2 tp+2]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print("tarczynski_schurOneMlattice_lowpass_passband_test_response","-dpdflatex");
close

% Save the filter specification
fid=fopen("tarczynski_schurOneMlattice_lowpass_test_spec.m","wt");
fprintf(fid,"tol=%4.1g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"norder=%d %% Filter order\n",norder);
fprintf(fid,"k_max=%g %% Maximum absolute value of k\n",k_max);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"Wap=%g %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"tp=%g %% Pass band delay\n",tp);
fprintf(fid,"ftp=%g %% Pass band delay response edge\n",ftp);
fprintf(fid,"Wtp=%g %% Pass band delay response weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"Was=%g %% Stop band amplitude response weight\n",Was);
fclose(fid);

% Save the results
print_polynomial(k1,"k1");
print_polynomial(k1,"k1","tarczynski_schurOneMlattice_lowpass_test_k1_coef.m");
print_polynomial(c1,"c1");
print_polynomial(c1,"c1","tarczynski_schurOneMlattice_lowpass_test_c1_coef.m");

save tarczynski_schurOneMlattice_lowpass_test.mat ...
     tol n norder k_max fap Wap tp ftp Wtp fas Was k1 c1

% Done
toc;
diary off
movefile tarczynski_schurOneMlattice_lowpass_test.diary.tmp ...
         tarczynski_schurOneMlattice_lowpass_test.diary;
