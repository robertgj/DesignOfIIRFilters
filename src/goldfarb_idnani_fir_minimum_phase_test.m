% goldfarb_idnani_fir_minimum_phase_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("goldfarb_idnani_fir_minimum_phase_test.diary");
unlink("goldfarb_idnani_fir_minimum_phase_test.diary.tmp");
diary goldfarb_idnani_fir_minimum_phase_test.diary.tmp

format short e

maxiter=2500
tol=1e-3
verbose=true;

% Define objective function
function [E,gradE,hessE]=iir_gi_fx(x,_U,_V,_M,_Q,_R,_wa,_Ad,_Wa)
         
  persistent U V M Q R N wa Ad Wa
  persistent init_complete=false

  % Initialise persistent (constant) values
  if nargin == 1
    if init_complete == false
      error("nargin==1 && init_complete==false");
    endif
  elseif nargin == 9
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    N=1+U+V+M+Q;
    wa=_wa;Ad=_Ad;Wa=_Wa;
    init_complete=true;
  else
    print_usage("[E,gradE,hessE] = iir_gi_fx(x, ... );");
  endif
  if nargout == 0
    return;
  endif

  % Calculate error, error gradient and error Hessian 
  if nargout == 3
    [E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,[],[],[],[],[],[],[],[],[]);
    hessE=diag(diag(hessE));
    isdefinite(hessE)
  elseif nargout == 2
    [E,gradE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,[],[],[],[],[],[],[],[],[]);
    hessE=eye(N,N);
  elseif nargout == 1
    E=iirE(x,U,V,M,Q,R,wa,Ad,Wa,[],[],[],[],[],[],[],[],[]);
    gradE=zeros(N,1);
    hessE=eye(N,N);
  endif
    
endfunction

% Define constraint gradient function
function [G,gradG]=iir_gi_gx(x,_xl,_xu,_U,_V,_M,_Q,_R,_wa,_Adu,_Adl)
         
  persistent xl xu N U V M Q R wa Adu Adl
  persistent init_complete=false

  % Initialise persistent (constant) values
  if nargin == 1
    if init_complete == false
      error("nargin==1 && init_complete==false");
    endif
  elseif nargin == 11
    xl=_xl;xu=_xu;
    wa=_wa;Adu=_Adu;Adl=_Adl;
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    N=1+U+V+M+Q;
    init_complete=true;
  else
    print_usage("[G,gradG] = iir_gi_gx(x, ... );");
  endif
  if nargout == 0
    return;
  endif
  [A,gradA]=iirA(wa,x,U,V,M,Q,R);
  G=[ A-Adl; Adu-A; x-xl; xu-x; ];
  gradG=[ gradA; -gradA; eye(N,N); -eye(N,N) ]';
endfunction

% Bandpass filter specification (frequencies are normalised to sample rate)
fapl=0.1,fapu=0.2,dBap=3,Wap=1
fasl=0.05,fasu=0.25,dBas=20,Wasl=1,Wasu=1
N=41
R=1

% Initial filter
brz=remez(N-1,2*[0 fasl fapl fapu fasu 0.5],[0 0 1 1 0 0], ...
          [Wasl Wap Wasu],'bandpass');
[x0,U,V,M,Q]=tf2x(brz,1);
if N ~= 1+U+V+M+Q
  error("N ~= 1+U+V+M+Q");
endif

% Use minimum phase coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q,31/32,1);
dmax=0.05;

% Frequency points
n=100;

% Desired amplitude 
wa=(0:(n-1))'*pi/n;
napl=floor(n*fapl/0.5);
napu=ceil(n*fapu/0.5);
nasl=ceil(n*fasl/0.5);
nasu=floor(n*fasu/0.5);
Ad=[zeros(napl,1);
    ones(napu-napl,1);
    zeros(n-napu,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1);
     ones(nasu-nasl,1);
     (10^(-dBas/20))*ones(n-nasu,1)];
Adl=[zeros(napl,1);
     (10^(-dBap/20))*ones(napu-napl,1);
     zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1);
    zeros(napl-nasl,1);
    Wap*ones(napu-napl,1);
    zeros(nasu-napu,1);
    Wasu*ones(n-nasu,1)];

% Initialise objective and constraint functions
iir_gi_fx([],U,V,M,Q,R,wa,Ad,Wa);
iir_gi_gx([],xl,xu,U,V,M,Q,R,wa(1:15:end),Adu(1:15:end),Adl(1:15:end));

[x,W,invW,iter,feasible] = ...
  goldfarb_idnani(x0,@iir_gi_fx,@iir_gi_gx,tol,maxiter,verbose);

% Done 
diary off
movefile goldfarb_idnani_fir_minimum_phase_test.diary.tmp goldfarb_idnani_fir_minimum_phase_test.diary;
