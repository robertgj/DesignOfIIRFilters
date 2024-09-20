function [Aap,Bap,Cap,Dap,ABCDap0,ABCDapk,ABCDapkk] = ...
  schurOneMAPlatticePipelined2Abcd(k,kk)
% [Aap,Bap,Cap,Dap,ABCDap0,ABCDapk,ABCDapkk] = ...
%   schurOneMAPlatticePipelined2Abcd(k,kk)
% Find the state variable representation of a pipelined Schur one-multiplier
% all-pass lattice filter.
%
% Inputs:
%  k - the one-multiplier lattice filter coefficients
%  kk - k(1:(Nk-1)).*k(2:Nk)
% Outputs:
%  [Aap,Bap;Cap,Dap] - state variable description for the all-pass filter
%  ABCDap0,ABCDapk,ABCDapkk - coefficient matrixes for the all-pass filter
%
% The lattice filter structure is (for N odd):
%                                           
%       _______                 _______            _______
%       |     |   __xN__        |     |            |     |  __x1__  
%  In ->|     |-->|z^-1|->...-->|     |->--------->|     |->|z^-1|->o
%       |  N  |   ------        |  2  |            |  1  |  ------  |
%       |     |                 |     |   __x2__   |     |          |
%  AP <-|     |<----------...<--|     |<--|z^-1|<--|     |<---------|
% Out   -------                 -------   ------   -------
%
% Each module 1,..,N is implemented as:
%                      
%               k    epsilon 
%     >---o->+---->o---------->+--->
%             ^\  /  
%               \/       
%               /\
%              /  \-epsilon
%             v    \
%     <------+<-----o--------------<
%
% The epsilon scaling is assumed to be applied after the k are determined.
  
% Copyright (C) 2024 Robert G. Jenssen
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
  if nargin<1 || nargin>3 || nargout<4 || nargout>7
    print_usage("[Aap,Bap,Cap,Dap] = schurOneMAPlatticePipelined2Abcd(k)\n\
[Aap,Bap,Cap,Dap,ABCDap0,ABCDapk,ABCDapkk] = ...\n\
  schurOneMAPlatticePipelined2Abcd(k,kk)\n");
  endif

  if isempty(k)
    error("k is empty!");
  endif

  % Initialise
  k=k(:);
  Nk=length(k);
  if nargin==1
    kk=k(1:(Nk-1)).*k(2:Nk);
  else
    if length(kk) ~= (length(k)-1)
      error("length(kk) ~= (length(k)-1)");
    endif
    kk=kk(:);
  endif

  [A,B,~,~,Cap,Dap,ABCD0,ABCDk,~,ABCDkk,~] = ...
    schurOneMlatticePipelined2Abcd ...
      (k,ones(size(k)),zeros(length(k)+1,1),kk,zeros(size(kk)));

  % Extract the state variable description
  Ns=rows(A);
  Rtap=2:3:Ns;

  ABCDap=[A,B;Cap,Dap];
  if ~isempty(Rtap)
    ABCDap(Rtap,:)=[];
    ABCDap(:,Rtap)=[];
  endif
  if rows(ABCDap) ~= (Nk+1)
    error("rows(ABCDap) ~= (Nk+1)");
  endif
  if columns(ABCDap) ~= (Nk+1)
    error("columns(ABCDap) ~= (Nk+1)");
  endif

  Aap=ABCDap(1:Nk,1:Nk);
  Bap=ABCDap(1:Nk,Nk+1);
  Cap=ABCDap(Nk+1,1:Nk);
  Dap=ABCDap(Nk+1,Nk+1);

  if nargout == 4
    return;
  endif

  % Find the matrix coefficients of k and kk

  % Constant coefficient matrix
  ABCDap0=ABCD0;
  ABCDap0(Ns+1,:)=[];
  if ~isempty(Rtap)
    ABCDap0(Rtap,:)=[];
    ABCDap0(:,Rtap)=[];
  endif
  
  % k coefficient matrixes
  ABCDapk=cell(1,Nk);
  for s=1:Nk,
    ABCDapk{s}=ABCDk{s};
    ABCDapk{s}(Ns+1,:)=[];
    if ~isempty(Rtap)
      ABCDapk{s}(Rtap,:)=[];
      ABCDapk{s}(:,Rtap)=[];
    endif
  endfor
  
  % kk coefficient matrixes
  ABCDapkk=cell(1,Nk-1);
  for s=1:Nk-1,
    ABCDapkk{s}=ABCDkk{s};
    ABCDapkk{s}(Ns+1,:)=[];
    if ~isempty(Rtap)
      ABCDapkk{s}(Rtap,:)=[];
      ABCDapkk{s}(:,Rtap)=[];
    endif
  endfor
  
endfunction

