function [nextW,nextInvW]=updateWbfgs(delta,gamma,W,invW,min_delta,verbose)

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

  if (nargin < 4) || (nargin > 6)
    print_usage("[nextW,nextInvW]=updateWbfgs(delta,gamma,W,invW,min_delta)");
  elseif nargin == 4
    min_delta=1e4*eps;
    verbose=false;
  elseif nargin == 5
    verbose=false;
  endif
  
  nextW=nextinvW=[];

  % Find Powells eta
  gamma=gamma(:);
  delta=delta(:);
  deltaTgamma=gamma'*delta;
  Wdelta=W*delta;
  deltaTWdelta=delta'*Wdelta;
  if deltaTgamma >= 0.2*deltaTWdelta
    theta = 1;
  else
    theta = 0.8*deltaTWdelta/(deltaTWdelta-deltaTgamma);
  endif
  eta = (theta*gamma)+((1-theta)*Wdelta);

  % Update W with Broyden-Fletcher-Goldfarb-Shannon
  nextW=W-(kron(Wdelta,Wdelta')/(delta'*Wdelta));
  deltaTeta=(delta')*eta;
  nextW=nextW+(kron(eta,eta')/(deltaTeta));

  % Update invW with Sherman-Morrison
  invWeta=invW*eta;
  nextInvW=invW + ...
           (1+((eta'*invWeta)/deltaTeta))*kron(delta,delta')/deltaTeta - ...
           (kron(invWeta,delta')+kron(delta,invWeta'))/deltaTeta;

endfunction
