function [s10,s11,s20,s00,s02,s22,sqp_iter,func_iter,feasible]= ...
  schurNSlattice_sqp_mmse(vS,s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                          sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax,...
                          wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                          maxiter,ftol,ctol,verbose)
% [s10,s11,s20,s00,s02,s22,sqp_iter,func_iter,feasible]= ...
%   schurNSlattice_sqp_mmse(vS,s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
%                           sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax,...
%                           wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                           maxiter,ftol,ctol,verbose)
%
% SQP MMSE optimisation of a normalised Schur lattice filter with
% constraints on the amplitude and group delay responses. 
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   s10_0,s11_0,s20_0,s00_0,s02_0,s22_0 - initial allpass filter coefficients
%   sxx_u,sxx_l - upper and lower bounds on the allpass filter coefficients
%   sxx_active - vector giving the indexes of the coefficients being optimised
%   sxx_symmetric - enforce s02=-s20 and s22=s00
%   dmax - maximum coefficient step-size
%   wa - angular frequencies of squared-magnitude response in [0,pi]. 
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of delay response in [0,pi]. 
%   Td - desired passband group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   maxiter - maximum number of SQP iterations
%   ftol - tolerance on function value
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   s10,s11,s20,s00,s02,s22 - filter design
%   sqp_iter - number of SQP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 

% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  if (nargin ~= 26) || (nargout ~= 9)
    print_usage(["[s10,s11,s20,s00,s02,s22,sqp_iter,func_iter,feasible]= ...\n", ...
 "      schurNSlattice_sqp_mmse(vS,s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...\n", ...
 "                              sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...\n", ...
 "                              wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n", ...
 "                              maxiter,ftol,ctol,verbose)"]);
  endif

  %
  % Sanity checks
  %
  Ns=length(s10_0);
  wa=wa(:);
  wt=wt(:);
  Nwa=length(wa);
  Nwt=length(wt);
  if isempty(wa) && isempty(wt)
    error("wa and wt empty");
  endif
  if Ns ~= length(s11_0)
    error("Expected Ns == length(s11_0)");
  endif
  if Ns ~= length(s20_0)
    error("Expected Ns == length(s20_0)");
  endif
  if Ns ~= length(s00_0)
    error("Expected Ns == length(s00_0)");
  endif
  if Ns ~= length(s02_0)
    error("Expected Ns == length(s02_0)");
  endif
  if Ns ~= length(s22_0)
    error("Expected Ns == length(s22_0)");
  endif
  if length(sxx_u) ~= (6*Ns)
    error("Expected length(sxx_u) == (6*Ns)");
  endif
  if length(sxx_l) ~= (6*Ns)
    error("Expected length(sxx_l) == (6*Ns)");
  endif
  if length(sxx_active) == 0
    error("No active coefficients!");
  endif
  if (min(sxx_active)<=0)||((6*Ns)<max(sxx_active))
    error("Invalid sxx_active!");
  endif
  if Nwa ~= length(Asqd)
    error("Expected length(wa)(%d) == length(Asqd)(%d)",Nwa,length(Asqd));
  endif  
  if ~isempty(Asqdu) && Nwa ~= length(Asqdu)
    error("Expected length(wa)(%d) == length(Asqdu)(%d)",Nwa,length(Asqdu));
  endif
  if ~isempty(Asqdl) && Nwa ~= length(Asqdl)
    error("Expected lenth(wa)(%d) == length(Asqdl)(%d)",Nwa,length(Asqdl));
  endif
  if Nwa ~= length(Wa)
    error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
  endif
  if ~isempty(Tdu) && Nwt ~= length(Tdu)
    error("Expected length(wt)(%d) == length(Tdu)(%d)",Nwt,length(Tdu));
  endif
  if ~isempty(Tdl) && Nwt ~= length(Tdl)
    error("Expected length(wt)(%d) == length(Tdl)(%d)",Nwt,length(Tdl));
  endif
  if ~isempty(Wt) && Nwt ~= length(Wt)
    error("Expected length(wt)(%d) == length(Wt)(%d)",Nwt,length(Wt));
  endif
  if isempty(vS)
    vS=schurNSlattice_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 4) || (all(isfield(vS,{"al","au","tl","tu"}))==false)
    error("numfields(vS)=%d, expected 4 (al, au, tl and tu)",numfields(vS));
  endif
  
  %
  % Initialise. sxx_0 are the initial coefficients arranged by section:
  % [s10(1),s11(1),s20(1),...,s22(Ns)] 
  %
  s10_0=s10_0(:)';s11_0=s11_0(:)';
  s20_0=s20_0(:)';s00_0=s00_0(:)';
  if sxx_symmetric
    s02_0=-s20_0;s22_0=s00_0;
  else
    s02_0=s02_0(:)';s22_0=s22_0(:)';
  endif
  sxx_0=reshape([s10_0;s11_0;s20_0;s00_0;s02_0;s22_0],1,6*Ns);

  %
  % If sxx_symmetric, remove s02 and s22 from the list of active coefficients
  %
  if sxx_symmetric
    rm_sym_coef=[5+((0:(Ns-1))*6),6+((0:(Ns-1))*6)];
    sxx_active=sxx_active(find(not(ismember(sxx_active,rm_sym_coef))));
  endif
  
  %
  % Find xsxx_0, the row vector of active coefficients in sxx_0
  %
  xsxx_0=sxx_0(sxx_active);
  sxx_u=sxx_u(:)';
  xsxx_u=sxx_u(sxx_active);
  sxx_l=sxx_l(:)';
  xsxx_l=sxx_l(sxx_active);
  
  % Initialise objective function persistent constants
  [E,gradE,hessE]=schurNSlattice_sqp_mmse_fx(xsxx_0, ...
                    sxx_0,sxx_active,sxx_symmetric,wa,Asqd,Wa,wt,Td,Wt);

  % Initialise the approximation to the Hessian for the BFGS update
  W=diag(diag(hessE));
  invW=inv(W);

  % Initialise constraint function persistent constants
  gx=schurNSlattice_sqp_mmse_gx(xsxx_0,...
                                vS,sxx_0,sxx_active,sxx_symmetric, ...
                                wa,Asqdu,Asqdl,wt,Tdu,Tdl,ctol,false);
  
  % Initial check on constraints. Do not need to proceed if they are satisfied.
  if (isempty(gx) == false) && all(gx > -ctol)
    s10=s10_0;s11=s11_0;s20=s20_0;s00=s00_0;s02=s02_0;s22=s22_0;
    sqp_lm=[];
    sqp_iter=0;
    [dummy1,dummy2,dummy3,func_iter] = schurNSlattice_sqp_mmse_fx();
    feasible=true;
    printf("schurNSlattice_sqp_mmse(): initial coef.s satisfy constraints\n");
    return;
  endif
  
  %
  % Sequential Quadratic Programming (SQP) loop
  %
  xsxx=[];E=inf;sqp_lm=[];func_iter=0;sqp_iter=0;loop_iter=0;feasible=false;
  try
    [xsxx,E,sqp_lm,sqp_iter,loop_iter,feasible] = ...
      sqp_bfgs(xsxx_0, ...
               @schurNSlattice_sqp_mmse_fx,@schurNSlattice_sqp_mmse_gx, ... 
               "armijo_kim",xsxx_l,xsxx_u,dmax,{W,invW},"bfgs", ...
               maxiter,ftol,ctol,verbose);
    [dummy1,dummy2,dummy3,func_iter] = schurNSlattice_sqp_mmse_fx();
  catch
    s10=[];s11=[];s20=[];s00=[];s02=[];s22=[];sqp_lm=[];
    [dummy1,dummy2,dummy3,func_iter] = schurNSlattice_sqp_mmse_fx();
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
  [s10,s11,s20,s00,s02,s22]=xsxx2s(xsxx,sxx_0,sxx_active,sxx_symmetric);
  if (feasible)
    printf("Feasible MMSE solution after %d SQP iterations\n", sqp_iter);
    printf("s10=[ ");printf("%f ",s10');printf("]';\n");
    printf("s11=[ ");printf("%f ",s11');printf("]';\n");
    printf("s20=[ ");printf("%f ",s20');printf("]';\n");
    printf("s00=[ ");printf("%f ",s00');printf("]';\n");
    printf("s02=[ ");printf("%f ",s02');printf("]';\n");
    printf("s22=[ ");printf("%f ",s22');printf("]';\n");
  elseif sqp_iter>=maxiter
    warning("Maximum SQP iterations reached (%d). Bailing out!\n", sqp_iter);
    printf("s10=[ ");printf("%f ",s10');printf("]';\n");
    printf("s11=[ ");printf("%f ",s11');printf("]';\n");
    printf("s20=[ ");printf("%f ",s20');printf("]';\n");
    printf("s00=[ ");printf("%f ",s00');printf("]';\n");
    printf("s02=[ ");printf("%f ",s02');printf("]';\n");
    printf("s22=[ ");printf("%f ",s22');printf("]';\n");
  else
    warning("Solution not feasible after %d SQP iterations!\n", sqp_iter); 
  endif

endfunction

function [E,gradE,hessE,func_iter]=schurNSlattice_sqp_mmse_fx(xsxx, ...
  _sxx_0,_sxx_active,_sxx_symmetric,_wa,_Asqd,_Wa,_wt,_Td,_Wt)
         
  persistent sxx_0 sxx_active sxx_symmetric wa Asqd Wa wt Td Wt
  persistent iter=0
  persistent init_done=false

  % Initialise persistent (constant) values
  if nargin == 10
    sxx_0=_sxx_0;sxx_active=_sxx_active;sxx_symmetric=_sxx_symmetric;
    wa=_wa;Asqd=_Asqd;Wa=_Wa;
    wt=_wt;Td=_Td;Wt=_Wt;
    iter=0;
    init_done=true;
  elseif nargout == 4
    % Hack to avoid a global for func_iter
    E=inf;gradE=[];hessE=[];func_iter=iter;
    return;
  elseif nargin == 1
    if init_done == false
      error("init_done==false");
    endif
  else
    print_usage(["[E,gradE,hessE] = schurNSlattice_sqp_mmse_fx(xsxx);\n", ...
 "schurNSlattice_sqp_mmse_fx(xsxx,...\n", ...
 "  sxx_0,sxx_active,sxx_symmetric,wa,Asqd,Wa,wt,Td,Wt);\n", ...
 "[dummy1,dummy2,dummy3,func_iter] = schurNSlattice_sqp_mmse_fx(sxx);"]);
  endif

  % Initialise s10,etc
  [s10,s11,s20,s00,s02,s22]=xsxx2s(xsxx,sxx_0,sxx_active,sxx_symmetric);
  
  % Calculate error, error gradient and diagonal of error Hessian
  if nargout == 3
    [E,gradE,diagHessE]=...
    schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  elseif nargout == 2
    [E,gradE]=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    diagHessE=[];
  elseif nargout == 1
    E=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    gradE=[];
    diagHessE=[];
  endif

  % Force s02=-s20 and s22=s00?
  if sxx_symmetric
    if ~isempty(gradE)
      gradE=make_sxx_symmetric(gradE);
    endif
    if ~isempty(diagHessE)
      diagHessE=make_sxx_symmetric(diagHessE);
    endif
  endif  

  % Remove inactive coefficients
  if ~isempty(gradE)
    gradE=gradE(sxx_active);
    gradE=gradE(:);
  endif
  if ~isempty(diagHessE)
    hessE=diag(diagHessE(sxx_active)); 
  endif

  iter=iter+1;
  func_iter=iter;
  
endfunction

function [gx,B]=schurNSlattice_sqp_mmse_gx (xsxx, ...
                  _vS,_sxx_0,_sxx_active,_sxx_symmetric,...
                  _wa,_Asqdu,_Asqdl,_wt,_Tdu,_Tdl,_ctol,_verbose)
  
  persistent vS sxx_0 sxx_active sxx_symmetric
  persistent wa Asqdu Asqdl wt Tdu Tdl ctol verbose
  persistent init_done=false

  % Initialise persistent values
  if nargin == 13
    % Initialise constraints
    if isempty(_vS) 
      schurNSlattice_slb_set_empty_constraints(vS);
    else
      vS.al=_vS.al;vS.au=_vS.au;
      vS.tl=_vS.tl;vS.tu=_vS.tu;
    endif
    sxx_0=_sxx_0;sxx_active=_sxx_active;sxx_symmetric=_sxx_symmetric;
    wa=_wa;Asqdu=_Asqdu;Asqdl=_Asqdl;
    wt=_wt;Tdu=_Tdu;Tdl=_Tdl;
    ctol=_ctol;verbose=_verbose;
    init_done=true;
  elseif nargin == 1
    if init_done == false
      error("init_done==false");
    endif
  else
    print_usage(["[gx,B] = schurNSlattice_sqp_mmse_gx(xsxx); \n", ...
 "      schurNSlattice_sqp_mmse_gx(xsxx,vS,sxx_0,sxx_active,sxx_symmetric, ...\n", ...
 "                                 wa,Asqdu,Asqdl,wt,Tdu,Tdl,ctol,verbose)"]);
  endif

  % Do nothing
  if schurNSlattice_slb_constraints_are_empty(vS)
    gx=[];
    B=[];
    return;
  endif

  % Initialise s10,etc
  [s10,s11,s20,s00,s02,s22]=xsxx2s(xsxx,sxx_0,sxx_active,sxx_symmetric);
  
  % Find response at constraint frequencies
  if nargout == 2
    [Asql,gradAsql]=schurNSlatticeAsq(wa(vS.al),s10,s11,s20,s00,s02,s22);
    [Asqu,gradAsqu]=schurNSlatticeAsq(wa(vS.au),s10,s11,s20,s00,s02,s22);
    [Tl,gradTl]=schurNSlatticeT(wt(vS.tl),s10,s11,s20,s00,s02,s22);
    [Tu,gradTu]=schurNSlatticeT(wt(vS.tu),s10,s11,s20,s00,s02,s22); 
  else
    Asql=schurNSlatticeAsq(wa(vS.al),s10,s11,s20,s00,s02,s22);
    Asqu=schurNSlatticeAsq(wa(vS.au),s10,s11,s20,s00,s02,s22);
    Tl=schurNSlatticeT(wt(vS.tl),s10,s11,s20,s00,s02,s22);
    Tu=schurNSlatticeT(wt(vS.tu),s10,s11,s20,s00,s02,s22);
    gradAsql=[];
    gradAsqu=[];
    gradTl=[];
    gradTu=[];
  endif

  % Force s02=-s20 and s22=s00?
  if sxx_symmetric
    if ~isempty(gradAsql)
      gradAsql=make_sxx_symmetric(gradAsql);
    endif
    if ~isempty(gradAsqu)
      gradAsqu=make_sxx_symmetric(gradAsqu);
    endif
    if ~isempty(gradTl)
      gradTl=make_sxx_symmetric(gradTl);
    endif
    if ~isempty(gradTu)
      gradTu=make_sxx_symmetric(gradTu);
    endif
  endif  

  % Construct constraint vector
  gx=[Asql-Asqdl(vS.al); Asqdu(vS.au)-Asqu; Tl-Tdl(vS.tl); Tdu(vS.tu)-Tu];

  % Construct constraint gradient matrix
  if nargout==2
    B=[gradAsql; -gradAsqu; gradTl; -gradTu];
    B=B(:,sxx_active)';
  else
    B=[];
  endif

  % Show
  if verbose
    if all(gx>-ctol)
      printf("All constraints satisfied!\n");
    endif
  endif

endfunction

function [s10,s11,s20,s00,s02,s22]=xsxx2s(xsxx,sxx_0,sxx_active,sxx_symmetric)
  % Check sxx_0
  if rem(length(sxx_0),6)
    error("Expected length(sxx_0) to be a multiple of 6");
  endif
  Ns=length(sxx_0)/6;
  
  % Convert from a vector of coefficients arranged by section
  % ie: [s10(1),s11(1),...,s00(Ns),s22(Ns)] to s10,s11,s20,...
  sxx=sxx_0;
  sxx(sxx_active)=xsxx;
  sxx=reshape(sxx,6,Ns);
  s10=sxx(1,:);s11=sxx(2,:);
  s20=sxx(3,:);s00=sxx(4,:);
  if sxx_symmetric
    s02=-s20;s22=s00;
  else 
    s02=sxx(5,:);s22=sxx(6,:);
 endif


endfunction

function Y=make_sxx_symmetric(X)
  if rem(columns(X),6)
    error("columns(X) is not a multiple of 6");
  endif
  Ns=columns(X)/6;
  Ns_vec=(0:(Ns-1))*6;
  Y=X;
  Y(:,(3+Ns_vec))=X(:,(3+Ns_vec))-X(:,(5+Ns_vec));
  Y(:,(4+Ns_vec))=X(:,(4+Ns_vec))+X(:,(6+Ns_vec));
endfunction
