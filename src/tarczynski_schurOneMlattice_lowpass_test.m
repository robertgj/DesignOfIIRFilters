% tarczynski_schurOneMlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Design a Schur one-multiplier lattice lowpass filter using the method
% of Tarczynski et al. to optimise the lattice coefficients directly.

test_common;

delete("tarczynski_schurOneMlattice_lowpass_test.diary");
delete("tarczynski_schurOneMlattice_lowpass_test.diary.tmp");
diary tarczynski_schurOneMlattice_lowpass_test.diary.tmp

tic;

verbose=true

function E=WISEJ_ONEM(kc,_k0,_epsilon0,_p0,_c0,_k_active,_c_active, ...
                      _wa,_Asqd,_Wa,_wt,_Td,_Wt)

  persistent k0 epsilon0 p0 c0 k_active c_active wa Asqd Wa wt Td Wt iter
  persistent init_done=false

  if nargin==13
    k0=_k0;epsilon0=_epsilon0;p0=_p0;c0=_c0;
    k_active=_k_active;c_active=_c_active;
    wa=_wa;Asqd=_Asqd;Wa=_Wa;wt=_wt;Td=_Td;Wt=_Wt;
    iter=0;
    init_done=true;
    return;
  elseif nargin ~= 1
    print_usage("E=WISEJ_ONEM(kc) \n\
WISEJ_ONEM(kc,k0,epsilon0,p0,c0,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)");
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
  c=c0;
  c(c_active)=kc(length(k_active)+c_active);
  
  % Find the amplitude response error
  Asq=schurOneMlatticeAsq(wa,k,epsilon0,ones(size(p0)),c);
  EAsq = Wa.*((Asq-Asqd).^2);

  % Find the delay response error
  t=schurOneMlatticeT(wt,k,epsilon0,ones(size(p0)),c);
  Et = Wt.*((t-Td).^2);

  % Trapezoidal integration of the weighted error
  intE = sum(diff(wa).*((EAsq(1:(length(EAsq)-1))+EAsq(2:end))/2)) + ...
         sum(diff(wt).*((Et(1:(length(Et)-1))+Et(2:end))/2));
 
  % Heuristics for the barrier function
  [n,d]=schurOneMlattice2tf(k,epsilon0,ones(size(p0)),c);
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

% Deczky3 lowpass filter specification
norder=10
fap=0.15,Wap=1
fas=0.25,Was=1e6
ftp=0.25,tp=10,Wtp=0.05

% Initial filter calculated by deczky3_socp_test.m
n0 = [   0.0034549892,  -0.0126111635,   0.0128424226,  -0.0085225483, ... 
         0.0217938968,  -0.0126330860,  -0.0347097162,  -0.0044625617, ... 
         0.1013086677,   0.1318220717,   0.1164537735 ]';
d0 = [   1.0000000000,  -1.6221027249,   1.7194613866,  -1.2096422600, ... 
         0.5911699380,  -0.1945010363,   0.0339957995,   0, ...
         0,              0,              0 ]';
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);

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
maxiter=1000;
k0=k0(:)';
k_active=find(k0~=0);
c0=c0(:)';
c_active=1:length(c0);
kc0=[k0(k_active),c0(c_active)];
WISEJ_ONEM([],k0,epsilon0,p0,c0,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt);
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
k1
c1=c0;
c1(c_active)=kc1(length(k_active)+c_active);
c1
[n1,d1]=schurOneMlattice2tf(k1,epsilon0,ones(size(p0)),c1);

% Plot overall response
nplot=1000;
[H,wplot]=freqz(n1,d1,nplot);
T=grpdelay(n1,d1,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -60 5]);
ylabel("Amplitude(dB)");
grid("on");
subplot(212);
plot(wplot*0.5/pi,T);
axis([0 0.5 0 20]);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print("tarczynski_schurOneMlattice_lowpass_response","-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
axis([0 fap -2 2]);
ylabel("Amplitude(dB)");
grid("on");
subplot(212);
plot(wplot*0.5/pi,T);
axis([0 fap 5 15]);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print("tarczynski_schurOneMlattice_lowpass_passband_response","-dpdflatex");
close

% Save the results
fid=fopen("tarczynski_schurOneMlattice_lowpass_test.spec","wt");
fprintf(fid,"tol=%4.1g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fclose(fid);
print_polynomial(n1,"n1");
print_polynomial(n1,"n1","tarczynski_schurOneMlattice_lowpass_test_n1_coef.m");
print_polynomial(d1,"d1");
print_polynomial(d1,"d1","tarczynski_schurOneMlattice_lowpass_test_d1_coef.m");

save tarczynski_schurOneMlattice_lowpass_test.mat n0 d0 k0 c0 k1 c1 n1 d1

% Done
toc;
diary off
movefile tarczynski_schurOneMlattice_lowpass_test.diary.tmp ...
         tarczynski_schurOneMlattice_lowpass_test.diary;
