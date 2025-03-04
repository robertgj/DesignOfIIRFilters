% bertsekas_correction_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="bertsekas_correction_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Deczky3 lowpass filter specification
fap=0.15,Wap=1
fas=0.3,Was=100
ftp=0.25,td=10,Wtp=2 

% Initial coefficients
U=0,V=0,Q=6,M=10,R=1
z=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K=0.0096312406;
x0=[K,abs(z),angle(z),abs(p),angle(p)]';

% Frequency vectors
n=400;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=ceil((n*fap)/0.5)+1;
wa=w(1:nap);
Ad=ones(nap,1);
Wa=Wap*ones(nap,1);

% Stop-band amplitude constraints
nas=floor((n*fas)/0.5)+1;
ws=w(nas:n);
Sd=zeros(length(ws),1);
Ws=Was*ones(length(ws),1);

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=w(1:ntp);
Td=td*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Find errors
dbstop if error;
         
[E,gradE,hessE]=iirE(x0,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,[],[],[]);

[C,L]=bertsekas_correction((hessE+hessE')/2);


% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
