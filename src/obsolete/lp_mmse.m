function [x,E,lm,sqp_iter,func_iter,feasible]=...
  lp_mmse(x0,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was, ...
          hessianInit,tol,maxiter,verbose)
%% [x,E,lm,iter,liter,feasible]=...
%% lp_mmse(x0,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was,hessianInit, ...
%%         tol,maxiter,verbose)
%% Inputs:
%%   x0 - initial coefficient vector in the form:
%%         [k; zR(1:U); pR(1:V); ...
%%             abs(z(1:M)); angle(z(1:M)); ...
%%             abs(p(1:Q)); angle(p(1:Q))];
%%         where k is the gain coefficient, zR and pR represent real
%%         zeros  and poles and z and p represent conjugate zero and
%%         pole pairs. 
%%   U - number of real zeros
%%   V - number of real poles
%%   M - number of conjugate zero pairs
%%   Q - number of conjugate pole pairs
%%   R - decimation factor, pole pairs are for z^R
%%   fap - amplitude pass band edge frequency (sample rate is 1)
%%   Wap - amplitude pass band weight (a single value, eg: 10)
%%   ftp - group delay pass band edge frequency
%%   Wtp - group delay pass band weight
%%   fas - amplitude stop band edge frequency
%%   Was - amplitude stop band weight
%%   hessianInit - type of initialisation of the Hessian 
%%                 ("exact", "diagonal" or "eye")
%%   tol - tolerance
%%   maxiter - maximum number of SQP iterations
%%   verbose - print out from sqp_bfgs()
%%   
%% Outputs:
%%   x - filter design 
%%   E - error value at x
%%   lm - Lagrange multipliers at x
%%   sqp_iter - number of SQP iterations
%%   func_iter - number of calls to the error function
%%   feasible - x satisfies the constraints
%%
  global lp_fiter lp_lm lp_N ...
      lp_U lp_V lp_M lp_Q lp_R lp_Apass lp_fap lp_Wap lp_Lap ...
      lp_Tpass lp_ftp lp_Wtp lp_Ltp lp_fas lp_Was lp_Las lp_tol

  %% Initialisation
  x=x0(:);
  E=0;
  lm=[];
  sqp_iter=0;
  func_iter=0;
  feasible=false;
  lp_fiter=0;
  lp_tol=tol;
  lp_U=U; lp_V=V; lp_M=M; lp_Q=Q; lp_R=R;
  lp_fap=fap; lp_Wap=Wap;
  lp_ftp=ftp; lp_Wtp=Wtp; lp_tp=tp;
  lp_fas=fas; lp_Was=Was;
  lp_N=1+lp_U+lp_V+lp_M+lp_Q;
  lp_Lap=lp_Ltp=lp_Las=512;
  lp_Apass=ones(lp_Lap,1);
  lp_Tpass=lp_tp*ones(lp_Ltp,1);

  %% Upper and lower constraints on x
  [xlb, xub]=xConstraints(U,V,M,Q);

  %% Initialise Hessian approximation
  if strcmpi(hessianInit,"exact")
    [fx,gxf,hxxf]=lp_fx(x);
    [W,invW]=updateWchol(hxxf,0.1);
  elseif strcmpi(hessianInit,"diagonal")
    [fx,gxf,hxxf]=lp_fx(x);
    W=diag(diag(hxxf));
    invW=inv(W);
  elseif strcmpi(hessianInit,"eye")
    W=invW=eye(lp_N,lp_N);
  else
    error("Unknown hessianInit %s",hessianInit);
  endif

  %% SQP loop
  try
    [x,E,lm,sqp_iter,liter,feasible] = ...
      sqp_bfgs(x,@lp_fx,@lp_gx,"armijo_kim",xlb,xub,inf,...
               {W,invW},"bfgs",tol,maxiter,verbose);
  catch
    feasible=false;
    printf("sqp_bfgs() infeasible!\n");
    err=lasterror();
    printf("%s\n", err.message);
    for e=1:length(err.stack)
      printf("Called %s at line %d\n",err.stack(e).name,err.stack(e).line);
    endfor
  end_try_catch
  func_iter = lp_fiter;
endfunction

function [fx,gxf,hxxf]=lp_fx(x)
  global lp_fiter lp_lm lp_N ...
      lp_U lp_V lp_M lp_Q lp_R lp_Apass lp_fap lp_Wap lp_Lap ...
      lp_Tpass lp_ftp lp_Wtp lp_Ltp lp_fas lp_Was lp_Las lp_tol lp_verbose

  %% Call objective function
  lp_fiter++;
  if nargout==3 
    [wap,Ap,gradAp,wtp,Tp,gradTp,was,As,gradAs,E,gradE,hessE] = ...
        errorE(x,lp_U,lp_V,lp_M,lp_Q,lp_R,lp_Apass,lp_fap,lp_Wap,lp_Lap, ...
               lp_Tpass,lp_ftp,lp_Wtp,lp_Ltp,lp_fas,lp_Was,lp_Las,lp_tol);
  else
    [wap,Ap,gradAp,wtp,Tp,gradTp,was,As,gradAs,E,gradE] = ...
        errorE(x,lp_U,lp_V,lp_M,lp_Q,lp_R,lp_Apass,lp_fap,lp_Wap,lp_Lap, ...
               lp_Tpass,lp_ftp,lp_Wtp,lp_Ltp,lp_fas,lp_Was,lp_Las,lp_tol);
    hessE=eye(lp_N,lp_N);
  endif
    
  %% Function value, gradient, Hessian
  fx=E;
  gxf=gradE';
  hxxf=hessE;
endfunction

function [gx,gxg]=lp_gx(x)
  %% No constraint function
  gx=[];
  gxg=[];
endfunction
