function [A,B,C,D,Cap,Dap,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ...
  schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)
% [A,B,C,D,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ...
%   schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)
% Find the state variable representation of a pipelined Schur one-multiplier
% lattice filter.
%
% Inputs:
%  k       - the lattice filter one-multiplier coefficients
%  epsilon - the sign coefficients for each module
%  c       - the numerator polynomial tap weights in the orthogonal basis
%  kk      - k(1:(Nk-1)).*k(2:Nk)
%  ck      - c(2:Nk).*k(2:Nk) (c(1)=c_{0}, ... ,c(Nk+1)=c_{Nk})
% Outputs:
%  [A,B;C,D] - state variable description of the pipelined Schur lattice filter
%  Cap, Dap  - corresponding matrixes for the all-pass filter
%  ABCD0, ABCDk, ABCDc, ABCDkk, ABCDck - cell arrays of matrixes
%              corresponding to each coefficient k_1,...,k_{Nk}, c_0,...,c_{Nk},
%              (or c(1),...,c(Nk+1)), kk_1,...kk_{Nk-1}, ck_1,...,ck_{Nk-1}
%
% The lattice filter structure is, for N odd and Y=3*ceil(N/2)-2:
%                                           
%       _______                 _______   __x2__   _______  
% Out <-|     |<----------...<--|     |<--|z^-1|<--|     |<---------|
%       |     |                 |     |   ------   |     |          | c(1)=c_0
%       |     |   __xY__        |     |            |     |  __x1__  |
%  In ->|  N  |-->|z^-1|->...-->|  2  |->--------->|  1  |->|z^-1|->o
%       |     |   ------        |     |            |     |  ------  |
%       |     |                 |     |   __x3__   |     |          |
%  AP <-|     |<----------...<--|     |<--|z^-1|<--|     |<---------|
% Out   -------                 -------   ------   -------
%
% Each module 1,..,N is implemented as:
%                      
%     <-----------+<---------------<
%                 ^         
%                c|
%                 |
%         ------->o-------------
%         |                    |
%         |     k    epsilon   V
%     >---o->+---->o---------->+--->
%             ^\  /  
%               \/       
%               /\
%              /  \-epsilon
%             v    \
%     <------+<-----o--------------<
%
  
% Copyright (C) 2017-2024 Robert G. Jenssen
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


  % Sanity checks
  if nargin<3 || nargin>5 || nargout<4 || nargout>11
    print_usage("[A,B,C,D] = schurOneMlatticePipelined2Abcd(k,epsilon,c)\n\
[A,B,C,D,Cap,Dap,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ... \n\
  schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)\n");
  endif

  if isempty(k)
    error("k is empty!");
  endif
  if length(k)~=length(epsilon) || ...
     (length(k)+1)~=length(c)
    error("Input coefficient lengths inconsistent!");
  endif
  
  % Initialise
  Nk=length(k);
  Nc=length(c);
  if rem(Nk,2)
    Ns=(3*ceil(Nk/2))-2;
  else
    Ns=3*Nk/2;
  endif

  if nargin==3
    kk=k(1:(Nk-1)).*k(2:Nk);
  else
    if length(kk) ~= (length(k)-1)
      error("length(kk) ~= (length(k)-1)");
    endif
  endif
  if nargin<5
    ck=c(2:Nk).*k(2:Nk);
  else
    if length(ck) ~= (length(k)-1)
      error("length(ck) ~= (length(k)-1)");
    endif
  endif
  
  % Modules 1 to ceil(Nk/2)-1
  ABCD=[c(1),zeros(1,Ns);1,zeros(1,Ns);eye(Ns+1)];
  for n=1:(ceil(Nk/2)-1)
    ABCDm=eye(Ns+3);
    ABCDm((3*(n-1))+(1:5),(3*(n-1))+(1:6))=...
      [0,-k((2*n)-1),0,0,-k(2*n)-(kk((2*n)-1)*epsilon((2*n-1))), ...
       1+(k((2*n)-1)*epsilon((2*n)-1))+(k(2*n)*epsilon(2*n))+...
       (kk((2*n)-1)*epsilon((2*n)-1)*epsilon(2*n));...
       1,0,0,0,-ck((2*n)-1),c(2*n)+(ck((2*n)-1)*epsilon(2*n));...
       0,1-(k((2*n)-1)*epsilon((2*n)-1)),0,0,-kk((2*n)-1), ...
       k((2*n)-1)+(kk((2*n)-1)*epsilon(2*n));...
       0,0,0,1,0,c((2*n)+1);...
       0,0,0,0,1-(k(2*n)*epsilon(2*n)),k(2*n)];
    ABCD=ABCDm*ABCD;
  endfor

  % Final module
  if rem(Nk,2)
    ABCDm=eye(Ns+2);
    ABCDm(Ns-1+(1:3),Ns-1+(1:4))=...
    [0,-k(Nk),0,1+(k(Nk)*epsilon(Nk)); ...
     1,0,0,c(Nc); ...
     0,1-(k(Nk)*epsilon(Nk)),0,k(Nk)];
  else
    ABCDm=eye(Ns+2);
    ABCDm(Ns-3+(1:5),Ns-3+(1:6))=...
      [0,-k(Nk-1),0,0,-k(Nk)-(kk(Nk-1)*epsilon(Nk-1)), ...
       1+(k(Nk-1)*epsilon(Nk-1))+(k(Nk)*epsilon(Nk))+...
       (kk(Nk-1)*epsilon(Nk-1)*epsilon(Nk));...
       1,0,0,0,-ck(Nk-1),c(Nc-1)+(ck(Nk-1)*epsilon(Nk));...
       0,1-(k(Nk-1)*epsilon(Nk-1)),0,0,-kk(Nk-1),...
       k(Nk-1)+(kk(Nk-1)*epsilon(Nk));...
       0,0,0,1,0,c(Nc);...
       0,0,0,0,1-(k(Nk)*epsilon(Nk)),k(Nk)];
  endif
  ABCD=ABCDm*ABCD;

  % Extract the state variable description
  A=ABCD(1:Ns,1:Ns);
  B=ABCD(1:Ns,Ns+1);
  C=ABCD(Ns+1,1:Ns);
  D=ABCD(Ns+1,Ns+1);
  Cap=ABCD(Ns+2,1:Ns);
  Dap=ABCD(Ns+2,Ns+1);

  if nargout <= 6
    return;
  endif

  %
  % Initialise matrix cell arrays
  %
  ABCD0=zeros(Ns+2,Ns+1);
  ABCDk=cell(1,Nk);
  for s=1:Nk
    ABCDk{s}=zeros(size(ABCD0));
  endfor
  ABCDc=cell(1,Nk+1);
  for s=1:(Nk+1)
    ABCDc{s}=zeros(size(ABCD0));
  endfor
  ABCDkk=cell(1,Nk-1);
  for s=1:(Nk-1)
    ABCDkk{s}=zeros(size(ABCD0));
  endfor
  ABCDck=cell(1,Nk-1);
  for s=1:(Nk-1)
    ABCDck{s}=zeros(size(ABCD0));
  endfor
  
  if Nk==1
    % Constant coefficient matrix
    ABCD0(1,2)=1;
    ABCD0(3,1)=1;
    % k coefficient matrix
    ABCDk{1}(1,1)=-1;
    ABCDk{1}(1,2)=epsilon(1);
    ABCDk{1}(3,1)=-epsilon(1);
    ABCDk{1}(3,2)=1;
    % c coefficient matrix
    ABCDc{1}(2,1)=1;
    ABCDc{2}(2,2)=1;
    % kk coefficient matrix
    % ck coefficient matrix
    return;
  endif
 
  % Coefficients of the first second order section (including c(1)=c0)
  % Constant coefficient matrix
  ABCD0(1,4)=1;
  ABCD0(3,1)=1;
  % k coefficient matrix
  ABCDk{1}(1,1)=-1;
  ABCDk{1}(1,4)=epsilon(1);
  ABCDk{1}(3,1)=-epsilon(1);
  ABCDk{1}(3,4)=1;
  ABCDk{2}(1,3)=-1;
  ABCDk{2}(1,4)=epsilon(2);
  % c coefficient matrix
  ABCDc{1}(2,1)=1;
  ABCDc{2}(2,4)=1;
  % kk coefficient matrix
  ABCDkk{1}(1,3)=-epsilon(1);
  ABCDkk{1}(1,4)=epsilon(1)*epsilon(2);
  ABCDkk{1}(3,3)=-1;
  ABCDkk{1}(3,4)=epsilon(2);
  % ck coefficient matrix
  ABCDck{1}(2,3)=-1;
  ABCDck{1}(2,4)=epsilon(2);

  % Loop over remaining second order sections excepting the output
  for s=3:3:(Ns-2),
    sk=2*(s/3);
    % Constant coefficient matrix
    ABCD0(s+1,s+4)=1;
    ABCD0(s+2,s-1)=1;
    ABCD0(s+3,s)=1;
    % k coefficient matrix
    ABCDk{sk}(s+3,s)=-epsilon(sk);
    ABCDk{sk}(s+3,s+1)=1;
    ABCDk{sk+1}(s+1,s)=-1;
    ABCDk{sk+1}(s+1,s+4)=epsilon(sk+1);
    ABCDk{sk+1}(s+3,s)=-epsilon(sk+1);
    ABCDk{sk+1}(s+3,s+4)=1;
    ABCDk{sk+2}(s+1,s+3)=-1;
    ABCDk{sk+2}(s+1,s+4)=epsilon(sk+2);
    % c coefficient matrix
    ABCDc{sk+1}(s+2,s+1)=1;
    ABCDc{sk+2}(s+2,s+4)=1;
    % kk coefficient matrix
    ABCDkk{sk}(s+1,s)=epsilon(sk);
    ABCDkk{sk}(s+1,s+1)=-1;
    ABCDkk{sk}(s+3,s)=epsilon(sk)*epsilon(sk+1);
    ABCDkk{sk}(s+3,s+1)=-epsilon(sk+1);
    ABCDkk{sk+1}(s+1,s+3)=-epsilon(sk+1);
    ABCDkk{sk+1}(s+1,s+4)=epsilon(sk+1)*epsilon(sk+2);
    ABCDkk{sk+1}(s+3,s+3)=-1;
    ABCDkk{sk+1}(s+3,s+4)=epsilon(sk+2);
    % ck coefficient matrix
    ABCDck{sk+1}(s+2,s+3)=-1;
    ABCDck{sk+1}(s+2,s+4)=epsilon(sk+2);
  endfor
  % Finalise cell array matrixes
  if rem(Nk,2)
    % Constant coefficient matrix
    ABCD0(Ns,Ns+1)=1; 
    ABCD0(Ns+1,Ns-2)=1;
    ABCD0(Ns+2,Ns-1)=1;
    % k coefficient matrix
    ABCDk{Nk-1}(Ns+2,Ns-1)=-epsilon(Nk-1);
    ABCDk{Nk-1}(Ns+2,Ns)=1;
    ABCDk{Nk}(Ns,Ns-1)=-1;
    ABCDk{Nk}(Ns,Ns+1)=epsilon(Nk);
    ABCDk{Nk}(Ns+2,Ns-1)=-epsilon(Nk);
    ABCDk{Nk}(Ns+2,Ns+1)=1;
    % c coefficient matrix
    ABCDc{Nk}(Ns+1,Ns)=1;
    ABCDc{Nk+1}(Ns+1,Ns+1)=1;
    % kk coefficient matrix
    ABCDkk{Nk-1}(Ns,Ns-1)=epsilon(Nk-1);
    ABCDkk{Nk-1}(Ns,Ns)=-1;
    ABCDkk{Nk-1}(Ns+2,Ns-1)=epsilon(Nk-1)*epsilon(Nk);
    ABCDkk{Nk-1}(Ns+2,Ns)=-epsilon(Nk);
    % ck coefficient matrix
  else
    % Constant coefficient matrix
    ABCD0(Ns+1,Ns-1)=1;
    ABCD0(Ns+2,Ns)=1;
    % k coefficient matrix
    ABCDk{Nk}(Ns+2,Ns)=-epsilon(Nk);
    ABCDk{Nk}(Ns+2,Ns+1)=1;
    % c coefficient matrix
    ABCDc{Nk+1}(Ns+1,Ns+1)=1;
  endif

endfunction
