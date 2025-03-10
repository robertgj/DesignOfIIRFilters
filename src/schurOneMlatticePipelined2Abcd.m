function [A,B,C,D,Cap,Dap,dummy1,dummy2,dummy3,dummy4,dummy5,dummy6] = ...
  schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)
% [A,B,C,D,Cap,Dap,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ...
%   schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)
% [A,B,C,D,Cap,Dap,dAdx,dBdx,dCdx,dDdx,dCapdx,dDapdx] = ...
%   schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)
% Find the state variable representation of a pipelined Schur one-multiplier
% lattice filter.
%
% Inputs:
%  k       - the lattice filter one-multiplier coefficients
%  epsilon - the sign coefficients for each module
%  c       - the numerator polynomial tap weights in the orthogonal basis
%  kk      - If not supplied then:
%              k(1:(Nk-1)).*k(2:Nk)
%  ck      - If not supplied then:
%              c(2:Nk).*k(2:Nk) (where c(1)=c_{0}, ... ,c(Nk+1)=c_{Nk})
% Outputs:
%  [A,B;C,D] - state variable description of the pipelined Schur lattice filter
%  Cap, Dap  - corresponding matrixes for the all-pass filter output
%  ABCD0,etc - cell arrays of matrixes of size (Ns+2)x(Ns+1) corresponding to
%              each coefficient k,c,kk and ck. Rows Ns+1 and Ns+2 of ABCD0,etc
%              correspond to the tapped and allpass outputs, respectively, and:
%                [A,B;C,D;Cap,Dap]=ABCD0+sum_over_s(k(s)*ABCDk{s})+...
%  dAdx,etc  - cell array of derivatives of A,etc wrt x=[k(:);(c(:);kk(:);ck(:)]
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
% See schurOneMlatticePipelined2Abcd_symbolic_test.m
  
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


  % Sanity checks
  if nargin<3 || nargin>5 || ...
     (nargout~=4 && nargout~=6 && nargout~=11 && nargout~=12)
    print_usage(["[A,B,C,D] = schurOneMlatticePipelined2Abcd(k,epsilon,c)\n", ...
 "[A,B,C,D,Cap,Dap] = schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)\n", ...
 "[A,B,C,D,Cap,Dap,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ... \n", ...
 "  schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)\n", ...
 "[A,B,C,D,Cap,Dap,dAdx,dBdx,dCdx,dDdx,dCapdx,dDapdx] = ... \n", ...
 "  schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck)\n"]);
  endif

  if isempty(k)
    error("k is empty!");
  endif
  if length(k)~=length(epsilon) || ...
     (length(k)+1)~=length(c)
    error("Input coefficient lengths inconsistent!");
  endif
  
  % Initialise
  k=k(:);
  Nk=length(k);
  epsilon=epsilon(:);

  c=c(:);
  Nc=length(c);

  if nargin<4
    kk=k(1:(Nk-1)).*k(2:Nk);
  else
    if length(kk) ~= (length(k)-1)
      error("length(kk) ~= (length(k)-1)");
    endif
  endif
  kk=kk(:);
  Nkk=length(kk);

  if nargin<5
    ck=c(2:Nk).*k(2:Nk);
  else
    if length(ck) ~= (length(k)-1)
      error("length(ck) ~= (length(k)-1)");
    endif
  endif
  ck=ck(:);
  Nck=length(ck);
   
  if rem(Nk,2)
    Ns=(3*ceil(Nk/2))-2;
  else
    Ns=3*Nk/2;
  endif

  %
  % Initialise matrix coefficient cell arrays
  %
  ABCD0=zeros(Ns+2,Ns+1);
  ABCDk=cell(1,Nk);
  for s=1:Nk
    ABCDk{s}=zeros(size(ABCD0));
  endfor
  ABCDc=cell(1,Nc);
  for s=1:(Nc)
    ABCDc{s}=zeros(size(ABCD0));
  endfor
  ABCDkk=cell(1,Nkk);
  for s=1:(Nkk)
    ABCDkk{s}=zeros(size(ABCD0));
  endfor
  ABCDck=cell(1,Nck);
  for s=1:(Nck)
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
  else 
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
  endif

  % Find ABCDCapDap
  ABCD=ABCD0;
  for s=1:Nk
    ABCD=ABCD+(k(s)*ABCDk{s});
  endfor
  for s=1:Nc
    ABCD=ABCD+(c(s)*ABCDc{s});
  endfor
  for s=1:Nkk
    ABCD=ABCD+(kk(s)*ABCDkk{s});
  endfor
  for s=1:Nck
    ABCD=ABCD+(ck(s)*ABCDck{s});
  endfor

  A=ABCD(1:Ns,1:Ns);
  B=ABCD(1:Ns,Ns+1);
  C=ABCD(Ns+1,1:Ns);
  D=ABCD(Ns+1,Ns+1);
  Cap=ABCD(Ns+2,1:Ns);
  Dap=ABCD(Ns+2,Ns+1);
  
  if nargout <= 11
    dummy1 = ABCD0;
    dummy2 = ABCDk;
    dummy3 = ABCDc;
    dummy4 = ABCDkk;
    dummy5 = ABCDck;
    return;
  endif

  % Extract dAdx,etc from ABCDk,etc
  Ndx=Nk+Nc+Nkk+Nck;
  dAdx=cell(1,Ndx);
  dBdx=cell(1,Ndx);
  dCdx=cell(1,Ndx);
  dDdx=cell(1,Ndx);
  dCapdx=cell(1,Ndx);
  dDapdx=cell(1,Ndx);

  Rs=1:Ns;
  for s=1:Nk
    sk=s;
    dAdx{sk}=ABCDk{s}(Rs,Rs);
    dBdx{sk}=ABCDk{s}(Rs,Ns+1);
    dCdx{sk}=ABCDk{s}(Ns+1,Rs);
    dDdx{sk}=ABCDk{s}(Ns+1,Ns+1);
    dCapdx{sk}=ABCDk{s}(Ns+2,Rs);
    dDapdx{sk}=ABCDk{s}(Ns+2,Ns+1);
  endfor
  for s=1:Nc
    sc=Nk+s;
    dAdx{sc}=ABCDc{s}(Rs,Rs);
    dBdx{sc}=ABCDc{s}(Rs,Ns+1);
    dCdx{sc}=ABCDc{s}(Ns+1,Rs);
    dDdx{sc}=ABCDc{s}(Ns+1,Ns+1);
    dCapdx{sc}=ABCDc{s}(Ns+2,Rs);
    dDapdx{sc}=ABCDc{s}(Ns+2,Ns+1);
  endfor
  for s=1:Nkk
    skk=Nk+Nc+s;
    dAdx{skk}=ABCDkk{s}(Rs,Rs);
    dBdx{skk}=ABCDkk{s}(Rs,Ns+1);
    dCdx{skk}=ABCDkk{s}(Ns+1,Rs);
    dDdx{skk}=ABCDkk{s}(Ns+1,Ns+1);
    dCapdx{skk}=ABCDkk{s}(Ns+2,Rs);
    dDapdx{skk}=ABCDkk{s}(Ns+2,Ns+1);
  endfor
  for s=1:Nck
    sck=Nk+Nc+Nkk+s;
    dAdx{sck}=ABCDck{s}(Rs,Rs);
    dBdx{sck}=ABCDck{s}(Rs,Ns+1);
    dCdx{sck}=ABCDck{s}(Ns+1,Rs);
    dDdx{sck}=ABCDck{s}(Ns+1,Ns+1);
    dCapdx{sck}=ABCDck{s}(Ns+2,Rs);
    dDapdx{sck}=ABCDck{s}(Ns+2,Ns+1);
  endfor
  
  dummy1 = dAdx;
  dummy2 = dBdx;
  dummy3 = dCdx;
  dummy4 = dDdx;
  dummy5 = dCapdx;
  dummy6 = dDapdx;
  
endfunction
