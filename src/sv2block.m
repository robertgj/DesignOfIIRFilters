function [Ad,Bd,Cd,Dd] = sv2block(p,A,B,C,D)
% function [Ad,Bd,Cd,Dd] = sv2block(p,A,B,C,D)
% Find the state variable equations for the block
% proccessing of the state variable equations represented
% by A,B,C,D. Inputs are processed n at a time:
%     x(k+p)=Adx(k)+Bdu(k)
%     y(k)=Cx(k)+Du(k)
% where u is length p vector of inputs and y is a length
% p vector of outputs.

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

if nargin  ~= 5 
  error("Sorry, expected five input arguments");
end 

% Apply decimation
Ad=A;Bd=B;Cd=C;Dd=D;
for k=2:p
  Ad = A*Ad;
  Bd = [A*Bd B];
  Dd = [D zeros(1,k-1); Cd*B Dd];
  Cd = [C; Cd*A];
end

endfunction
