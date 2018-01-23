function [abk,slb_iter,opt_iter,func_iter,feasible] = ...
         parallel_allpass_slb(pfx,ab0,abu,abl,Va,Qa,Ra,Vb,Qb,Rb, ...
                              polyphase,difference, ...
                              wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                              maxiter,tol,ctol,verbose)
% [abk,slb_iter,opt_iter,func_iter,feasible] = ...
%   parallel_allpass_slb(pfx,ab0,abu,abl,Va,Qa,Ra,Vb,Qb,Rb, ...
%                        polyphase,difference, ...
%                        wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                        maxiter,tol,ctol,verbose)
%
% PCLS optimisation of a parallel allpass filter with constraints on the
% amplitude and group delay responses. See:
%
% "Constrained Least Square Design of FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Trans. Signal Processing, Vol.44, No.8, August 1996, pp.1879--1892
%
% Inputs:
%   pfx - pointer to function that calls the inner optimisation loop:   
%         [xk,socp_iter,func_iter,feasible]= ...
%           pfx(vS,ab0,abu,abl,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
%               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%               maxiter,tol,verbose)
%   ab0 - initial coefficient vector in the form:
%          [ RpA(1:Va); abs(rpA(1:Qaon2)); angle(rpA(1:Qaon2)) ...
%          [ RpB(1:Vb); abs(rpB(1:Qbon2)); angle(rpB(1:Qbon2))];
%        where RpX represents real poles and rpX represents conjugate pole pairs
%   abu - upper constraints on the pole radiuses of the A and B allpass filters
%   abl - lower constraints on the pole radiuses of the A and B allpass filters
%   Va - number of real poles in filter A
%   Qa - number of conjugate pole pairs in filter A
%   Ra - decimation factor of filter A
%   Vb - number of real poles in filter B
%   Qb - number of conjugate pole pairs in filter B
%   Rb - decimation factor of filter B
%   polyphase - polyphase combination of the allpass filters
%   difference - difference of the allpass filters
%   wa - angular frequencies of amplitude response in [0,pi]
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of group delay response in [0,pi]
%   Td - desired passband group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   tol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   abk - filter design 
%   slb_iter - number of PCLS iterations
%   opt_iter - number of optimisation loop iterations
%   func_iter - number of function calls
%   feasible - abk satisfies the constraints 
%
% The constraints exchange algorithm is:
% 
%  1. Initialise the constraint sets R and S to the empty set
%  2. Solve for the Lagrange multipliers at the constraints in S
%  3. Check the KKT conditions. If they fail then remove the 
%     constraint with the most negative Lagrange multiplier from
%     S and go back to step 2.
%  4. Exchange constraints: calculate the new response and check 
%     for violation of the constraints in R. If any constraints 
%     are violated then move them from R to S and go back to step 2.
%  5. Update constraints: overwrite the previous constraint set R 
%     with S. Set the constraint set S to contain the peak or 
%     trough frequencies that fail the constraints.
%  6. If the solution has not converged then go back to step 2.
%
% See Figure 4 of "A Modified Algorithm for Constrained Least 
% Square Design of Multiband FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Transactions on Signal Processing, 46(2):497-501, February 1998.

% Copyright (C) 2017,2018 Robert G. Jenssen
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

  %
  % Sanity checks
  %
  if (nargin != 26) || (nargout > 5)
    print_usage("[abk,slb_iter,opt_iter,func_iter,feasible] = ...\n\
      parallel_allpass_slb(pfx,ab0,abu,abl,Va,Qa,Ra,Vb,Qb,Rb, ...\n\
                           polyphase,difference, ...\n\
                           wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n\
                           maxiter,tol,ctol,verbose)");
  endif
  if !is_function_handle(pfx)
    error("Expected pfx to be a function handle!");
  endif

  %
  % SLB constraints
  %

  %
  % Step 1: Initialise constraint sets of the amplitude and group
  % delay responses over frequency. vS.al etc are angular frequencies.
  %
  vR=parallel_allpass_slb_set_empty_constraints();
  Asqk=parallel_allpassAsq(wa,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
  Tk=parallel_allpassT(wt,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
  vS=parallel_allpass_slb_update_constraints ...
       (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,ctol);

  % Initialise SLB loop parameters
  info=0;slb_iter=0;opt_iter=0;func_iter=0;feasible=false;abk=ab0(:);
  
  % PCLS loop
  while 1
    
    % Check loop iterations
    slb_iter = slb_iter+1;
    if slb_iter>maxiter
      feasible = false;
      warning("PCLS loop iteration limit exceeded!");
      break;
    endif

    %
    % Step 2 : Solve the minimisation problem with the active constraints  
    % Step 3 : Test for optimality with Karush-Kuhn-Tucker conditions
    %
    try
      [nextabk,tmp_opt_iter,tmp_func_iter,feasible] = ...
      feval(pfx,vS,abk,abu,abl,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
            maxiter,tol,false);
      opt_iter = opt_iter + tmp_opt_iter;
      func_iter = func_iter + tmp_func_iter;
    catch
      feasible=0;
      err=lasterror();
      for e=1:length(err.stack)
        printf("Called from %s at line %d\n", ...
               err.stack(e).name, err.stack(e).line);
      endfor
      error("feval(pfx,...) failure : %s",err.message);
    end_try_catch
    if feasible
      if abk==nextabk
        printf("abk=[ ");printf("%f ",abk);printf("]';\n");
        warning("No change to solution after %d PCLS iterations\n",slb_iter);
        break;
      endif
      abk=nextabk;
      printf("Feasible solution after %d optimisation iterations\n", ...
             tmp_opt_iter);
      printf("abk=[ ");printf("%f ",abk);printf("]';\n");
    else
      warning("Optimisation solution not feasible!");
      break;
    endif

    %
    % Step 4: Check for violations over vR
    % 
    Asqk=parallel_allpassAsq(wa,abk,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
    Tk=parallel_allpassT(wt,abk,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
    [vR,vS,exchanged] = parallel_allpass_slb_exchange_constraints ...
                          (vS,vR,Asqk,Asqdu,Asqdl,Tk,Tdu,Tdl,ctol);
    if exchanged
      printf("Step 4: R constraints violated after ");
      printf("%d PCLS iterations\nGoing to Step 2!\n",slb_iter);
      continue;
    else
      printf("Step 4: no R constraints violated after ")
      printf("%d PCLS iterations\nGoing to Step 5!\n",slb_iter);
    endif

    %
    % Step 5: Multiple exchange of the constraint sets
    %
    vR=vS;
    vS=parallel_allpass_slb_update_constraints ...
       (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,ctol);
    printf("Step 5: vS frequency constraints updated to:\n");
    for [v,k]=vS
      printf("%s=[ ",k);printf("%d ",v);printf("]\n");
    endfor
    if verbose
      parallel_allpass_slb_show_constraints(vS,wa,Asqk,wt,Tk);
    endif

    %
    % Step 6: Check for convergence
    %
    if parallel_allpass_slb_constraints_are_empty(vS)
      printf("Step 6: Solution satisfying constraints found ");
      printf("after %d PCLS iterations\nDone!\n",slb_iter);
      break;
    else
      printf("Step 6: Solution does not satisfy S constraints ");
      printf("after %d PCLS iterations\nGoing to Step 2!\n",slb_iter);
      continue;
    endif

  % End of PCLS constraint loop
  endwhile

endfunction
