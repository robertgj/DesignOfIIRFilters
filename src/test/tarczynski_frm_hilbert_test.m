% tarczynski_frm_hilbert_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen
%
% Design an FRM Hilbert filter from IIR allpass model in parallel with a delay
% and FIR masking filters using the method of Tarczynski et al. The 
% masking filters have odd lengths (ie: even order) and are symmetric
% (ie: linear phase). See "A class of FRM-based all-pass digital filters with
% applications in half-band filters and Hilbert transformers", L. Milić et al.

test_common;

pkg load optim;

delete("tarczynski_frm_hilbert_test.diary");
delete("tarczynski_frm_hilbert_test.diary.tmp");
diary tarczynski_frm_hilbert_test.diary.tmp

tic;

maxiter=5000
verbose=true;
strf="tarczynski_frm_hilbert_test";

function [q,r2M]=vec2frm_hilbert(ra,mr,na,Mmodel,Dmodel)
  % Model filter
  ra=ra(:);
  r2M=zeros((2*Mmodel*mr)+1,1);
  r2M(1:(2*Mmodel):end)=[1;ra(1:mr)];

  % FIR masking filters
  dmask=(na-1)/2;
  aa=ra((mr+1):(mr+dmask+1));
  aa=[aa;flipud(aa(1:dmask))];

  % Calculate the numerator polynomial from the halfband filter 
  au=zeros(size(aa));
  au(1:2:end)=aa(1:2:end);
  av=zeros(size(aa));
  av(2:2:end)=aa(2:2:end); 
  zdmask=[zeros(dmask,1);1;zeros(dmask,1)];
  zDM=zeros(Dmodel*Mmodel,1);
  q=[conv(flipud(r2M),(2*au)-zdmask);zDM] + [zDM;conv(r2M,2*av)];

  % Convert to Hilbert
  rm1=zeros((2*mr*Mmodel)+1,1);
  rm1(1:(4*Mmodel):end)=1;
  rm1(((2*Mmodel)+1):(4*Mmodel):end)=-1;
  r2M=r2M.*rm1;
  qm1=zeros((((2*mr)+Dmodel)*Mmodel)+(2*dmask)+1,1);
  qm1(1:4:end)=1;
  qm1(3:4:end)=-1;
  q=q.*qm1;

endfunction

function E=WISEJ_FRM_HILBERT(ra,_mr,_na,_Mmodel,_Dmodel, ...
                             _w,_Hd,_Wa,_Td,_Wt,_Pd,_Wp)

  persistent mr na Mmodel Dmodel w Hd Wa Td Wt Pd Wp
  persistent td
  persistent init_done=false

  if nargin==12
    mr=_mr; na=_na; Mmodel=_Mmodel; Dmodel=_Dmodel;
    w=_w; Hd=_Hd; Wa=_Wa; Td=_Td; Wt=_Wt; Pd=_Pd; Wp=_Wp;
    dmask=(na+1)/2;
    td=(Dmodel*Mmodel)+dmask;
    init_done=true;
  endif
  if isempty(ra)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Find the FRM filter polynomials
  [q,r2M]=vec2frm_hilbert(ra,mr,na,Mmodel,Dmodel);
 
  % Find the error response
  H=freqz(q,r2M,w);
  EH=abs(abs(H)-abs(Hd)).^2;
  EH=abs(abs(H)-abs(Hd)).^2;
  T=grpdelay(q,r2M,w);
  ET=abs(T-Td).^2;
  P=unwrap(arg(H))+(w*td);
  EP=abs(P-Pd).^2;
  E=(EH.*Wa)+(ET.*Wt)+(EP.*Wp);
  
  % Trapezoidal integration of the error
  intE = sum(diff(w).*((E(1:(length(E)-1))+E(2:end))/2));
 
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
  E = ((1-lambda)*intE) + (lambda*EJ);
endfunction

%
% Filter specification
%
tol=1e-6 % Tolerance on coefficient update vector
n=800 % Number of frequency points
mr=5 % R=2 allpass model filter order is mr*2 with mr coefficients
na=33 % FIR masking filter length
Mmodel=7 % Decimation
Dmodel=9 % Desired model filter passband delay
dmask=(na-1)/2 % Nominal masking filter delay (assumes odd length)
td=(Mmodel*Dmodel)+dmask % Nominal FRM filter delay
fpass=0.01 % Lower pass band edge
fstop=0.49 % Upper pass  band edge
Wa=1; % Amplitude weight
Wt=0.00075; % Delay weight
Wp=0.00075; % Phase weight

% Model and masking filter edge frequencies for the half-band filter
fmpass=0.24
fmstop=0.26
if mod(fmpass*Mmodel,1)>0.5
  m=ceil(fmstop*Mmodel);
  fadp=m-(fmstop*Mmodel);
  fads=m-(fmpass*Mmodel);
  faap=((m-1)+fads)/Mmodel;
  faas=(m-fadp)/Mmodel;
else
  m=floor(fmpass*Mmodel);
  fadp=(fmpass*Mmodel)-m;
  fads=(fmstop*Mmodel)-m;
  faap=(m+fadp)/Mmodel;
  faas=((m+1)-fads)/Mmodel;
endif

%
% Initial filter vector
%
r0=[1;zeros(mr,1)];
aa0=remez(na-1,2*[0 faap faas 0.5],[1 1 0 0]);
ra0=[r0(2:end);aa0(1:(dmask+1))];

%
% Plot the initial filter response
%
[q0,r2M0]=vec2frm_hilbert(ra0,mr,na,Mmodel,Dmodel);
nplot=400;
[Hw_init,wplot]=freqz(q0,r2M0,nplot);
[Tw_init,wplot]=grpdelay(q0,r2M0,nplot);
% Plot initial response
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(Hw_init)));
ylabel("Amplitude(dB)");
axis([0 0.5 -0.6 0.6]);
grid("on");
strt=sprintf("Initial FRM Hilbert filter:mr=%d,na=%d,Mmodel=%d,Dmodel=%d,td=%d",
             mr,na,Mmodel,Dmodel,td);
title(strt);
subplot(312);
plot(wplot*0.5/pi,(unwrap(arg(Hw_init))+(wplot*td))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 -0.6 -0.4]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,Tw_init);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 76 82]);
grid("on");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

%
% Unconstrained minimisation of the filter response
%

% Frequency vectors
w=pi*(fpass+((0:(n-1))'*(fstop-fpass)/n));
Hd=ones(size(w));
Td=((Dmodel*Mmodel)+dmask)*ones(size(w));
Pd=-pi*ones(size(w))/2;

WISEJ_FRM_HILBERT([],mr,na,Mmodel,Dmodel,w,Hd,Wa,Td,Wt,Pd,Wp);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ra1,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_FRM_HILBERT,ra0,opt);
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
[q1,r2M1]=vec2frm_hilbert(ra1,mr,na,Mmodel,Dmodel);

%
% Calculate the filter response
%
nplot=1024;
[Hw_hilbert,wplot]=freqz(q1,r2M1,nplot);
Tw_hilbert=grpdelay(q1,r2M1,nplot);

% Plot overall response
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(Hw_hilbert)));
ylabel("Amplitude(dB)");
axis([0 0.5 -0.6 0.6]);
grid("on");
strt=sprintf("FRM Hilbert filter:mr=%d,na=%d,Mmodel=%d,Dmodel=%d,td=%d",
             mr,na,Mmodel,Dmodel,td);
title(strt);
subplot(312);
plot(wplot*0.5/pi,(unwrap(arg(Hw_hilbert))+(wplot*td))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 -0.6 -0.4]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,Tw_hilbert);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 76 82]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Alternative calculation of the response
%
r1=[1;ra1(1:mr)]; 
u1=ra1((mr+1):2:(mr+dmask+1));
v1=ra1((mr+2):2:(mr+dmask));

% Model filter response
r2M1a=zeros((2*Mmodel*mr)+1,1);
r2M1a(1:(2*Mmodel):end)=r1;
r2Mm1=zeros((2*mr*Mmodel)+1,1);
r2Mm1(1:(4*Mmodel):end)=1;
r2Mm1(((2*Mmodel)+1):(4*Mmodel):end)=-1;
Hr2M_alt=freqz(flipud(r2M1a).*r2Mm1,r2M1a.*r2Mm1,wplot);
% Masking filter
um1=ones(size(u1));
um1(2:2:end)=-1;
au1=zeros((2*dmask)+1,1);
au1(1:2:(dmask+1))=u1.*um1;
au1((dmask+2):end)=flipud(au1(1:dmask));
zdmask=[zeros(dmask,1);1;zeros(dmask,1)];
Hau_alt=freqz((2*au1)-zdmask,1,wplot);
% Complementary masking filter
vm1=ones(size(v1));
vm1(2:2:end)=-1;
av1=zeros((2*dmask)+1,1);
av1(2:2:dmask)=v1.*vm1;
av1((dmask+2):2:end)=flipud(v1).*vm1;
zDM=zeros(Dmodel*Mmodel,1);
Hav_alt=freqz([zDM;2*av1],1,wplot);
% Overall response
Hw_hilbert_alt=(Hr2M_alt.*Hau_alt)+Hav_alt;
% Check
if max(abs(Hw_hilbert-Hw_hilbert_alt)) > 200*eps
  error("max(abs(Hw_hilbert-Hw_hilbert_alt)) (%g*eps) > 200*eps",
        max(abs(Hw_hilbert-Hw_hilbert_alt))/eps)
endif

% Save the results
print_polynomial(q1,"q1");
print_polynomial(q1,"q1",strcat(strf,"_q1_coef.m"),"%16.10f");
print_polynomial(r2M1,"r2M1");
print_polynomial(r2M1,"r2M1",strcat(strf,"_r2M1_coef.m"),"%16.10f");
print_polynomial(r1,"r1");
print_polynomial(r1,"r1",strcat(strf,"_r1_coef.m"),"%16.10f");
print_polynomial(u1,"u1");
print_polynomial(u1,"u1",strcat(strf,"_u1_coef.m"),"%16.10f");
print_polynomial(v1,"v1");
print_polynomial(v1,"v1",strcat(strf,"_v1_coef.m"),"%16.10f");

save tarczynski_frm_hilbert_test.mat r0 aa0 q0 r2M0 q1 r2M1 r1 u1 v1 ...
     Mmodel Dmodel dmask mr na fpass fstop n tol nplot wplot

% Done
toc;
diary off
movefile tarczynski_frm_hilbert_test.diary.tmp tarczynski_frm_hilbert_test.diary;
