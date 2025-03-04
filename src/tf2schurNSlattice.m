function [s10,s11,s20,s00,s02,s22,c,S] = tf2schurNSlattice(n,d)
% [s10,s11,s20,s00,s02,s22,c,S] = tf2schurNSlattice(n,d)
% Synthesise the normalised scaled lattice filter 
% corresponding to of the transfer function N(z)/D(z) where 
% N(z)=n(1)+n(2)z+n(3)z^2 etc. For a stable, causal filter, the 
% denominator, D(z), has all its zeros within the unit circle and 
% is a Schur polynomial. The input, D(z), is decomposed into a Schur 
% orthonormal polynomial basis. The output, N(z), is expanded in this 
% basis.
%
% The lattice filter structure is:
%       _______          _______                _______    s10(0)
% Out <-|     |<---------|     |<---------...<--|     |<---------- 
%       |     |  ______  |     |  ______        |     |  ______  |
%  In ->|  N  |->|z^-1|->| N-1 |->|z^-1|->...-->|  1  |->|z^-1|->o
%       |     |  ------  |     |  ------        |     |  ------  |
%  AP <-|     |<---------|     |<---------...<--|     |<----------
% Out   -------          -------                ------- 
%
% Each module 1,..,N is implemented as:
%                      
%       <---------+<----------------<
%                 ^     s11       
%              s10|
%                 |
%       >---------o--o------>+------>
%                    |  s00  ^
%                 s20|       |s02 
%                    V  s22  |
%       <------------+<------o------<
%
% c is the vector of coefficients obtained by expanding N(z) in the
% Schur basis. Recall that schurNSscale combines s10(0) and s11(1).
%
% ng and ngap are the round-off noise gains for the output and all-pass
% transfer functions (In to Out) and (In to APOut). 
% Reference: Chapter 12 of "VLSI Digital Signal Processing Systems: 
% Design and Implementation", by K. K. Parhi, Wiley, ISBN 0-471-24186-5

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

% Sanity check
if (nargin ~= 2) || ((nargout ~= 6) && (nargout ~= 8))
  print_usage("[s10,s11,s20,s00,s02,s22,c,S] = tf2schurNSlattice(n,d)");
endif

% Find the Schur decomposition of the denominator
[k,S] = schurdecomp(d);

% Expand the numerator in the Schur basis
c = schurexpand(n,S);

% Scale the lattice output taps
[s10,s11,s20,s00,s02,s22] = schurNSscale(k,c);

endfunction
