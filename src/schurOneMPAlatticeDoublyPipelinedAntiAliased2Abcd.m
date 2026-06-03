function [A,B,C,D]=schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd ...
    (A1k,A2k,difference,B1k,B2k)
% [A,B,C,D] = schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd ...
%  (A1k,A2k,difference,B1k,B2k)
%
% Find the state variable description of the series combination of two
% parallel Schur one-multiplier doubly pipelined all-pass lattice filters
% and and anti-aliasing filter consisting of two parallel all-pass
% one-multiplier Schur lattice filters.
%
% Inputs:
%   A1k,A2k - one-multiplier allpass section coefficients
%   difference - difference of the A1 and A2 all-pass filter outputs
%   B1k,B2k - anti-aliasing filter one-multiplier all-pass section coefficients
% Outputs:
%   [A,B;C,D] - the state variable description

% Copyright (C) 2026 Robert G. Jenssen
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
  if (nargin ~= 5) || (nargout ~= 4)
    print_usage(["[A,B,C,D] = ", ...
                 "schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd", ...
                 "(A1k,A2k,difference,B1k,B2k)"]);
  endif

  [A1A,A1B,A1C,A1D] = schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
  [A2A,A2B,A2C,A2D] = schurOneMAPlatticeDoublyPipelined2Abcd(A2k);

  if difference
    mm=-1;
  else
    mm=1;
  endif

  A_1=[A1A,zeros(rows(A1A),columns(A2A));zeros(rows(A2A),columns(A1A)),A2A];
  B_1=[A1B;A2B];
  C_1=[A1C,mm*A2C]/2;
  D_1=[A1D+(mm*A2D)]/2;

  [B1A,B1B,B1C,B1D] = schurOneMAPlattice2Abcd(B1k);
  [B2A,B2B,B2C,B2D] = schurOneMAPlattice2Abcd(B2k);

  A_2=[B1A,zeros(rows(B1A),columns(B2A));zeros(rows(B2A),columns(B1A)),B2A];
  B_2=[B1B;B2B];
  C_2=[B1C,B2C]/2;
  D_2=[B1D+B2D]/2;

  A=[A_1,zeros(rows(A_1),columns(A_2));B_2*C_1,A_2];
  B=[B_1;B_2*D_1];
  C=[D_2*C_1,C_2];
  D=[D_2*D_1];
  
endfunction
