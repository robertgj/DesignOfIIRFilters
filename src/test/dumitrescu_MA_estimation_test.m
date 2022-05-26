% dumitrescu_MA_estimation_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% Implement MA estimation with the method of the dual of the SDP trace
% parameterisation by Dumitrescu at al. See Equation 47, "On the
% Parameterization of Positive Real Sequences and MA Parameter Estimation",
% B. Dumitrescu, I. Tabus and P. Stoica, IEEE Transactions on Signal Processing,
% Vol. 49, No. 11, pp. 2630–2639, November 2001.

test_common;

delete("dumitrescu_MA_estimation_test.diary");
delete("dumitrescu_MA_estimation_test.diary.tmp");
diary dumitrescu_MA_estimation_test.diary.tmp

strf="dumitrescu_MA_estimation_test";
tol=1e-12;
nplot=1024;
w=pi*(0:(nplot-1))'/nplot;

%
% Make a filter according to Section VII of the reference
%
n=20;                % Actual filter order
ne=20;               % Filter order for estimation
N=2000;              % Filtered sequence length
ng=floor(sqrt(N));   % Estimate of variance-covariance matrix is (n+ng)x(n+ng)
Rz=0.98;             % Zero radius
wk=(1:(n/2))*pi/((n/2)+1);
h=real(x2tf([1,Rz*exp(-j*wk),Rz*exp(j*wk)],n,0,0,0,1));
h=h(:);
H=freqz(h,1,w);
% Sanity check on r
hh=h*h';
r=zeros(n+1,1);
for k=0:n
  r(k+1)=sum(diag(diag(ones(n+1-k,1),k)*hh,k));
endfor
R=directFIRsymmetricA(w,flipud(r));
if min(R)<tol
  printf("min(R)(%g)<tol(%g)\n",min(R),tol);
endif

%
% Filter a noise sequence
%
rand("seed",0xdeadbeef);
u=rand(N,1)-0.5;
u=u/std(u);
y=filter(h,1,u);

%
% Estimate covariance of y (Section III)
%
rhat=zeros(N,1);
for k=1:N,
  rhat(k)=y(k:N)'*y(1:(N-k+1))/N;
endfor

%
% Estimate variance-covariances of y, (use limits l= +/-(ne+ng) instead of +/-N)
%
What=zeros(ne+ng+1,ne+ng+1);
for k=0:(ne+ng),
  for p=k:(ne+ng),
    for l=-(ne+ng):(ne+ng),
      l1=1+abs(l);
      l2=1+abs(l+k-p);
      l3=1+abs(l-p);
      l4=1+abs(l+k);
      What(k+1,p+1)=What(k+1,p+1)+ ...
                    (((rhat(l1)*rhat(l2))+(rhat(l3)*rhat(l4)))*(N-abs(l)));
    endfor
  endfor
endfor
What=(What+(triu(What,1)'))/(N*N);
if ~isdefinite(What,tol)
  error("~isdefinite(What,%g)",tol);
endif

%
% Partition What (Equations 14 and 15)
%
ghat=rhat((1+ne+1):(1+ne+ng));
rhat=rhat(1:(ne+1));
What11=What(1:(ne+1),1:(ne+1));
What12=What(1:(ne+1),(1+ne+1):end);
What22=What((1+ne+1):end,(1+ne+1):end);
% Calculate rtilde
rtilde=rhat-(What12*inv(What22)*ghat);
% Sanity check on rtilde
Rtilde=directFIRsymmetricA(w,flipud(rtilde));
if min(Rtilde)<tol
  printf("min(Rtilde)(%g)<tol(%g)\n",min(Rtilde),tol);
endif

% Calculate Gamma
Gamma=What11-(What12*inv(What22)*(What12'));
% Sanity check on Gamma
if ~isdefinite(Gamma,tol)
  error("~isdefinite(Gamma,%g)",tol);
endif
  
%
% Set up the SeDuMi problem (Equation 47) :
% b is mx1, y is mx1, A is mx(n1-1), c is (n1-1)x1, K.q=n1
%
m=ne+2;
n1=ne+2;
% Minimise eta=b'*y
b=[1;zeros(ne+1,1)];
bt=-b;
% Quadratic constraints (||G*mustar+inv(G)'*rtilde||<eta:
G=chol(Gamma);
At=-[b,[zeros(1,ne+1);G]];
ct=[0;inv(G)'*rtilde];
K.q=n1;
% SDP constraints
F0=zeros(ne+1,ne+1);
F=zeros((ne+1)*(ne+1),ne+2);
F(:,1)=vec(zeros(ne+1)); % eta
F(:,2)=vec(eye(ne+1));   % mustar(1)
for k=3:(ne+2),          % mustar(2:(ne+1))
  F(:,k)=vec(diag(0.5*ones(n-k+2,1),k-1)+diag(0.5*ones(n-k+2,1),-k+1));
endfor
At=[At;F];
ct=[ct;vec(F0)];
K.s=ne+1;
%
pars.eps=tol;
[x,y,info] = sedumi(At,bt,ct,K,pars);
printf("info.numerr = %d\n",info.numerr);
printf("info.dinf = %d\n",info.dinf);
printf("info.pinf = %d\n",info.pinf);
if info.numerr==2
  error("info.numerr == 2");
endif
% Check x and y
if abs((ct'*x)-(y'*bt))>(100*tol)
  error("abs((c'*x)-(y'*b))(%g)>(100*tol)(%g)",abs((ct'*x)-(y'*bt)),100*tol);
endif

% Find the filter impulse response from the spectral factorisation of rstar
% Note that the sign of the objective is changed between Equations 23 and 24
% "to get a minimization problem instead of a maximization one"
mustar=-y(2:end);
rstar=(Gamma*mustar)+rtilde;
% Sanity check on rstar
Rstar=directFIRsymmetricA(w,flipud(rstar));
if min(Rstar)<tol
  printf("min(Rstar)(%g)<tol(%g)\n",min(Rstar),tol);
endif

% Calculate minimum phase filter, hstar
rstar_roots=qroots([rstar(end:-1:2);rstar]);
if any((abs(abs(rstar_roots)-1))<tol)
  error("any((abs(abs(rstar_roots)-1))<tol)");
endif
hstar=minphase(rstar);
hstar=hstar(:)/hstar(1);

% Compare response error for hstar
Hstar=freqz(hstar,1,w);
printf("norm(Hstar-H)=%g\n",norm(Hstar-H));
printf("max(abs(Hstar-H))=%g\n",max(abs(Hstar-H)));

% Plot results
plot(w*0.5/pi,20*log10(abs(H)), "-", ...
     w*0.5/pi,20*log10(abs(Hstar)),"-.")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -10 25]);
legend("h","h*");
legend("boxoff");
legend("location","north");
strt=sprintf("MA estimator amplitude response : n=%d, N=%d, Rz=%4.2f",n,N,Rz);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close;
zplane([qroots(h),qroots(hstar)]);
strt=sprintf("MA estimator zeros : n=%d, N=%d, Rz=%4.2f", n,N,Rz);
title(strt);
print(strcat(strf,"_zeros"),"-dpdflatex");
close;

% Save results
print_polynomial(rstar,"rstar");
print_polynomial(rstar,"rstar",strcat(strf,"_rstar_coef.m"));
print_polynomial(hstar,"hstar");
print_polynomial(hstar,"hstar",strcat(strf,"_hstar_coef.m"));

% Print specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"n=%d %% Filter order\n",n);
fprintf(fid,"ne=%d %% Filter order for estimation\n",ne);
fprintf(fid,"N=%d %% Number of filtered noise samples\n",N);
fprintf(fid,"Rz=%f %% Radius of filter zeros\n",Rz);
fclose(fid);

save dumitrescu_MA_estimation_test.mat ...
     n ne N ng Rz h r Gamma R rtilde rstar hstar mustar

% Done
diary off
movefile dumitrescu_MA_estimation_test.diary.tmp dumitrescu_MA_estimation_test.diary;
