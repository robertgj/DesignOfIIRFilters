function Da0=allpass_delay_wise_lowpass(m,DD,fap,fas,Was,td,ftp,Wtp)
% Da0=allpass_delay_wise_lowpass(m,DD,fap,fas,Was,td,ftp,Wtp)
% Design a lowpass filter consisting of an allpass filter in parallel
% with a delay using the method of Tarczynski et al. 
% Inputs:
%  m - allpass filter order
%  DD - parallel delay in samples
%  fap,fas - low-pass filter amplitude pass-band and stop-band frequencies
%  Was - amplitude stop-band weight (pass-band weight is 1)
%  td - nominal pass-band delay
%  ftp - low-pass filter delay pass-band frequency
%  Wtp - delay pass-band weight 
% Output:
%  Da0 - allpass denominator polynomial
  
% Copyright (C) 2024-2025 Robert G. Jenssen
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

  if ((nargin~=5) && (nargin~=8)) || (nargout~=1)
    print_usage("Da0=allpass_delay_wise_lowpass(m,DD,fap,fas,Was,td,ftp,Wtp)");
  endif

  maxiter=5000;
  % Frequency points
  n=1000;
  fplot=0.5*(0:(n-1))'/n;
  wplot=2*pi*fplot;
  nap=ceil(fap*n/0.5)+1;
  nas=floor(fas*n/0.5)+1;
  Wap=1;

  % Frequency vectors
  Ad=[ones(nap,1);zeros(n-nap,1)];
  Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
  if nargin == 8
    ntp=floor(ftp*n/0.5)+1;
    Td=td*ones(ntp,1);
    Wt=Wtp*ones(ntp,1);
  else
    Td=[];
    Wt=[];
  endif

  % Unconstrained minimisation
  R=1;
  polyphase=false;
  tol=1e-9;
  ai=[-0.9;zeros(m-1,1)];
  WISEJ_DA([],R,DD,polyphase,Ad,Wa,Td,Wt);
  opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
  [a0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_DA,ai,opt);
  if (INFO == 1)
    printf("Converged to a solution point.\n");
  elseif (INFO == 2)
    printf("Last relative step size was less than TolX.\n");
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

  % Create the initial polynomials
  a0=a0(:);
  Da0=[1;kron(a0,[zeros(R-1,1);1])];
endfunction
