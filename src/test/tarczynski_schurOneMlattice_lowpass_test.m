% tarczynski_schurOneMlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Design a Schur one-multiplier lattice lowpass filter using the method
% of Tarczynski et al. to optimise the lattice coefficients directly.

test_common;

pkg load optim;

strf="tarczynski_schurOneMlattice_lowpass_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

function E=WISEJ_OneM(kc,_ki,_ci,_k_max,_k_active,_c_active, ...
                      _wa,_Asqd,_Wa,_wt,_Td,_Wt)

% E=WISEJ_OneM(kc,ki,ci,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)
% Objective function for minimising the response error of a tapped Schur 
% lattice filter using the method of Tarczynski et al. See "A WISE
% Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432
% The argument kc is the concatenation of the allpass filter reflection
% coefficients tap coefficients to be optimised.
%
% First initialise the common parameters of the filter structure with:
%  WISEJ_OneM([],ki,ci,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)
% The common filter parameters are:
%  ki - initial all-pass reflection coefficients
%  ci - initial tap coefficients
%  k_max - upper limit on reflection coefficient magnitude
%  k_active - indexes of reflection coefficients to be optimised
%  c_active - indexes of tap coefficients to be optimised
%  wa - angular frequencies of the desired squared-amplitude response
%  Asqd - desired filter squared-amplitude response
%  Wa - filter squared-amplitude response weighting factor
%  wt - angular frequencies of the desired group-delay response
%  Td - desired filter group-delay response
%  Wt - filter group-delay response weighting factor

  persistent ki ci k_max k_active c_active wa Asqd Wa wt Td Wt iter
  persistent init_done=false

  if nargin==12
    ki=_ki;ci=_ci;
    k_max=_k_max;k_active=_k_active;c_active=_c_active;
    wa=_wa;Asqd=_Asqd;Wa=_Wa;wt=_wt;Td=_Td;Wt=_Wt;
    iter=0;
    init_done=true;
    return;
  elseif nargin ~= 1
    print_usage(["E=WISEJ_OneM(kc) \n", ...
 "WISEJ_OneM(kc,ki,ci,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt)"]);
  endif
  if init_done==false
    error("init_done == false!");
  endif
  if length(kc) ~= (length(ki)+length(ci))
    error("length(kc)(%d) ~= (length(ki)(%d)+length(ci)(%d))", ...
          length(kc),length(ki),length(ci));
  endif

  % Find the response
  k=ki;
  k(k_active)=kc(k_active);
  if any(abs(k)>k_max)
    E=100;
    return;
  endif
  c=ci;
  c(c_active)=kc(length(ki)+c_active);

  % Find the amplitude response error
  Asq=schurOneMlatticeAsq(wa,k,ones(size(k)),ones(size(k)),c);
  EAsq = Wa.*((Asq-Asqd).^2);

  % Trapezoidal integration of the weighted error
  intE = sum(diff(wa).*((EAsq(1:(length(EAsq)-1))+EAsq(2:end))/2));
 
  % Find the delay response error
  if length(wt)>1
    t=schurOneMlatticeT(wt,k,ones(size(k)),ones(size(k)),c);
    Et = Wt.*((t-Td).^2);
    intE = intE + sum(diff(wt).*((Et(1:(length(Et)-1))+Et(2:end))/2));
  endif
    
  % Heuristics for the barrier function
  [N,D]=schurOneMlattice2tf(k,ones(size(k)),ones(size(k)),c);
  lambda = 0.01;
  if (length(D)) > 0
    M =30;
    t = 300;
    rho = 255/256;
    % Convert D to state variable form
    Drho=D./(rho.^(0:(length(D)-1))');
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    A=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    B=[zeros(nDrho-2,1);1];
    C=-Drho(nDrho:-1:2);
    % Calculate barrier function
    f = zeros(M,1);
    CA_t = C*(A^(t-1));
    for m=1:M
      f(m) = CA_t*B;
      CA_t = CA_t*A;
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

tic;

% Lowpass filter specification
norder=10,R=1,k_max=127/128
fap=0.15,Wap=1
fas=0.25,Was=1e6
ftp=0.25,tp=6,Wtp=0.2

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
ki=0.1*kron(ones(1,norder/R),[zeros(1,R-1),1]);
k_active=find(ki~=0);
ci=0.1*ones(1,norder+1);
c_active=1:length(ci);
kci=[ki,ci];
WISEJ_OneM([],ki,ci,k_max,k_active,c_active,wa,Asqd,Wa,wt,Td,Wt);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[kc0,FVEC,INFO,OUTPUT] = fminunc(@WISEJ_OneM,kci,opt);
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
k0=ki;
k0(k_active)=kc0(k_active);
c0=ci;
c0(c_active)=kc0(length(k_active)+c_active);
[N0,D0]=schurOneMlattice2tf(k0,ones(size(k0)),ones(size(k0)),c0);

% Plot overall response
nplot=1000;
[H0,wplot]=freqz(N0,D0,nplot);
T0=delayz(N0,D0,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
axis([0 0.5 -60 5]);
ylabel("Amplitude(dB)");
grid("on");
subplot(212);
plot(wplot*0.5/pi,T0);
axis([0 0.5 0 20]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
axis([0 max(fap,ftp) -4 4]);
ylabel("Amplitude(dB)");
grid("on");
subplot(212);
plot(wplot*0.5/pi,T0);
axis([0 max(fap,ftp) tp-2 tp+2]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
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
print_polynomial(k0,"k0");
print_polynomial(k0,"k0",strcat(strf,"_k0_coef.m"));
print_polynomial(c0,"c0");
print_polynomial(c0,"c0",strcat(strf,"_c0_coef.m"));
print_polynomial(N0,"N0");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0,"D0");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"));

eval(sprintf(["save %s.mat ", ...
              "tol n norder k_max fap Wap tp ftp Wtp fas Was k0 c0 N0 D0"], ...
             strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
