% yalmip_sdp_fir_lowpass_test.m
%
% Test FIR design with a quadratic objective function
% See: Section 8 of "Introduction to Semidefinite Programming",
% Robert M. Freund, MIT6_251JF09_SDP.pdf
%
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_sdp_fir_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

Options=sdpsettings("solver","sedumi", ...
                    "dualize",true, ...
                    "saveyalmipmodel",true, ...
                    "savesolverinput",true, ...
                    "savesolveroutput",true);

% Low-pass filter specification
N=30;d=10;fap=0.1;Wap=1;Wat=0.0001;fas=0.2;Was=1;

% Common constants
tol=1e-6;
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
hz=zeros(1,N+1);
hz(d+1)=1;
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
Phi=[-1,0;0,1];
C_d=zeros(1,N);
C_d(N-d+1)=1;
c_p=2*cos(2*pi*fap);
c_s=2*cos(2*pi*fas);
e_c=e^(j*pi*(fap+fas));
c_h=2*cos(pi*(fas-fap));

%
% Use YALMIP to solve for a quadratic constraint on the amplitude response
%
printf("\nUsing YALMIP to solve for a quadratic constraint on the amplitude\n");
[~,~,G,g]=directFIRnonsymmetricEsqPW ...
            (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[Wap,Wat,Was]);
if ~isdefinite(G)
  error("~isdefinite(G)");
endif
% Call YALMIP
x=sdpvar(1,N+1);
theta=sdpvar(1,1);
W=sdpvar(N+1,N+1,"symmetric","real");
for k=1:4,
  switch(k)
    case 1
      Objective=x*G*x'+2*g*x'+2*fap;
      Constraints=[];
    case 2
      Constraints=[(x*G*x'+2*g*x'+2*fap-theta)<=0,theta>=0];
      Objective=theta;
    case 3
      R=chol(G);
      xR=[[eye(N+1),(x*(R'))'];[x*(R'),(-(2*fap)-(x*(2*g'))+theta)]];
      Constraints=[xR>=0,theta>=0];
      Objective=theta;
    case 4
      xW=[[1,x];[x',W]];
      gG=[[(2*fap)-theta,g];[g',G]];
      Constraints=[-trace(gG*xW)>=0,xW>=0,theta>=0];
      Objective=theta;
    otherwise
      error("Invalid switch value!");
  endswitch
  sol=optimize(Constraints,Objective,sdpsettings("solver","sedumi"));
  if sol.problem
    error("YALMIP failed : %s",sol.info);
  endif
  eval(sprintf("h%d=value(x);",k));
endfor
if max(abs((h1-h2))) > tol
  error("max(abs((h1-h2))) > tol");
endif
if max(abs((h1-h3))) > tol
  error("max(abs((h1-h3))) > tol");
endif
if max(abs((h1-h4))) > tol
  error("max(abs((h1-h4))) > tol");
endif

% Plot response
[H,w]=freqz(h1,1,nplot);
[T,w]=delayz(h1,1,nplot);
subplot(211);
plot(w*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf(["KYP quadratic non-symmetric FIR filter : ", ...
 "N=%d,d=%d,fap=%g,Wap=%g,Wat=%g,fas=%g,Was=%g"],N,d,fap,Wap,Wat,fas,Was);
title(strt);
zticks([]);
subplot(212);
plot(w(1:nap)*0.5/pi,T(1:nap));
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 d-0.4 d+0.4]);
grid("on");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save 
print_polynomial(h1,"h1","%13.10f");
print_polynomial(h1,"h1",strcat(strf,"_h1_coef.m"),"%13.10f");
print_polynomial(h2,"h2","%13.10f");
print_polynomial(h2,"h2",strcat(strf,"_h2_coef.m"),"%13.10f");
print_polynomial(h3,"h3","%13.10f");
print_polynomial(h3,"h3",strcat(strf,"_h3_coef.m"),"%13.10f");
print_polynomial(h4,"h4","%13.10f");
print_polynomial(h4,"h4",strcat(strf,"_h4_coef.m"),"%13.10f");

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
