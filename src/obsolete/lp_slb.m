function [x,E,lm,iter,fiter,feasible] = lp_slb(x0,U,V,M,Q,R,fap,Wap,dbap,ftp,Wtp,tp,rtp,fas,Was,dbas,hessianInit,tol,maxiter,verbose)
%% [x,E,lm,iter,fiter,feasible] = lp_slb(x0,U,V,M,Q,R,fap,Wap, ...
%%  dbap,ftp,Wtp,tp,rtp,fas,Was,dbas,hessianInit,tol,maxiter,verbose)
%%
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
%%   fap - pass band amplitude edge frequency (sample rate is 1)
%%   Wap - pass band amplitude weight (a single value, eg: 10)
%%   dbap - amplitude pass band ripple in dB
%%   ftp - pass band group delay edge frequency
%%   Wtp - pass band group delay weight
%%   tp - desired pass band group delay in samples
%%   rtp - pass band group delay ripple in samples
%%   fas - stop band amplitude edge frequency
%%   Was - stop band amplitude weight
%%   dbas - stop band amplitude ripple in dB
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
%%   fiter - number of calls to the error function
%%   feasible - x satisfies the constraints
%%
%% Example of low-pass IIR filter design using quasi-Newton optimisation
%% with constraints on the peak amplitude and group delay errors based
%% on the paper by Selesnick, Lang and Burrus[1]. 
%%
%% By default, the sqp_bfgs() SQP solver uses the BFGS Hessian update
%% and the goldensection linesearch method. 
%%
%% References:
%% [1] "Constrained Least Square Design of FIR Filters without Specified 
%% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
%% Trans. Signal Processing, Vol.44, No.8, August 1996, pp.1879--1892
%% [2] "PCLS IIR Digital Filters with Simultaneous Frequency Response 
%% Magnitude and Group Delay Specifications", J. L. Sullivan and J. W. 
%% Adams, IEEE Trans. Signal Processing, Vol.46, No.11, November 1998,
%% pp.2853--2861.

  global lp_U lp_V lp_M lp_Q lp_R lp_N ...
         lp_Apass lp_fap lp_Wap lp_rap lp_Lap  ...
         lp_Tpass lp_ftp lp_Wtp lp_rtp lp_Ltp ...
         lp_fas lp_Was lp_ras lp_Las ...
         lp_verbose lp_lm lp_liter lp_fiter lp_tol ...
         lp_wap lp_Ap lp_gradAp lp_wtp lp_Tp lp_gradTp  ...
         lp_was lp_As lp_gradAs lp_E lp_gradE lp_hessE ...
         lp_Sap lp_Stp lp_Sas lp_lb lp_ub 

  %% Sanity checks
  if ((nargin != 20) || (nargout != 6))
    usage("[x,E,lm,iter,fiter,feasible] = lp_slb(x0,U,V,M,Q,R,\n\
fap,Wap,dbap,ftp,Wtp,tp,rtp,fas,Was,dbas,hessianInit,tol,maxiter,verbose)");
  endif

  if (length(x0) != (1+U+V+M+Q))
    error("Expected length(x0)==1+U+V+M+Q");
  endif

  %% Initialisation
  x=x0(:);
  E=0;
  lm=[];
  iter=0;
  fiter=0;
  lp_fiter=0;
  feasible=false;
  lp_verbose=verbose;
  lp_tol=tol;
  lm=[];

  lp_U=U;
  lp_V=V;
  lp_M=M;
  lp_Q=Q;    
  lp_R=R;
  lp_N=1+lp_U+lp_V+lp_M+lp_Q;
  lp_Lap=lp_Ltp=lp_Las=512;
  lp_Apass=ones(lp_Lap,1);
  lp_fap=fap;
  lp_Wap=Wap;
  lp_rap=10^(-dbap/20);
  lp_Tpass=tp*ones(lp_Ltp,1);
  lp_ftp=ftp;
  lp_Wtp=Wtp;
  lp_rtp=rtp;
  lp_fas=fas; 
  lp_Was=Was;
  lp_ras=10^(-dbas/20);

  %% Constraints on coeficients
  [lp_lb,lp_ub]=xConstraints(U,V,M,Q);

  %% Response and error
  lp_wap=[];lp_Ap=[];lp_gradAp=[];
  lp_wtp=[];lp_Tp=[];lp_gradTp=[];
  lp_was=[];lp_As=[];lp_gradAs=[];
  lp_E=[];lp_gradE=[];lp_hessE=[];

  %% Constraints on response
  lp_Sap=[];lp_Stp=[];lp_Sas=[];
  lp_Rap=[];lp_Rtp=[];lp_Ras=[];

  %% Initial check
  E=lp_fx(x);
  if updateSmoothConstraints(x)
    showSmoothConstraints(x);
    feasible=true;
    printf("Initial point satisfies constraints!\n");
    return
  endif

  %% Optimisation loop
  iter=0;
  do

    %% Optimise current constraints
    do 

      %% Call SQP loop
      showSmoothConstraints(x);
      iter++;

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
        printf("Starting SQP loop\n");
        [x,E,lm,siter,liter,feasible] = ...
          sqp_bfgs(x,@lp_fx,@lp_gx,"armijo_kim", ...
                   lp_lb,lp_ub,inf,{W,invW},"bfgs", ...
                   tol,maxiter,verbose);
      catch
        feasible=false;
        printf("sqp_bfgs() infeasible!\n");
        err=lasterror();
        printf("%s\n", err.message);
        for e=1:length(err.stack)
          printf("Called %s at line %d\n", ...
                 err.stack(e).name,err.stack(e).line);
        endfor
        return;
      end_try_catch
      if (feasible)
        printf("Feasible solution at %d iterations\nE=%f\n",siter,E);
        printf("x=[ ");printf("%f ",x);printf("]';\n");
      elseif iter>=maxiter
        warning("Maximum iterations reached (%d). Bailing out!\n", iter);
        printf("x=[ ");printf("%f ",x);printf("]';\n");
        return;
      else
        warning("Solution not feasible at %d iterations. Bailing out!\n",iter); 
        return;
      endif

      %% Check if any constraints from the previous pass are violated
    until exchangeSmoothConstraints();

    printf("Inner loop complete at %d iterations\n",iter);
    fiter=lp_fiter;
  until updateSmoothConstraints(x);

  printf("Found solution satisfying constraints\n");
  showSmoothConstraints(x);

endfunction

function gx=gSmooth()
  global lp_Apass lp_rap lp_Ap lp_Tpass lp_rtp lp_Tp lp_ras lp_As ...
         lp_Sap lp_Stp lp_Sas
  gx=[ -lp_Ap(lp_Sap) + lp_Apass(lp_Sap); ...
        lp_Ap(lp_Sap) - lp_rap*ones(size(lp_Sap)); ...
       -lp_Tp(lp_Stp) + (lp_Tpass(lp_Stp) + ...
                         (0.5*lp_rtp*ones(size(lp_Stp)))); ...
        lp_Tp(lp_Stp) - (lp_Tpass(lp_Stp) - ...
                         (0.5*lp_rtp*ones(size(lp_Stp)))); ...
       -lp_As(lp_Sas) + (lp_ras*ones(size(lp_Sas))); ];
endfunction

function [fx,gxf,hxxf]=lp_fx(x)
  global lp_wap lp_Ap lp_gradAp lp_wtp lp_Tp lp_gradTp  ...
      lp_was lp_As lp_gradAs lp_E lp_gradE lp_hessE ...
      lp_U lp_V lp_M lp_Q lp_R lp_Apass lp_fap lp_Wap lp_rap lp_Lap  ...
      lp_Tpass lp_ftp lp_Wtp lp_rtp lp_Ltp lp_fas lp_Was lp_ras lp_Las ...
      lp_N lp_Sap lp_Stp lp_Sas lp_lb lp_ub ...
      lp_verbose lp_lm lp_liter lp_fiter lp_tol

  %% Call objective function
  lp_fiter++;
  if nargout==3
    [lp_wap,lp_Ap,lp_gradAp,lp_wtp,lp_Tp,lp_gradTp, ...
     lp_was,lp_As,lp_gradAs,lp_E,lp_gradE,lp_hessE] = ...
        errorE(x,lp_U,lp_V,lp_M,lp_Q,lp_R,lp_Apass,lp_fap,lp_Wap,lp_Lap, ...
               lp_Tpass,lp_ftp,lp_Wtp,lp_Ltp,lp_fas,lp_Was,lp_Las,lp_tol);
  else
    [lp_wap,lp_Ap,lp_gradAp,lp_wtp,lp_Tp,lp_gradTp, ...
     lp_was,lp_As,lp_gradAs,lp_E,lp_gradE] = ...
        errorE(x,lp_U,lp_V,lp_M,lp_Q,lp_R,lp_Apass,lp_fap,lp_Wap,lp_Lap, ...
               lp_Tpass,lp_ftp,lp_Wtp,lp_Ltp,lp_fas,lp_Was,lp_Las,lp_tol);
    lp_hessE=eye(lp_N,lp_N);
  endif

  %% Function value, gradient, Hessian
  fx = lp_E;
  gxf=lp_gradE';
  hxxf=lp_hessE;
endfunction

function [gx,gxg]=lp_gx(x)
  global lp_wap lp_Ap lp_gradAp lp_wtp lp_Tp lp_gradTp  ...
      lp_was lp_As lp_gradAs lp_Sap lp_Stp lp_Sas ...
      lp_U lp_V lp_M lp_Q lp_R lp_tol

  %% !!!NOTE WELL!!!
  %% Assume lp_wap, lp_wtp and lp_was are already set
  [lp_Ap,lp_gradAp]=iirA(lp_wap,x,lp_U,lp_V,lp_M,lp_Q,lp_R,lp_tol);
  [lp_Tp,lp_gradTp]=iirT(lp_wtp,x,lp_U,lp_V,lp_M,lp_Q,lp_R,lp_tol);
  [lp_As,lp_gradAs]=iirA(lp_was,x,lp_U,lp_V,lp_M,lp_Q,lp_R,lp_tol);

  %% Constraints
  gx=gSmooth();
 
  %% Constraint gradients
  gxg=[ -lp_gradAp(lp_Sap,:); ...
          lp_gradAp(lp_Sap,:); ...
         -lp_gradTp(lp_Stp,:); ...
          lp_gradTp(lp_Stp,:); ...
         -lp_gradAs(lp_Sas,:) ]';
endfunction

function vS=findS()
  global lp_tol
  gS=gSmooth();
  vS=find(gS < -lp_tol);
endfunction

function ok=exchangeSmoothConstraints()
  global lp_tol lp_wap lp_Ap lp_wtp lp_Tp lp_was lp_As ...
      lp_Apass lp_rap lp_Tpass lp_rtp lp_ras ...
      lp_Sap lp_Stp lp_Sas lp_Rap lp_Rtp lp_Ras
  
  %% Pass band amplitude upper
  gRapu=[ -lp_Ap(lp_Rap) + lp_Apass(lp_Rap) ];
  vgRapu=find(gRapu<-lp_tol);
  if !isempty(vgRapu)
    for k=vgRapu(:)'
      printf("Exchange Rap upper %d: %f,%f\n", ...
             k,lp_wap(lp_Rap(k))*0.5/pi,lp_Ap(lp_Rap(k)));
    endfor
    lp_Sap=unique([lp_Sap; lp_Rap(vgRapu)]);
    lp_Rap(vgRapu)=[];
  endif

  %% Pass band amplitude lower
  gRapl=[ lp_Ap(lp_Rap) - ...
         (lp_Apass(lp_Rap)-lp_rap*ones(size(lp_Apass(lp_Rap))))];
  vgRapl=find(gRapl<-lp_tol);
  if !isempty(vgRapl)
    for k=vgRapl(:)'
      printf("Exchange Rap lower %d: %f,%f\n", ...
             k,lp_wap(lp_Rap(k))*0.5/pi,lp_Ap(lp_Rap(k)));
    endfor
    lp_Sap=unique([lp_Sap; lp_Rap(vgRapl)]);
    lp_Rap(vgRapl)=[];
  endif

  %% Pass band delay upper
  gRtpu=[-lp_Tp(lp_Rtp) + ...
         (lp_Tpass(lp_Rtp)+ (0.5*lp_rtp*ones(size(lp_Tpass(lp_Rtp)))))];
  vgRtpu=find(gRtpu<-lp_tol);
  if !isempty(vgRtpu)
    for k=vgRtpu(:)'
      printf("Exchange Rtp upper %d: %f,%f\n", ...
             k,lp_wtp(lp_Rtp(k))*0.5/pi,lp_Tp(lp_Rtp(k)));
    endfor
    lp_Stp=unique([lp_Stp; lp_Rtp(vgRtpu)]);
    lp_Rtp(vgRtpu)=[];
  endif

  %% Pass band delay lower
  gRtpl=[lp_Tp(lp_Rtp) - (lp_Tpass(lp_Rtp)- ...
                          (0.5*lp_rtp*ones(size(lp_Tpass(lp_Rtp)))))];
  vgRtpl=find(gRtpl<-lp_tol);
  if !isempty(vgRtpl)
    for k=vgRtpl(:)'
      printf("Exchange Rtp lower %d: %f,%f\n", ...
             k,lp_wtp(lp_Rtp(k))*0.5/pi,lp_Tp(lp_Rtp(k)));
    endfor
    lp_Stp=unique([lp_Stp; lp_Rtp(vgRtpl)]);
    lp_Rtp(vgRtpl)=[];
  endif

  %% Stop band amplitude
  gRasu=[ -lp_As(lp_Ras) + (lp_ras*ones(size(lp_Ras))) ];
  vgRasu=find(gRasu<-lp_tol);
  if !isempty(vgRasu)
    for k=vgRasu(:)'
      printf("Exchange Ras upper %d: %f,%f\n", ...
             k,lp_was(lp_Ras(k))*0.5/pi,lp_As(lp_Ras(k)));
    endfor
    lp_Sas=unique([lp_Sas; lp_Ras(vgRasu)]);    
    lp_Ras(vgRasu)=[];
  endif

  %% Check for violated constraints
  vS=findS();
  ok=isempty(vS);
  printf("\nExchange of smooth constraints complete.\n");
  if ok == false
    printf("Some constraints violated\n");
  endif
     
endfunction 

function ok=updateSmoothConstraints(x)
  global lp_tol lp_N ...
      lp_Lap lp_Ltp lp_Las lp_Ap lp_Tp lp_As ...
      lp_Sap lp_Stp lp_Sas lp_Rap lp_Rtp lp_Ras

  %% Backup current constraints
  lp_Rap=lp_Sap;
  lp_Rtp=lp_Stp;
  lp_Ras=lp_Sas;

  %% Find peaks in amplitude and group delay
  Sapu = local_max( lp_Ap);
  Sapl = local_max(-lp_Ap);
  Stpu = local_max( lp_Tp);
  Stpl = local_max(-lp_Tp);
  Sasu = local_max( lp_As);

  lp_Sap=[Sapu;Sapl];
  lp_Stp=[Stpu;Stpl];
  lp_Sas=Sasu;

  %% Check all constraints
  vS=findS();
  ok=isempty(vS);

  %% Echo
  printf("\nUpdate of smooth constraints complete\n");
endfunction 

function showSmoothConstraints(x)
  global lp_wap lp_Ap lp_wtp lp_Tp lp_was lp_As ...
      lp_Sap lp_Stp lp_Sas lp_tol
  
  vS=findS();
  for k=vS(:)'
    if k<=length(lp_Sap)
      kSapu=k;
      printf("Sap upper constraint violated at %f, %f\n", ...
             lp_wap(lp_Sap(kSapu))*0.5/pi,lp_Ap(lp_Sap(kSapu)));

    elseif k<=2*length(lp_Sap)
      kSapl=k-length(lp_Sap);
      printf("Sap lower constraint violated at %f, %f\n", ...
             lp_wap(lp_Sap(kSapl))*0.5/pi,lp_Ap(lp_Sap(kSapl)));

    elseif k<=2*length(lp_Sap)+length(lp_Stp)
      kStpu=k-2*length(lp_Sap);
      printf("Stp upper constraint violated at %f, %f\n", ...
             lp_wtp(lp_Stp(kStpu))*0.5/pi,lp_Tp(lp_Stp(kStpu)));

    elseif k<=2*length(lp_Sap)+2*length(lp_Stp)
      kStpl=k-2*length(lp_Sap)-length(lp_Stp);
      printf("Stp lower constraint violated at %f, %f\n", ...
             lp_wtp(lp_Stp(kStpl))*0.5/pi,lp_Tp(lp_Stp(kStpl)));

    elseif k<=2*length(lp_Sap)+2*length(lp_Stp)+length(lp_Sas)
      kSasu=k-2*length(lp_Sap)-2*length(lp_Stp);
      printf("Sas upper constraint violated at %f, %f\n", ...
             lp_was(lp_Sas(kSasu))*0.5/pi,lp_As(lp_Sas(kSasu)));

    else
      error("Invalid index into vS: %d of %d. Bailing out!\n",k,length(lp_S));
    endif
  endfor
endfunction

