function [Aap,Bap,Cap,Dap]=schurOneMAPlatticePipelined2Abcd_alternate(k,epsilon)
% [Aap,Bap,Cap,Dap] = schurOneMAPlatticePipelined2Abcd_alternate(k,epsilon)
% Find the state variable representation of a pipelined Schur one-multiplier
% all-pass lattice filter.
%
% Inputs:
%  k - the one-multiplier lattice filter coefficients
%  epsilon - one-multiplier lattice scaling
% Outputs:
%  [Aap,Bap;Cap,Dap] - state variable description for the all-pass filter
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
  
% Copyright (C) 2025 Robert G. Jenssen
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
  if (nargin > 2) || (nargout~=4)
    print_usage (["[Aap,Bap,Cap,Dap]=", ...
                  "schurOneMAPlatticePipelined2Abcd_alternate(k,epsilon)\n"]);
  endif

  if isempty(k)
    error("k is empty!");
  endif

  % Initialise
  k=k(:);
  N=length(k);
  if nargin == 1
    epsilon=ones(size(k));
  endif
  if length(k) ~= length(epsilon)
    error("length(k) ~= length(epsilon)");
  endif

  ABCD=[1,zeros(1,N); ...
         eye(N+1)];
  for s=1:(ceil(N/2)-1),
    sABCD=[[eye((s-1)*2),zeros((s-1)*2,(N+2)-((s-1)*2))]; ...
           [[[zeros(1,(s-1)*2), ...
              -k((s*2)-1), ...
              0, ...
              -k(s*2)*(1+(k((s*2)-1)*epsilon((s*2)-1))), ...
              (1+(k((s*2)-1)*epsilon((s*2)-1)))*(1+(k(s*2)*epsilon(s*2)))]; ...
             [zeros(1,(s-1)*2), ...
              (1-k((2*s)-1)*epsilon((2*s)-1)), ...
              0, ...
              -k((2*s)-1)*k(2*s), ...
              k((2*s)-1)*(1+k(2*s)*epsilon(2*s))]; ...
             [zeros(1,(s-1)*2), ...
              0, ...
              0, ...
              (1-k(2*s)*epsilon(2*s)), ...
              k(2*s)]], ...
            zeros(3,N+2-((s-1)*2)-4)]; ...
           [zeros((N+2-(s-1)*2)-3,((s-1)*2)+3),eye((N+2)-((s-1)*2)-3)]];
    ABCD=sABCD*ABCD;
  endfor
  
  if rem(N,2)
    sABCD=[[eye(N+1-2),zeros(N+1-2,3)]; ...
           [zeros(1,N+2-3),-k(N),                0,(1+(k(N)*epsilon(N)))]; ...
           [zeros(1,N+2-3),(1-(k(N)*epsilon(N))),0,k(N)]];
    ABCD=sABCD*ABCD;
  else
    sABCD=[[eye(N+1-3),zeros(N+1-3,4)]; ...
           [zeros(1,N+2-4), ...
            -k(N-1), ...
            0, ...
            -(1+(k(N-1)*epsilon(N-1)))*k(N), ...
            (1+(k(N-1)*epsilon(N-1)))*(1+(k(N)*epsilon(N)))]; ...
           [zeros(1,N+2-4), ...
            (1-(k(N-1)*epsilon(N-1))), ...
            0, ...
            -k(N-1)*k(N), ...
            k(N-1)*(1+(k(N)*epsilon(N)))]; ...
           [zeros(1,N+2-4), ...
            0, ...
            0, ...
            (1-k(N)*epsilon(N)), ...
            k(N)]];
    ABCD=sABCD*ABCD;
  endif        

  Aap=ABCD(1:N,1:N);
  Bap=ABCD(1:N,N+1);
  Cap=ABCD(N+1,1:N);
  Dap=ABCD(N+1,N+1);
           
endfunction

